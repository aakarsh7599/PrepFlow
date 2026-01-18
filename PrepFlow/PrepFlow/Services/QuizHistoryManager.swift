import Foundation
import SwiftData
import SwiftUI

// MARK: - Quiz History Manager
class QuizHistoryManager {
    static let shared = QuizHistoryManager()

    private init() {}

    // MARK: - Fetch Methods

    /// Get all quiz sessions, optionally filtered by category
    func getAllSessions(from context: ModelContext, category: String? = nil) -> [QuizSession] {
        var descriptor = FetchDescriptor<QuizSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )

        if let category = category {
            descriptor.predicate = #Predicate<QuizSession> { session in
                session.category == category
            }
        }

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching quiz sessions: \(error)")
            return []
        }
    }

    /// Get recent sessions (limited count)
    func getRecentSessions(from context: ModelContext, limit: Int = 5, category: String? = nil) -> [QuizSession] {
        var descriptor = FetchDescriptor<QuizSession>(
            sortBy: [SortDescriptor(\.startedAt, order: .reverse)]
        )
        descriptor.fetchLimit = limit

        if let category = category {
            descriptor.predicate = #Predicate<QuizSession> { session in
                session.category == category && session.completedAt != nil
            }
        } else {
            descriptor.predicate = #Predicate<QuizSession> { session in
                session.completedAt != nil
            }
        }

        do {
            return try context.fetch(descriptor)
        } catch {
            print("Error fetching recent sessions: \(error)")
            return []
        }
    }

    // MARK: - Statistics

    /// Get overall statistics
    func getOverallStats(from context: ModelContext) -> OverallQuizStats {
        let sessions = getAllSessions(from: context)
        let completedSessions = sessions.filter { $0.isCompleted }

        guard !completedSessions.isEmpty else {
            return OverallQuizStats(
                totalQuizzes: 0,
                averageScore: 0,
                bestCategory: nil,
                worstCategory: nil,
                totalQuestions: 0
            )
        }

        let totalScore = completedSessions.reduce(0.0) { $0 + $1.averageScore }
        let averageScore = totalScore / Double(completedSessions.count)

        // Calculate category stats
        let categoryStats = TopicCategoryType.allCases.map { category in
            let catSessions = completedSessions.filter { $0.category == category.rawValue }
            let avgScore = catSessions.isEmpty ? 0.0 : catSessions.reduce(0.0) { $0 + $1.averageScore } / Double(catSessions.count)
            return (category: category, score: avgScore, count: catSessions.count)
        }.filter { $0.count > 0 }

        let bestCategory = categoryStats.max(by: { $0.score < $1.score })?.category
        let worstCategory = categoryStats.min(by: { $0.score < $1.score })?.category

        let totalQuestions = completedSessions.reduce(0) { $0 + $1.questionsAnswered }

        return OverallQuizStats(
            totalQuizzes: completedSessions.count,
            averageScore: averageScore,
            bestCategory: bestCategory,
            worstCategory: worstCategory,
            totalQuestions: totalQuestions
        )
    }

    /// Get statistics per category
    func getCategoryStats(from context: ModelContext) -> [CategoryStats] {
        return TopicCategoryType.allCases.map { category in
            let sessions = getAllSessions(from: context, category: category.rawValue)
                .filter { $0.isCompleted }

            guard !sessions.isEmpty else {
                return CategoryStats(
                    category: category,
                    quizCount: 0,
                    averageScore: 0,
                    bestScore: 0,
                    trend: .insufficient
                )
            }

            let avgScore = sessions.reduce(0.0) { $0 + $1.averageScore } / Double(sessions.count)
            let bestScore = sessions.max(by: { $0.averageScore < $1.averageScore })?.averageScore ?? 0

            // Calculate trend from last 5 quizzes
            let trend = calculateTrend(sessions: Array(sessions.prefix(5)))

            return CategoryStats(
                category: category,
                quizCount: sessions.count,
                averageScore: avgScore,
                bestScore: bestScore,
                trend: trend
            )
        }
    }

    // MARK: - Weak Areas Analysis

    /// Identify weak areas based on quiz performance
    func getWeakAreas(from context: ModelContext, category: String? = nil) -> [WeakArea] {
        let sessions = getAllSessions(from: context, category: category)
            .filter { $0.isCompleted }

        // Group questions by topic
        var topicStats: [String: (scores: [Int], missedPoints: [String], category: String)] = [:]

        for session in sessions {
            for question in session.questions {
                let topic = question.topic.isEmpty ? "General" : question.topic
                if var stats = topicStats[topic] {
                    stats.scores.append(question.score)
                    stats.missedPoints.append(contentsOf: question.missedPoints)
                    topicStats[topic] = stats
                } else {
                    topicStats[topic] = (
                        scores: [question.score],
                        missedPoints: question.missedPoints,
                        category: session.category
                    )
                }
            }
        }

        // Convert to weak areas (topics with average score < 7)
        return topicStats.compactMap { (topic, stats) in
            let avgScore = Double(stats.scores.reduce(0, +)) / Double(stats.scores.count)

            // Only include if below threshold and has enough data
            guard avgScore < 7.0 && stats.scores.count >= 2 else { return nil }

            // Get most common missed concepts
            let missedConcepts = getMostFrequent(items: stats.missedPoints, limit: 3)

            return WeakArea(
                topic: topic,
                category: stats.category,
                averageScore: avgScore,
                quizCount: stats.scores.count,
                missedConcepts: missedConcepts
            )
        }
        .sorted { $0.averageScore < $1.averageScore }
    }

    /// Get commonly missed concepts across all quizzes
    func getCommonMistakes(from context: ModelContext, limit: Int = 10) -> [(concept: String, frequency: Int)] {
        let sessions = getAllSessions(from: context).filter { $0.isCompleted }

        var allMissedPoints: [String] = []
        for session in sessions {
            for question in session.questions {
                allMissedPoints.append(contentsOf: question.missedPoints)
            }
        }

        // Count frequency
        var frequency: [String: Int] = [:]
        for point in allMissedPoints {
            frequency[point, default: 0] += 1
        }

        return frequency
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { ($0.key, $0.value) }
    }

    // MARK: - Improvement Trend

    /// Get score improvement trend for a category
    func getImprovementTrend(from context: ModelContext, category: String? = nil, count: Int = 10) -> [Double] {
        var sessions = getAllSessions(from: context, category: category)
            .filter { $0.isCompleted }
            .sorted { $0.startedAt < $1.startedAt } // Oldest first for trend

        // Take last N sessions
        if sessions.count > count {
            sessions = Array(sessions.suffix(count))
        }

        return sessions.map { $0.averageScore }
    }

    /// Calculate best score for a category
    func getBestScore(from context: ModelContext, category: String) -> Double? {
        let sessions = getAllSessions(from: context, category: category)
            .filter { $0.isCompleted }

        return sessions.max(by: { $0.averageScore < $1.averageScore })?.averageScore
    }

    // MARK: - Helper Methods

    private func calculateTrend(sessions: [QuizSession]) -> PerformanceTrend {
        guard sessions.count >= 3 else { return .insufficient }

        let sortedByDate = sessions.sorted { $0.startedAt < $1.startedAt }
        let scores = sortedByDate.map { $0.averageScore }

        // Simple linear regression direction
        let n = Double(scores.count)
        let sumX = (0..<scores.count).reduce(0.0) { $0 + Double($1) }
        let sumY = scores.reduce(0.0, +)
        let sumXY = scores.enumerated().reduce(0.0) { $0 + Double($1.offset) * $1.element }
        let sumX2 = (0..<scores.count).reduce(0.0) { $0 + Double($1 * $1) }

        let slope = (n * sumXY - sumX * sumY) / (n * sumX2 - sumX * sumX)

        if slope > 0.3 {
            return .improving
        } else if slope < -0.3 {
            return .declining
        } else {
            return .stable
        }
    }

    private func getMostFrequent(items: [String], limit: Int) -> [String] {
        var frequency: [String: Int] = [:]
        for item in items {
            frequency[item, default: 0] += 1
        }

        return frequency
            .sorted { $0.value > $1.value }
            .prefix(limit)
            .map { $0.key }
    }
}

// MARK: - Supporting Types
struct OverallQuizStats {
    let totalQuizzes: Int
    let averageScore: Double
    let bestCategory: TopicCategoryType?
    let worstCategory: TopicCategoryType?
    let totalQuestions: Int

    var formattedAverageScore: String {
        String(format: "%.1f", averageScore)
    }
}
