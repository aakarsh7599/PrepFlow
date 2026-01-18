import Foundation
import SwiftData

// MARK: - Daily Progress Model
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

    var isFullyCompleted: Bool {
        lldCompleted && hldCompleted && dsaCompleted
    }

    init(
        id: UUID = UUID(),
        date: Date = Date(),
        lldTopicId: UUID? = nil,
        hldTopicId: UUID? = nil,
        dsaTopicId: UUID? = nil,
        lldCompleted: Bool = false,
        hldCompleted: Bool = false,
        dsaCompleted: Bool = false,
        streak: Int = 0
    ) {
        self.id = id
        self.date = date
        self.lldTopicId = lldTopicId
        self.hldTopicId = hldTopicId
        self.dsaTopicId = dsaTopicId
        self.lldCompleted = lldCompleted
        self.hldCompleted = hldCompleted
        self.dsaCompleted = dsaCompleted
        self.streak = streak
    }
}

// MARK: - Journal Entry Model
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

// MARK: - Topic Completion Model
@Model
final class TopicCompletion {
    var id: UUID
    var topicTitle: String
    var category: String
    var week: Int
    var day: Int
    var completedAt: Date
    var journalEntryId: UUID?
    var quizScore: Int?

    init(
        id: UUID = UUID(),
        topicTitle: String,
        category: String,
        week: Int,
        day: Int,
        completedAt: Date = Date(),
        journalEntryId: UUID? = nil,
        quizScore: Int? = nil
    ) {
        self.id = id
        self.topicTitle = topicTitle
        self.category = category
        self.week = week
        self.day = day
        self.completedAt = completedAt
        self.journalEntryId = journalEntryId
        self.quizScore = quizScore
    }
}
