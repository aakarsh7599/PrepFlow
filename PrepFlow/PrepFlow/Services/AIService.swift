import Foundation
import Combine

// MARK: - AI Provider Enum
enum AIProvider: String {
    case claude = "claude"
    case openai = "openai"
}

// MARK: - Unified AI Service
class AIService: ObservableObject {
    static let shared = AIService()

    @Published var isProcessing = false
    @Published var lastError: String?

    private init() {}

    // MARK: - Provider Selection
    private var provider: AIProvider {
        let preferred = UserDefaults.standard.string(forKey: "preferredAIProvider") ?? "claude"
        return AIProvider(rawValue: preferred) ?? .claude
    }

    private var claudeAPIKey: String {
        UserDefaults.standard.string(forKey: "claudeAPIKey") ?? ""
    }

    private var openAIAPIKey: String {
        UserDefaults.standard.string(forKey: "openAIAPIKey") ?? ""
    }

    private var activeAPIKey: String {
        switch provider {
        case .claude: return claudeAPIKey
        case .openai: return openAIAPIKey
        }
    }

    var isConfigured: Bool {
        !activeAPIKey.isEmpty
    }

    // MARK: - Validate Journal Entry
    func validateJournalEntry(
        topic: String,
        category: String,
        journalContent: String
    ) async throws -> JournalValidation {
        guard isConfigured else {
            throw AIError.missingAPIKey
        }

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

        Respond in JSON format only, no markdown:
        {"score": <number>, "feedback": "<string>", "followUpQuestions": ["<string>"], "knowledgeGaps": ["<string>"]}
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
    ) async throws -> [QuizQuestion] {
        guard isConfigured else {
            throw AIError.missingAPIKey
        }

        let prompt = """
        You are an expert technical interviewer. Generate \(count) \(difficulty) difficulty interview questions about "\(topic)" (category: \(category)).

        For each question, provide:
        1. The question itself (clear, specific)
        2. A helpful hint
        3. Key points that should be covered in a good answer (3-5 points)

        Respond in JSON format only, no markdown:
        {"questions": [{"question": "<string>", "hint": "<string>", "keyPoints": ["<string>"]}]}
        """

        let response = try await sendMessage(prompt: prompt)
        return try parseQuizResponse(response)
    }

