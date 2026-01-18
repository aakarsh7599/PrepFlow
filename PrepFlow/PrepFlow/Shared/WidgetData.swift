import Foundation

// MARK: - Widget Data (Shared between app and widget)
struct SharedWidgetData: Codable {
    let lldTopic: SharedTopicSummary
    let hldTopic: SharedTopicSummary
    let dsaTopic: SharedTopicSummary
    let lldCompleted: Bool
    let hldCompleted: Bool
    let dsaCompleted: Bool
    let currentStreak: Int
    let totalDaysCompleted: Int
    let currentWeek: Int
    let currentDay: Int
    let lastUpdated: Date

    var completionPercentage: Double {
        let completed = [lldCompleted, hldCompleted, dsaCompleted].filter { $0 }.count
        return Double(completed) / 3.0
    }

    var completedCount: Int {
        [lldCompleted, hldCompleted, dsaCompleted].filter { $0 }.count
    }

    static var empty: SharedWidgetData {
        SharedWidgetData(
            lldTopic: SharedTopicSummary(title: "Loading...", subtitle: "", estimatedMinutes: 0, category: "LLD"),
            hldTopic: SharedTopicSummary(title: "Loading...", subtitle: "", estimatedMinutes: 0, category: "HLD"),
            dsaTopic: SharedTopicSummary(title: "Loading...", subtitle: "", estimatedMinutes: 0, category: "DSA"),
            lldCompleted: false,
            hldCompleted: false,
            dsaCompleted: false,
            currentStreak: 0,
            totalDaysCompleted: 0,
            currentWeek: 1,
            currentDay: 1,
            lastUpdated: Date()
        )
    }
}

struct SharedTopicSummary: Codable {
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let category: String
}
