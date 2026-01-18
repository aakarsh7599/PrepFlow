import Foundation

// MARK: - Claude API Service
actor ClaudeService {
    static let shared = ClaudeService()

    private let baseURL = "https://api.anthropic.com/v1/messages"
    private var apiKey: String {
        UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
    }

    private init() {}

    // MARK: - Validate Journal Entry
    func validateJournalEntry(
        topic: String,
        category: String,
        journalContent: String
    ) async throws -> JournalValidationResponse {
        let prompt = """
        You are an expert technical interviewer and educator. A student is learning about "\(topic)" (category: \(category)) for interview preparation.

        They wrote the following journal entry about what they learned:

        ---
        \(journalContent)
        ---

        Please evaluate their understanding and provide:
        1. A score from 1-10 based on:
           - Accuracy of concepts (40%)
           - Depth of understanding (30%)
           - Practical applicability (30%)

        2. Constructive feedback (2-3 sentences)

        3. 2-3 follow-up questions to deepen their understanding

        4. Any knowledge gaps or misconceptions identified

        Respond in JSON format:
        {
            "score": <number>,
            "feedback": "<string>",
            "followUpQuestions": ["<string>", ...],
            "knowledgeGaps": ["<string>", ...]
        }
        """

        let response = try await sendMessage(prompt: prompt)
        return try parseValidationResponse(response)
    }

    // MARK: - Generate Quiz Questions
    func generateQuizQuestions(
        topic: String,
        category: String,
        difficulty: String = "medium",
        count: Int = 3
    ) async throws -> [QuizQuestionResponse] {
        let prompt = """
        You are an expert technical interviewer. Generate \(count) \(difficulty) difficulty interview questions about "\(topic)" (category: \(category)).

        For each question, provide:
        1. The question itself
        2. A helpful hint
        3. Key points that should be covered in a good answer

        Respond in JSON format:
        {
            "questions": [
                {
                    "question": "<string>",
                    "hint": "<string>",
                    "keyPoints": ["<string>", ...]
                }
            ]
        }
        """

        let response = try await sendMessage(prompt: prompt)
        return try parseQuizResponse(response)
    }

    // MARK: - Evaluate Quiz Answer
    func evaluateQuizAnswer(
        question: String,
        expectedPoints: [String],
        userAnswer: String
    ) async throws -> QuizAnswerEvaluation {
        let prompt = """
        You are an expert technical interviewer evaluating an answer.

        Question: \(question)

        Key points expected:
        \(expectedPoints.map { "- \($0)" }.joined(separator: "\n"))

        Student's answer:
        ---
        \(userAnswer)
        ---

        Evaluate the answer and provide:
        1. Score from 1-10
        2. Brief feedback (2-3 sentences)
        3. Points they covered well
        4. Points they missed

        Respond in JSON format:
        {
            "score": <number>,
            "feedback": "<string>",
            "coveredPoints": ["<string>", ...],
            "missedPoints": ["<string>", ...]
        }
        """

        let response = try await sendMessage(prompt: prompt)
        return try parseAnswerEvaluation(response)
    }

    // MARK: - Private Methods
    private func sendMessage(prompt: String) async throws -> String {
        guard !apiKey.isEmpty else {
            throw ClaudeError.missingAPIKey
        }

        guard let url = URL(string: baseURL) else {
            throw ClaudeError.invalidURL
        }

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(apiKey, forHTTPHeaderField: "x-api-key")
        request.setValue("2023-06-01", forHTTPHeaderField: "anthropic-version")

        let body: [String: Any] = [
            "model": "claude-sonnet-4-20250514",
            "max_tokens": 1024,
            "messages": [
                ["role": "user", "content": prompt]
            ]
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw ClaudeError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            throw ClaudeError.apiError(statusCode: httpResponse.statusCode)
        }

        let result = try JSONDecoder().decode(ClaudeAPIResponse.self, from: data)
        return result.content.first?.text ?? ""
    }

    private func parseValidationResponse(_ response: String) throws -> JournalValidationResponse {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw ClaudeError.parseError
        }
        return try JSONDecoder().decode(JournalValidationResponse.self, from: data)
    }

    private func parseQuizResponse(_ response: String) throws -> [QuizQuestionResponse] {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw ClaudeError.parseError
        }
        let container = try JSONDecoder().decode(QuizQuestionsContainer.self, from: data)
        return container.questions
    }

    private func parseAnswerEvaluation(_ response: String) throws -> QuizAnswerEvaluation {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw ClaudeError.parseError
        }
        return try JSONDecoder().decode(QuizAnswerEvaluation.self, from: data)
    }

    private func extractJSON(from text: String) -> String {
        if let start = text.range(of: "```json"),
           let end = text.range(of: "```", range: start.upperBound..<text.endIndex) {
            return String(text[start.upperBound..<end.lowerBound]).trimmingCharacters(in: .whitespacesAndNewlines)
        }
        if let start = text.firstIndex(of: "{"),
           let end = text.lastIndex(of: "}") {
            return String(text[start...end])
        }
        return text
    }
}

// MARK: - Response Types
struct ClaudeAPIResponse: Codable {
    let content: [ContentBlock]

    struct ContentBlock: Codable {
        let text: String
    }
}

struct JournalValidationResponse: Codable {
    let score: Int
    let feedback: String
    let followUpQuestions: [String]
    let knowledgeGaps: [String]
}

struct QuizQuestionsContainer: Codable {
    let questions: [QuizQuestionResponse]
}

struct QuizQuestionResponse: Codable, Identifiable {
    var id: UUID { UUID() }
    let question: String
    let hint: String
    let keyPoints: [String]
}

struct QuizAnswerEvaluation: Codable {
    let score: Int
    let feedback: String
    let coveredPoints: [String]
    let missedPoints: [String]
}

// MARK: - Errors
enum ClaudeError: Error, LocalizedError {
    case missingAPIKey
    case invalidURL
    case invalidResponse
    case apiError(statusCode: Int)
    case parseError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Please set your Claude API key in Settings"
        case .invalidURL:
            return "Invalid API URL"
        case .invalidResponse:
            return "Invalid response from server"
        case .apiError(let code):
            return "API error: \(code)"
        case .parseError:
            return "Failed to parse AI response"
        }
    }
}