    // MARK: - Evaluate Quiz Answer
    func evaluateQuizAnswer(
        question: String,
        expectedPoints: [String],
        userAnswer: String
    ) async throws -> AnswerEvaluation {
        guard isConfigured else {
            throw AIError.missingAPIKey
        }

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
        4. Points they missed or should improve

        Respond in JSON format only, no markdown:
        {"score": <number>, "feedback": "<string>", "coveredPoints": ["<string>"], "missedPoints": ["<string>"]}
        """

        let response = try await sendMessage(prompt: prompt)
        return try parseAnswerEvaluation(response)
    }

    // MARK: - Send Message (Provider-agnostic)
    private func sendMessage(prompt: String) async throws -> String {
        switch provider {
        case .claude:
            return try await sendClaudeMessage(prompt: prompt)
        case .openai:
            return try await sendOpenAIMessage(prompt: prompt)
        }
    }

    // MARK: - Claude API
    private func sendClaudeMessage(prompt: String) async throws -> String {
        let url = URL(string: "https://api.anthropic.com/v1/messages")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue(claudeAPIKey, forHTTPHeaderField: "x-api-key")
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
            throw AIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorBody = String(data: data, encoding: .utf8) {
                throw AIError.apiError(message: "Claude API error (\(httpResponse.statusCode)): \(errorBody)")
            }
            throw AIError.apiError(message: "Claude API error: \(httpResponse.statusCode)")
        }

        struct ClaudeResponse: Decodable {
            struct Content: Decodable {
                let text: String
            }
            let content: [Content]
        }

        let result = try JSONDecoder().decode(ClaudeResponse.self, from: data)
        return result.content.first?.text ?? ""
    }

    // MARK: - OpenAI API
    private func sendOpenAIMessage(prompt: String) async throws -> String {
        let url = URL(string: "https://api.openai.com/v1/chat/completions")!

        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        request.setValue("Bearer \(openAIAPIKey)", forHTTPHeaderField: "Authorization")

        let body: [String: Any] = [
            "model": "gpt-4o-mini",
            "messages": [
                ["role": "system", "content": "You are an expert technical interviewer helping with interview preparation. Always respond with valid JSON only, no markdown formatting."],
                ["role": "user", "content": prompt]
            ],
            "max_tokens": 1024,
            "temperature": 0.7
        ]

        request.httpBody = try JSONSerialization.data(withJSONObject: body)

        let (data, response) = try await URLSession.shared.data(for: request)

        guard let httpResponse = response as? HTTPURLResponse else {
            throw AIError.invalidResponse
        }

        guard httpResponse.statusCode == 200 else {
            if let errorBody = String(data: data, encoding: .utf8) {
                throw AIError.apiError(message: "OpenAI API error (\(httpResponse.statusCode)): \(errorBody)")
            }
            throw AIError.apiError(message: "OpenAI API error: \(httpResponse.statusCode)")
        }

        struct OpenAIResponse: Decodable {
            struct Choice: Decodable {
                struct Message: Decodable {
                    let content: String
                }
                let message: Message
            }
            let choices: [Choice]
        }

        let result = try JSONDecoder().decode(OpenAIResponse.self, from: data)
        return result.choices.first?.message.content ?? ""
    }

    // MARK: - Response Parsing
    private func parseValidationResponse(_ response: String) throws -> JournalValidation {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.parseError
        }
        return try JSONDecoder().decode(JournalValidation.self, from: data)
    }

    private func parseQuizResponse(_ response: String) throws -> [QuizQuestion] {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.parseError
        }
        struct Container: Decodable {
            let questions: [QuizQuestion]
        }
        let container = try JSONDecoder().decode(Container.self, from: data)
        return container.questions
    }

    private func parseAnswerEvaluation(_ response: String) throws -> AnswerEvaluation {
        let jsonString = extractJSON(from: response)
        guard let data = jsonString.data(using: .utf8) else {
            throw AIError.parseError
        }
        return try JSONDecoder().decode(AnswerEvaluation.self, from: data)
    }

    private func extractJSON(from text: String) -> String {
        // Remove markdown code blocks if present
        var cleaned = text
        if let start = cleaned.range(of: "```json") {
            cleaned = String(cleaned[start.upperBound...])
        } else if let start = cleaned.range(of: "```") {
            cleaned = String(cleaned[start.upperBound...])
        }
        if let end = cleaned.range(of: "```") {
            cleaned = String(cleaned[..<end.lowerBound])
        }
        cleaned = cleaned.trimmingCharacters(in: .whitespacesAndNewlines)

        // Find JSON object
        if let start = cleaned.firstIndex(of: "{"),
           let end = cleaned.lastIndex(of: "}") {
            return String(cleaned[start...end])
        }
        return cleaned
    }
}

// MARK: - Response Types
struct JournalValidation: Codable {
    let score: Int
    let feedback: String
    let followUpQuestions: [String]
    let knowledgeGaps: [String]
}

struct QuizQuestion: Codable, Identifiable {
    var id: UUID { UUID() }
    let question: String
    let hint: String
    let keyPoints: [String]

    enum CodingKeys: String, CodingKey {
        case question, hint, keyPoints
    }
}

struct AnswerEvaluation: Codable {
    let score: Int
    let feedback: String
    let coveredPoints: [String]
    let missedPoints: [String]
}

// MARK: - Errors
enum AIError: Error, LocalizedError {
    case missingAPIKey
    case invalidResponse
    case apiError(message: String)
    case parseError

    var errorDescription: String? {
        switch self {
        case .missingAPIKey:
            return "Please configure your API key in Settings"
        case .invalidResponse:
            return "Invalid response from AI service"
        case .apiError(let message):
            return message
        case .parseError:
            return "Failed to parse AI response"
        }
    }
}
