import SwiftUI
import SwiftData

struct ProgressView: View {
    @Query private var dailyProgress: [DailyProgress]
    @State private var selectedTimeframe: Timeframe = .week

    enum Timeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    timeframePicker
                    statsSection
                    streakCalendarSection
                    categoryBreakdownSection
                    recentActivitySection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Progress")
        }
    }

    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(Timeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }

    private var statsSection: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                StatCard(title: "Current Streak", value: "\(currentStreak)", unit: "days", icon: "flame.fill", color: .orange)
                StatCard(title: "Total Days", value: "\(totalDays)", unit: "completed", icon: "checkmark.circle.fill", color: .green)
            }
            HStack(spacing: 16) {
                StatCard(title: "Topics Covered", value: "\(topicsCovered)", unit: "topics", icon: "book.fill", color: .blue)
                StatCard(title: "Avg. AI Score", value: "7.2", unit: "/10", icon: "brain.head.profile", color: .purple)
            }
        }
    }

    private var streakCalendarSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Activity Calendar")
                .font(.headline)

            LazyVGrid(columns: Array(repeating: GridItem(.flexible(), spacing: 4), count: 7), spacing: 4) {
                ForEach(0..<35, id: \.self) { index in
                    CalendarDay(day: index + 1, isCompleted: index < 12, isPartial: index == 12, isToday: index == 17)
                }
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var categoryBreakdownSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Category Progress")
                .font(.headline)

            VStack(spacing: 12) {
                CategoryProgressBar(category: "LLD", progress: 0.35, completed: 21, total: 60, color: .purple)
                CategoryProgressBar(category: "HLD", progress: 0.35, completed: 21, total: 60, color: .blue)
                CategoryProgressBar(category: "DSA", progress: 0.35, completed: 21, total: 60, color: .green)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var recentActivitySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Activity")
                .font(.headline)

            VStack(spacing: 0) {
                ActivityRow(title: "Completed LLD: Factory Pattern", subtitle: "Today, 2:30 PM", icon: "checkmark.circle.fill", color: .green)
                Divider().padding(.leading, 44)
                ActivityRow(title: "Journaled HLD learnings", subtitle: "Today, 11:45 AM", icon: "pencil.circle.fill", color: .purple)
                Divider().padding(.leading, 44)
                ActivityRow(title: "AI Quiz: 8/10", subtitle: "Yesterday, 9:00 PM", icon: "brain.head.profile", color: .blue)
                Divider().padding(.leading, 44)
                ActivityRow(title: "Solved: Two Sum II", subtitle: "Yesterday, 6:15 PM", icon: "function", color: .green)
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var currentStreak: Int { return 12 }
    private var totalDays: Int { return dailyProgress.count }
    private var topicsCovered: Int { return 36 }
}

struct StatCard: View {
    let title: String
    let value: String
    let unit: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Image(systemName: icon)
                    .foregroundStyle(color)
                Spacer()
            }
            Spacer()
            HStack(alignment: .firstTextBaseline, spacing: 4) {
                Text(value)
                    .font(.title.bold())
                Text(unit)
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .padding()
        .frame(maxWidth: .infinity, minHeight: 100, alignment: .leading)
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 16))
    }
}

struct CalendarDay: View {
    let day: Int
    let isCompleted: Bool
    let isPartial: Bool
    let isToday: Bool

    var body: some View {
        ZStack {
            if isCompleted {
                RoundedRectangle(cornerRadius: 4).fill(.green)
            } else if isPartial {
                RoundedRectangle(cornerRadius: 4).fill(.green.opacity(0.4))
            } else {
                RoundedRectangle(cornerRadius: 4).fill(Color(.systemGray5))
            }
            if isToday {
                RoundedRectangle(cornerRadius: 4).stroke(.primary, lineWidth: 2)
            }
        }
        .frame(height: 28)
    }
}

struct CategoryProgressBar: View {
    let category: String
    let progress: Double
    let completed: Int
    let total: Int
    let color: Color

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(category).font(.subheadline.bold())
                Spacer()
                Text("\(completed)/\(total)").font(.caption).foregroundStyle(.secondary)
            }
            GeometryReader { geometry in
                ZStack(alignment: .leading) {
                    RoundedRectangle(cornerRadius: 4).fill(color.opacity(0.2)).frame(height: 8)
                    RoundedRectangle(cornerRadius: 4).fill(color).frame(width: geometry.size.width * progress, height: 8)
                }
            }
            .frame(height: 8)
        }
    }
}

struct ActivityRow: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: icon).font(.title2).foregroundStyle(color).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.subheadline)
                Text(subtitle).font(.caption).foregroundStyle(.secondary)
            }
            Spacer()
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    ProgressView()
        .modelContainer(for: [DailyProgress.self])
}
