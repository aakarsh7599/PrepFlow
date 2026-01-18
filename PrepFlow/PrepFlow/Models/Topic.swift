import Foundation
import SwiftData

enum TopicCategory: String, Codable, CaseIterable {
    case lld = "LLD"
    case hld = "HLD"
    case dsa = "DSA"

    var color: String {
        switch self {
        case .lld: return "purple"
        case .hld: return "blue"
        case .dsa: return "green"
        }
    }

    var icon: String {
        switch self {
        case .lld: return "cube.fill"
        case .hld: return "cloud.fill"
        case .dsa: return "function"
        }
    }
}

@Model
final class Topic {
    var id: UUID
    var title: String
    var categoryRaw: String
    var day: Int
    var week: Int
    var content: String
    var subtopics: [String]
    var isCompleted: Bool
    var completedAt: Date?
    var resources: [String]

    var category: TopicCategory {
        get { TopicCategory(rawValue: categoryRaw) ?? .lld }
        set { categoryRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        category: TopicCategory,
        day: Int,
        week: Int,
        content: String,
        subtopics: [String] = [],
        isCompleted: Bool = false,
        resources: [String] = []
    ) {
        self.id = id
        self.title = title
        self.categoryRaw = category.rawValue
        self.day = day
        self.week = week
        self.content = content
        self.subtopics = subtopics
        self.isCompleted = isCompleted
        self.resources = resources
    }
}

@Model
final class DailyProgress {
    var id: UUID
    var date: Date
    var lldTopicId: UUID?
    var hldTopicId: UUID?
    var dsaTopicId: UUID?
    var lldCompleted: Bool
    var hldCompleted: Bool
    var dsaCompleted: Bool
    var streak: Int

    var completionPercentage: Double {
        let completed = [lldCompleted, hldCompleted, dsaCompleted].filter { $0 }.count
        return Double(completed) / 3.0
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        lldCompleted: Bool = false,
        hldCompleted: Bool = false,
        dsaCompleted: Bool = false,
        streak: Int = 0
    ) {
        self.id = id
        self.date = date
        self.lldCompleted = lldCompleted
        self.hldCompleted = hldCompleted
        self.dsaCompleted = dsaCompleted
        self.streak = streak
    }
}

@Model
final class JournalEntry {
    var id: UUID
    var date: Date
    var topicId: UUID?
    var category: String
    var content: String
    var aiValidationScore: Int?
    var aiFeedback: String?
    var followUpQuestions: [String]
    var knowledgeGaps: [String]

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        topicId: UUID? = nil,
        category: String = "",
        content: String = "",
        aiValidationScore: Int? = nil,
        aiFeedback: String? = nil,
        followUpQuestions: [String] = [],
        knowledgeGaps: [String] = []
    ) {
        self.id = id
        self.date = date
        self.topicId = topicId
        self.category = category
        self.content = content
        self.aiValidationScore = aiValidationScore
        self.aiFeedback = aiFeedback
        self.followUpQuestions = followUpQuestions
        self.knowledgeGaps = knowledgeGaps
    }
}
