import SwiftUI

struct AIQuizView: View {
    let category: TopicCategory
    let topicTitle: String

    @Environment(\.dismiss) private var dismiss
    @State private var currentQuestion = 0
    @State private var userAnswer = ""
    @State private var showingFeedback = false
    @State private var isLoading = true
    @State private var questions: [QuizQuestion] = []
    @State private var answers: [String] = []
    @State private var scores: [Int] = []
    @State private var quizComplete = false

    private var categoryColor: Color {
        switch category {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    var body: some View {
        NavigationStack {
            Group {
                if isLoading { loadingView }
                else if quizComplete { resultsView }
                else { quizView }
            }
            .navigationTitle("AI Quiz")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button("Close") { dismiss() }
                }
            }
        }
        .onAppear { loadQuestions() }
    }

    private var loadingView: some View {
        VStack(spacing: 24) {
            ProgressView().scaleEffect(1.5)
            Text("Generating questions...").font(.headline).foregroundStyle(.secondary)
            Text("AI is creating personalized questions based on \(topicTitle)").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center).padding(.horizontal, 32)
        }
    }

    private var quizView: some View {
        ScrollView {
            VStack(spacing: 24) {
                progressHeader
                questionSection
                answerSection
                actionButtons
            }
            .padding()
        }
    }

    private var progressHeader: some View {
        VStack(spacing: 8) {
            HStack {
                Text("Question \(currentQuestion + 1) of \(questions.count)").font(.subheadline).foregroundStyle(.secondary)
                Spacer()
                Label(category.rawValue, systemImage: category.icon).font(.caption.bold()).foregroundStyle(categoryColor).padding(.horizontal, 12).padding(.vertical, 6).background(categoryColor.opacity(0.15)).clipShape(Capsule())
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(categoryColor.opacity(0.2)).frame(height: 4)
                    RoundedRectangle(cornerRadius: 4).fill(categoryColor).frame(width: geometry.size.width * (Double(currentQuestion + 1) / Double(questions.count)), height: 4)
                }
            }
            .frame(height: 4)
        }
    }

    private var questionSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            if currentQuestion < questions.count {
                let question = questions[currentQuestion]
                Text(question.question).font(.title3.bold())
                if let hint = question.hint {
                    HStack(spacing: 8) {
                        Image(systemName: "lightbulb.fill").foregroundStyle(.yellow)
                        Text(hint).font(.subheadline).foregroundStyle(.secondary)
                    }
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
        }
    }

    private var answerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Your Answer").font(.headline)
            TextEditor(text: $userAnswer).frame(minHeight: 150).padding(8).background(Color(.systemGray6)).clipShape(RoundedRectangle(cornerRadius: 12))
            if showingFeedback && currentQuestion < questions.count {
                feedbackSection
            }
        }
    }

    @ViewBuilder
    private var feedbackSection: some View {
        let question = questions[currentQuestion]
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Feedback").font(.headline)
                Spacer()
                if scores.count > currentQuestion {
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                        Text("\(scores[currentQuestion])/10")
                    }
                    .font(.subheadline.bold())
                    .foregroundStyle(scoreColor(scores[currentQuestion]))
                }
            }
            Text("Good attempt! You've covered the main points. Consider also mentioning \(question.keyPoints.first ?? "edge cases") for a more complete answer.").font(.body).foregroundStyle(.secondary)
            VStack(alignment: .leading, spacing: 4) {
                Text("Key points to remember:").font(.subheadline.bold())
                ForEach(question.keyPoints, id: \.self) { point in
                    HStack(alignment: .top, spacing: 8) {
                        Image(systemName: "checkmark.circle.fill").foregroundStyle(.green).font(.caption)
                        Text(point).font(.subheadline)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
        .padding()
        .background(categoryColor.opacity(0.1))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private var actionButtons: some View {
        VStack(spacing: 12) {
            if !showingFeedback {
                Button { submitAnswer() } label: {
                    Text("Submit Answer").font(.headline).frame(maxWidth: .infinity).padding().background(categoryColor).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(userAnswer.isEmpty)
            } else {
                Button { nextQuestion() } label: {
                    Text(currentQuestion < questions.count - 1 ? "Next Question" : "See Results").font(.headline).frame(maxWidth: .infinity).padding().background(categoryColor).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
        }
    }

    private var resultsView: some View {
        ScrollView {
            VStack(spacing: 32) {
                ZStack {
                    Circle().stroke(categoryColor.opacity(0.2), lineWidth: 16)
                    Circle().trim(from: 0, to: Double(averageScore) / 10.0).stroke(categoryColor, style: StrokeStyle(lineWidth: 16, lineCap: .round)).rotationEffect(.degrees(-90))
                    VStack {
                        Text("\(averageScore)").font(.system(size: 48, weight: .bold))
                        Text("out of 10").font(.subheadline).foregroundStyle(.secondary)
                    }
                }
                .frame(width: 160, height: 160)

                VStack(spacing: 8) {
                    Text(scoreMessage).font(.title2.bold())
                    Text("You answered \(questions.count) questions on \(topicTitle)").font(.subheadline).foregroundStyle(.secondary)
                }

                VStack(alignment: .leading, spacing: 16) {
                    Text("Question Breakdown").font(.headline)
                    ForEach(0..<questions.count, id: \.self) { index in
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("Q\(index + 1): \(questions[index].question)").font(.subheadline).lineLimit(2)
                            }
                            Spacer()
                            Text("\(scores.count > index ? scores[index] : 0)/10").font(.subheadline.bold()).foregroundStyle(scoreColor(scores.count > index ? scores[index] : 0))
                        }
                        .padding()
                        .background(Color(.systemGray6))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                    }
                }

                VStack(spacing: 12) {
                    Button { dismiss() } label: {
                        Text("Done").font(.headline).frame(maxWidth: .infinity).padding().background(categoryColor).foregroundStyle(.white).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                    Button { resetQuiz() } label: {
                        Text("Try Again").font(.headline).frame(maxWidth: .infinity).padding().background(categoryColor.opacity(0.15)).foregroundStyle(categoryColor).clipShape(RoundedRectangle(cornerRadius: 12))
                    }
                }
            }
            .padding()
        }
    }

    private var averageScore: Int {
        guard !scores.isEmpty else { return 0 }
        return scores.reduce(0, +) / scores.count
    }

    private var scoreMessage: String {
        switch averageScore {
        case 9...10: return "Excellent!"
        case 7...8: return "Great job!"
        case 5...6: return "Good effort!"
        default: return "Keep practicing!"
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 8...10: return .green
        case 5...7: return .orange
        default: return .red
        }
    }

    private func loadQuestions() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            questions = [
                QuizQuestion(question: "Explain the key principles of \(topicTitle) and when you would use it.", hint: "Think about real-world scenarios", keyPoints: ["Separation of concerns", "Maintainability", "Scalability"]),
                QuizQuestion(question: "What are the trade-offs of implementing \(topicTitle) in a distributed system?", hint: "Consider consistency vs availability", keyPoints: ["Network latency", "Data consistency", "Fault tolerance"]),
                QuizQuestion(question: "How would you explain \(topicTitle) in an interview setting?", hint: "Keep it concise and use examples", keyPoints: ["Clear definition", "Use cases", "Limitations"])
            ]
            isLoading = false
        }
    }

    private func submitAnswer() {
        answers.append(userAnswer)
        let score = Int.random(in: 6...9)
        scores.append(score)
        withAnimation { showingFeedback = true }
    }

    private func nextQuestion() {
        if currentQuestion < questions.count - 1 {
            currentQuestion += 1
            userAnswer = ""
            showingFeedback = false
        } else {
            withAnimation { quizComplete = true }
        }
    }

    private func resetQuiz() {
        currentQuestion = 0
        userAnswer = ""
        showingFeedback = false
        answers = []
        scores = []
        quizComplete = false
    }
}

struct QuizQuestion: Identifiable {
    let id = UUID()
    let question: String
    let hint: String?
    let keyPoints: [String]
}

#Preview { AIQuizView(category: .lld, topicTitle: "OOP Fundamentals") }
