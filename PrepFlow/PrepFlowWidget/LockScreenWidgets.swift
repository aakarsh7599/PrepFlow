import WidgetKit
import SwiftUI

// MARK: - Lock Screen Widgets
struct PrepFlowLockScreenWidgets: Widget {
    let kind: String = "PrepFlowLockScreen"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            LockScreenWidgetView(entry: entry)
        }
        .configurationDisplayName("PrepFlow")
        .description("Quick glance at your daily progress.")
        .supportedFamilies([
            .accessoryCircular,
            .accessoryRectangular,
            .accessoryInline
        ])
    }
}

// MARK: - Lock Screen Entry View
struct LockScreenWidgetView: View {
    @Environment(\.widgetFamily) var family
    let entry: PrepFlowEntry

    var body: some View {
        switch family {
        case .accessoryCircular:
            CircularLockScreenView(entry: entry)
        case .accessoryRectangular:
            RectangularLockScreenView(entry: entry)
        case .accessoryInline:
            InlineLockScreenView(entry: entry)
        default:
            CircularLockScreenView(entry: entry)
        }
    }
}

// MARK: - Circular Lock Screen Widget
struct CircularLockScreenView: View {
    let entry: PrepFlowEntry

    var body: some View {
        Gauge(value: entry.data.completionPercentage) {
            Image(systemName: "book.fill")
        } currentValueLabel: {
            Text("\(entry.data.completedCount)/3")
                .font(.system(.caption, design: .rounded).bold())
        }
        .gaugeStyle(.accessoryCircular)
    }
}

// MARK: - Rectangular Lock Screen Widget
struct RectangularLockScreenView: View {
    let entry: PrepFlowEntry

    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            HStack {
                Text("Week \(entry.data.currentWeek), Day \(entry.data.currentDay)")
                    .font(.headline)

                Spacer()

                if entry.data.currentStreak > 0 {
                    HStack(spacing: 2) {
                        Image(systemName: "flame.fill")
                        Text("\(entry.data.currentStreak)")
                    }
                    .font(.caption)
                }
            }

            HStack(spacing: 8) {
                LockScreenProgressDot(label: "L", isCompleted: entry.data.lldCompleted)
                LockScreenProgressDot(label: "H", isCompleted: entry.data.hldCompleted)
                LockScreenProgressDot(label: "D", isCompleted: entry.data.dsaCompleted)

                Spacer()

                Text("\(entry.data.completedCount)/3 done")
                    .font(.caption)
            }
        }
        .containerBackground(.fill.tertiary, for: .widget)
    }
}

// MARK: - Inline Lock Screen Widget
struct InlineLockScreenView: View {
    let entry: PrepFlowEntry

    var body: some View {
        HStack(spacing: 4) {
            Text("\(entry.data.completedCount)/3 Complete")

            if entry.data.currentStreak > 0 {
                Text("\u{2022}")
                Image(systemName: "flame.fill")
                Text("\(entry.data.currentStreak) day streak")
            }
        }
    }
}

// MARK: - Supporting Views
struct LockScreenProgressDot: View {
    let label: String
    let isCompleted: Bool

    var body: some View {
        ZStack {
            Circle()
                .stroke(lineWidth: 1.5)
                .frame(width: 18, height: 18)

            if isCompleted {
                Image(systemName: "checkmark")
                    .font(.system(size: 10, weight: .bold))
            } else {
                Text(label)
                    .font(.system(size: 10, weight: .bold))
            }
        }
    }
}

// MARK: - Previews
#Preview("Circular", as: .accessoryCircular) {
    PrepFlowLockScreenWidgets()
} timeline: {
    PrepFlowEntry(date: Date(), data: WidgetData.sample)
}

#Preview("Rectangular", as: .accessoryRectangular) {
    PrepFlowLockScreenWidgets()
} timeline: {
    PrepFlowEntry(date: Date(), data: WidgetData.sample)
}

#Preview("Inline", as: .accessoryInline) {
    PrepFlowLockScreenWidgets()
} timeline: {
    PrepFlowEntry(date: Date(), data: WidgetData.sample)
}
