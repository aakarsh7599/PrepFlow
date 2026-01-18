import WidgetKit
import SwiftUI

// MARK: - Widget Data Structure
struct WidgetData: Codable {
    let lldTopic: TopicSummary
    let hldTopic: TopicSummary
    let dsaTopic: TopicSummary
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

    static var empty: WidgetData {
        WidgetData(
            lldTopic: TopicSummary(title: "Loading...", subtitle: "", estimatedMinutes: 0, category: "LLD"),
            hldTopic: TopicSummary(title: "Loading...", subtitle: "", estimatedMinutes: 0, category: "HLD"),
            dsaTopic: TopicSummary(title: "Loading...", subtitle: "", estimatedMinutes: 0, category: "DSA"),
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

    static var sample: WidgetData {
        WidgetData(
            lldTopic: TopicSummary(title: "OOP Fundamentals", subtitle: "Classes, Objects", estimatedMinutes: 60, category: "LLD"),
            hldTopic: TopicSummary(title: "System Design", subtitle: "Scalability", estimatedMinutes: 60, category: "HLD"),
            dsaTopic: TopicSummary(title: "Arrays & Hashing", subtitle: "Two Sum", estimatedMinutes: 45, category: "DSA"),
            lldCompleted: true,
            hldCompleted: false,
            dsaCompleted: false,
            currentStreak: 5,
            totalDaysCompleted: 12,
            currentWeek: 2,
            currentDay: 5,
            lastUpdated: Date()
        )
    }
}

struct TopicSummary: Codable {
    let title: String
    let subtitle: String
    let estimatedMinutes: Int
    let category: String
}

// MARK: - Widget Data Manager
class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let groupIdentifier = "group.prepflow.shared"
    private let widgetDataKey = "widgetData"
    private let userDefaults: UserDefaults?

    init() {
        userDefaults = UserDefaults(suiteName: groupIdentifier)
    }

    func loadWidgetData() -> WidgetData {
        guard let userDefaults = userDefaults,
              let data = userDefaults.data(forKey: widgetDataKey) else {
            return .empty
        }

        do {
            return try JSONDecoder().decode(WidgetData.self, from: data)
        } catch {
            return .empty
        }
    }
}

// MARK: - Widget Provider
struct Provider: TimelineProvider {
    func placeholder(in context: Context) -> PrepFlowEntry {
        PrepFlowEntry(date: Date(), data: .sample)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrepFlowEntry) -> Void) {
        let data = WidgetDataManager.shared.loadWidgetData()
        let entry = PrepFlowEntry(date: Date(), data: data)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrepFlowEntry>) -> Void) {
        let data = WidgetDataManager.shared.loadWidgetData()
        let entry = PrepFlowEntry(date: Date(), data: data)

        // Refresh every 30 minutes
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 30, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Widget Entry
struct PrepFlowEntry: TimelineEntry {
    let date: Date
    let data: WidgetData
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PrepFlowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Header
            HStack {
                Text("PrepFlow")
                    .font(.caption2.bold())
                    .foregroundStyle(.secondary)
                Spacer()
                if entry.data.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                            .font(.caption2)
                            .foregroundStyle(.orange)
                        Text("\(entry.data.currentStreak)")
                            .font(.caption2.bold())
                    }
                }
            }

            Spacer()

            // Progress circles
            HStack(spacing: 12) {
                CompletionCircle(
                    label: "L",
                    isCompleted: entry.data.lldCompleted,
                    color: .purple
                )
                CompletionCircle(
                    label: "H",
                    isCompleted: entry.data.hldCompleted,
                    color: .blue
                )
                CompletionCircle(
                    label: "D",
                    isCompleted: entry.data.dsaCompleted,
                    color: .green
                )
            }

            Spacer()

            // Footer
            Text("Week \(entry.data.currentWeek), Day \(entry.data.currentDay)")
                .font(.caption2)
                .foregroundStyle(.secondary)
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Medium Widget View
struct MediumWidgetView: View {
    let entry: PrepFlowEntry

    var body: some View {
        HStack(spacing: 16) {
            // Left side - Progress
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text("Today")
                        .font(.headline.bold())
                    Spacer()
                    if entry.data.currentStreak > 0 {
                        HStack(spacing: 2) {
                            Image(systemName: "flame.fill")
                                .foregroundStyle(.orange)
                            Text("\(entry.data.currentStreak)")
                                .font(.subheadline.bold())
                        }
                    }
                }

                Text("Week \(entry.data.currentWeek), Day \(entry.data.currentDay)")
                    .font(.caption)
                    .foregroundStyle(.secondary)

                Spacer()

                // Progress circles
                HStack(spacing: 16) {
                    CompletionCircle(
                        label: "LLD",
                        isCompleted: entry.data.lldCompleted,
                        color: .purple
                    )
                    CompletionCircle(
                        label: "HLD",
                        isCompleted: entry.data.hldCompleted,
                        color: .blue
                    )
                    CompletionCircle(
                        label: "DSA",
                        isCompleted: entry.data.dsaCompleted,
                        color: .green
                    )
                }
            }

            Divider()

            // Right side - Topics
            VStack(alignment: .leading, spacing: 6) {
                TopicRow(
                    topic: entry.data.lldTopic,
                    isCompleted: entry.data.lldCompleted,
                    color: .purple
                )
                TopicRow(
                    topic: entry.data.hldTopic,
                    isCompleted: entry.data.hldCompleted,
                    color: .blue
                )
                TopicRow(
                    topic: entry.data.dsaTopic,
                    isCompleted: entry.data.dsaCompleted,
                    color: .green
                )
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Supporting Views
struct CompletionCircle: View {
    let label: String
    let isCompleted: Bool
    let color: Color

    var body: some View {
        ZStack {
            Circle()
                .stroke(color.opacity(0.3), lineWidth: 3)
                .frame(width: 32, height: 32)

            if isCompleted {
                Circle()
                    .fill(color)
                    .frame(width: 32, height: 32)

                Image(systemName: "checkmark")
                    .font(.caption.bold())
                    .foregroundStyle(.white)
            } else {
                Text(label)
                    .font(.caption2.bold())
                    .foregroundStyle(color)
            }
        }
    }
}

struct TopicRow: View {
    let topic: TopicSummary
    let isCompleted: Bool
    let color: Color

    var body: some View {
        HStack(spacing: 6) {
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.caption)
                .foregroundStyle(isCompleted ? color : .secondary)

            Text(topic.title)
                .font(.caption)
                .lineLimit(1)
                .foregroundStyle(isCompleted ? .secondary : .primary)
                .strikethrough(isCompleted)
        }
    }
}

// MARK: - Widget Configuration
struct PrepFlowSmallWidget: Widget {
    let kind: String = "PrepFlowSmallWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            SmallWidgetView(entry: entry)
        }
        .configurationDisplayName("Daily Progress")
        .description("Track your LLD, HLD, and DSA completion.")
        .supportedFamilies([.systemSmall])
    }
}

struct PrepFlowMediumWidget: Widget {
    let kind: String = "PrepFlowMediumWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            MediumWidgetView(entry: entry)
        }
        .configurationDisplayName("Today's Topics")
        .description("See today's topics and track completion.")
        .supportedFamilies([.systemMedium])
    }
}

// MARK: - Previews
#Preview("Small", as: .systemSmall) {
    PrepFlowSmallWidget()
} timeline: {
    PrepFlowEntry(date: Date(), data: .sample)
}

#Preview("Medium", as: .systemMedium) {
    PrepFlowMediumWidget()
} timeline: {
    PrepFlowEntry(date: Date(), data: .sample)
}
