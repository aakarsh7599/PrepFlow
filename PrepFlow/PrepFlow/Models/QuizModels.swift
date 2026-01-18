import Foundation
import SwiftData
import SwiftUI

// MARK: - Quiz Session Model
@Model
final class QuizSession {
    var id: UUID
    var category: String              // "LLD", "HLD", "DSA"
    var topicTitle: String?           // Specific topic or nil for random quiz
    var startedAt: Date
    var completedAt: Date?
    var totalQuestions: Int
    var averageScore: Double          // 0-10 scale
    var questionsAnswered: Int

    @Relationship(deleteRule: .cascade, inverse: \QuizQuestionRecord.session)
    var questions: [QuizQuestionRecord]

    var isCompleted: Bool {
        completedAt != nil
    }

    var scorePercentage: Double {
        averageScore / 10.0 * 100.0
    }

    var categoryType: TopicCategoryType? {
        TopicCategoryType(rawValue: category)
    }

    init(
        id: UUID = UUID(),
        category: String,
        topicTitle: String? = nil,
        startedAt: Date = Date(),
        completedAt: Date? = nil,
        totalQuestions: Int = 5,
        averageScore: Double = 0,
        questionsAnswered: Int = 0,
        questions: [QuizQuestionRecord] = []
    ) {
        self.id = id
        self.category = category
        self.topicTitle = topicTitle
        self.startedAt = startedAt
        self.completedAt = completedAt
        self.totalQuestions = totalQuestions
        self.averageScore = averageScore
        self.questionsAnswered = questionsAnswered
        self.questions = questions
    }
}

// MARK: - Quiz Question Record Model
@Model
final class QuizQuestionRecord {
    var id: UUID
    var questionText: String
    var hint: String
    var keyPoints: [String]           // Expected key points
    var userAnswer: String
    var score: Int                    // 1-10
    var feedback: String
    var coveredPoints: [String]
    var missedPoints: [String]
    var answeredAt: Date
    var topic: String                 // Topic this question was about

    var session: QuizSession?

    var scorePercentage: Double {
        Double(score) / 10.0 * 100.0
    }

    init(
        id: UUID = UUID(),
        questionText: String,
        hint: String = "",
        keyPoints: [String] = [],
        userAnswer: String = "",
        score: Int = 0,
        feedback: String = "",
        coveredPoints: [String] = [],
        missedPoints: [String] = [],
        answeredAt: Date = Date(),
        topic: String = ""
    ) {
        self.id = id
        self.questionText = questionText
        self.hint = hint
        self.keyPoints = keyPoints
        self.userAnswer = userAnswer
        self.score = score
        self.feedback = feedback
        self.coveredPoints = coveredPoints
        self.missedPoints = missedPoints
        self.answeredAt = answeredAt
        self.topic = topic
    }
}

// MARK: - Analytics Support Types
struct WeakArea: Identifiable {
    let id = UUID()
    let topic: String
    let category: String
    let averageScore: Double
    let quizCount: Int
    let missedConcepts: [String]
}

struct TopicPerformance: Identifiable {
    let id = UUID()
    let topic: String
    let averageScore: Double
    let attemptCount: Int
    let lastAttempt: Date?
    let trend: PerformanceTrend
}

enum PerformanceTrend {
    case improving
    case declining
    case stable
    case insufficient // Not enough data

    var icon: String {
        switch self {
        case .improving: return "arrow.up.right"
        case .declining: return "arrow.down.right"
        case .stable: return "arrow.right"
        case .insufficient: return "minus"
        }
    }

    var color: SwiftUI.Color {
        switch self {
        case .improving: return .green
        case .declining: return .red
        case .stable: return .orange
        case .insufficient: return .secondary
        }
    }
}

struct CategoryStats: Identifiable {
    let id = UUID()
    let category: TopicCategoryType
    let quizCount: Int
    let averageScore: Double
    let bestScore: Double
    let trend: PerformanceTrend
}
