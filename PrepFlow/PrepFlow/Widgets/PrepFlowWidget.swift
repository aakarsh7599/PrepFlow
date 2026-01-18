import WidgetKit
import SwiftUI

// MARK: - Widget Entry
struct PrepFlowEntry: TimelineEntry {
    let date: Date
    let lldTopic: String
    let hldTopic: String
    let dsaTopic: String
    let streak: Int
    let lldCompleted: Bool
    let hldCompleted: Bool
    let dsaCompleted: Bool
}

// MARK: - Timeline Provider
struct PrepFlowProvider: TimelineProvider {
    func placeholder(in context: Context) -> PrepFlowEntry {
        PrepFlowEntry(date: Date(), lldTopic: "OOP Fundamentals", hldTopic: "System Design Basics", dsaTopic: "Two Sum", streak: 12, lldCompleted: false, hldCompleted: false, dsaCompleted: false)
    }

    func getSnapshot(in context: Context, completion: @escaping (PrepFlowEntry) -> Void) {
        let entry = PrepFlowEntry(date: Date(), lldTopic: "Factory Pattern", hldTopic: "Load Balancing", dsaTopic: "Valid Palindrome", streak: 12, lldCompleted: true, hldCompleted: false, dsaCompleted: false)
        completion(entry)
    }

    func getTimeline(in context: Context, completion: @escaping (Timeline<PrepFlowEntry>) -> Void) {
        let entry = PrepFlowEntry(date: Date(), lldTopic: "Factory Pattern", hldTopic: "Load Balancing", dsaTopic: "Valid Palindrome", streak: 12, lldCompleted: false, hldCompleted: false, dsaCompleted: false)
        let nextUpdate = Calendar.current.date(byAdding: .hour, value: 1, to: Date())!
        let timeline = Timeline(entries: [entry], policy: .after(nextUpdate))
        completion(timeline)
    }
}

// MARK: - Small Widget View
struct SmallWidgetView: View {
    let entry: PrepFlowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: "flame.fill").foregroundStyle(.orange)
                Text("\(entry.streak)").font(.headline.bold())
                Spacer()
            }
            Spacer()
            Text("Today's Focus").font(.caption).foregroundStyle(.secondary)
            Text(entry.lldTopic).font(.subheadline.bold()).lineLimit(2)
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
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text("\(entry.streak)").font(.title2.bold())
                }
                Text("day streak").font(.caption).foregroundStyle(.secondary)
            }
            .frame(width: 80)
            Divider()
            VStack(alignment: .leading, spacing: 8) {
                TopicRow(icon: "cube.fill", color: .purple, title: entry.lldTopic, isCompleted: entry.lldCompleted)
                TopicRow(icon: "cloud.fill", color: .blue, title: entry.hldTopic, isCompleted: entry.hldCompleted)
                TopicRow(icon: "function", color: .green, title: entry.dsaTopic, isCompleted: entry.dsaCompleted)
            }
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct TopicRow: View {
    let icon: String
    let color: Color
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: icon).font(.caption).foregroundStyle(color).frame(width: 16)
            Text(title).font(.caption).lineLimit(1)
            Spacer()
            if isCompleted {
                Image(systemName: "checkmark.circle.fill").font(.caption).foregroundStyle(.green)
            }
        }
    }
}

// MARK: - Large Widget View
struct LargeWidgetView: View {
    let entry: PrepFlowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("PrepFlow").font(.headline)
                    Text(entry.date, format: .dateTime.weekday().month().day()).font(.caption).foregroundStyle(.secondary)
                }
                Spacer()
                HStack(spacing: 4) {
                    Image(systemName: "flame.fill").foregroundStyle(.orange)
                    Text("\(entry.streak)").font(.title2.bold())
                }
            }
            Divider()
            HStack(spacing: 16) {
                ProgressCircle(isCompleted: entry.lldCompleted, color: .purple, label: "LLD")
                ProgressCircle(isCompleted: entry.hldCompleted, color: .blue, label: "HLD")
                ProgressCircle(isCompleted: entry.dsaCompleted, color: .green, label: "DSA")
            }
            Divider()
            VStack(alignment: .leading, spacing: 12) {
                LargeTopicRow(category: "LLD", icon: "cube.fill", color: .purple, title: entry.lldTopic, isCompleted: entry.lldCompleted)
                LargeTopicRow(category: "HLD", icon: "cloud.fill", color: .blue, title: entry.hldTopic, isCompleted: entry.hldCompleted)
                LargeTopicRow(category: "DSA", icon: "function", color: .green, title: entry.dsaTopic, isCompleted: entry.dsaCompleted)
            }
            Spacer()
        }
        .padding()
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

struct ProgressCircle: View {
    let isCompleted: Bool
    let color: Color
    let label: String

    var body: some View {
        VStack(spacing: 4) {
            ZStack {
                Circle().stroke(color.opacity(0.2), lineWidth: 4)
                Circle().trim(from: 0, to: isCompleted ? 1.0 : 0.0).stroke(color, lineWidth: 4).rotationEffect(.degrees(-90))
                Image(systemName: isCompleted ? "checkmark" : "circle").font(.caption).foregroundStyle(color)
            }
            .frame(width: 36, height: 36)
            Text(label).font(.caption2).foregroundStyle(.secondary)
        }
    }
}

struct LargeTopicRow: View {
    let category: String
    let icon: String
    let color: Color
    let title: String
    let isCompleted: Bool

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.body).foregroundStyle(color).frame(width: 24)
            VStack(alignment: .leading, spacing: 2) {
                Text(category).font(.caption).foregroundStyle(.secondary)
                Text(title).font(.subheadline).lineLimit(1)
            }
            Spacer()
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle").foregroundStyle(isCompleted ? .green : .secondary)
        }
    }
}

// MARK: - Widget Configuration
struct PrepFlowWidget: Widget {
    let kind: String = "PrepFlowWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PrepFlowProvider()) { entry in
            WidgetEntryView(entry: entry)
        }
        .configurationDisplayName("PrepFlow")
        .description("Track your daily interview prep progress")
        .supportedFamilies([.systemSmall, .systemMedium, .systemLarge])
    }
}

struct WidgetEntryView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrepFlowEntry

    var body: some View {
        switch family {
        case .systemSmall: SmallWidgetView(entry: entry)
        case .systemMedium: MediumWidgetView(entry: entry)
        case .systemLarge: LargeWidgetView(entry: entry)
        default: SmallWidgetView(entry: entry)
        }
    }
}
