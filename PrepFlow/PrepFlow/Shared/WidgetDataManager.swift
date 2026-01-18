import Foundation
import WidgetKit

// MARK: - Widget Data Manager (App Side)
class AppWidgetDataManager {
    static let shared = AppWidgetDataManager()
    private let groupIdentifier = "group.prepflow.shared"
    private let widgetDataKey = "widgetData"
    private let userDefaults: UserDefaults?

    private init() {
        userDefaults = UserDefaults(suiteName: groupIdentifier)
    }

    // MARK: - Save Widget Data
    func saveWidgetData(_ data: SharedWidgetData) {
        guard let userDefaults = userDefaults else { return }

        do {
            let encoded = try JSONEncoder().encode(data)
            userDefaults.set(encoded, forKey: widgetDataKey)
            // Trigger widget refresh
            WidgetCenter.shared.reloadAllTimelines()
        } catch {
            print("Failed to save widget data: \(error)")
        }
    }

    // MARK: - Load Widget Data
    func loadWidgetData() -> SharedWidgetData {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: widgetDataKey) else {
            return .empty
        }

        do {
            return try JSONDecoder().decode(SharedWidgetData.self, from: data)
        } catch {
            return .empty
        }
    }

    // MARK: - Update from Current State
    func updateWidgetData(
        lldTopic: CurriculumTopic,
        hldTopic: CurriculumTopic,
        dsaTopic: CurriculumTopic,
        lldCompleted: Bool,
        hldCompleted: Bool,
        dsaCompleted: Bool,
        currentStreak: Int,
        totalDaysCompleted: Int,
        currentWeek: Int,
        currentDay: Int
    ) {
        let data = SharedWidgetData(
            lldTopic: SharedTopicSummary(
                title: lldTopic.title,
                subtitle: lldTopic.subtitle,
                estimatedMinutes: lldTopic.estimatedMinutes,
                category: "LLD"
            ),
            hldTopic: SharedTopicSummary(
                title: hldTopic.title,
                subtitle: hldTopic.subtitle,
                estimatedMinutes: hldTopic.estimatedMinutes,
                category: "HLD"
            ),
            dsaTopic: SharedTopicSummary(
                title: dsaTopic.title,
                subtitle: dsaTopic.subtitle,
                estimatedMinutes: dsaTopic.estimatedMinutes,
                category: "DSA"
            ),
            lldCompleted: lldCompleted,
            hldCompleted: hldCompleted,
            dsaCompleted: dsaCompleted,
            currentStreak: currentStreak,
            totalDaysCompleted: totalDaysCompleted,
            currentWeek: currentWeek,
            currentDay: currentDay,
            lastUpdated: Date()
        )

        saveWidgetData(data)
    }
}
