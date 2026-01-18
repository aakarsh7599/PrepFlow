import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var modelContext
    @Query private var dailyProgress: [DailyProgress]
    @State private var currentDay: Int = 1
    @State private var currentWeek: Int = 1

    private var todayProgress: DailyProgress? {
        dailyProgress.first { Calendar.current.isDateInToday($0.date) }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    // Header with date and streak
                    headerSection

                    // Progress rings
                    progressRingsSection

                    // Today's topics
                    todayTopicsSection

                    // Quick actions
                    quickActionsSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("Today")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button(action: {}) {
                        Image(systemName: "bell.fill")
                            .foregroundStyle(.purple)
                    }
                }
            }
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        HStack {
            VStack(alignment: .leading, spacing: 4) {
                Text(Date(), format: .dateTime.weekday(.wide))
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                Text(Date(), format: .dateTime.month().day())
                    .font(.title.bold())
            }

            Spacer()

            // Streak badge
            HStack(spacing: 4) {
                Image(systemName: "flame.fill")
                    .foregroundStyle(.orange)
                Text("\(todayProgress?.streak ?? 0)")
                    .font(.title2.bold())
                Text("day streak")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.horizontal, 16)
            .padding(.vertical, 8)
            .background(.orange.opacity(0.15))
            .clipShape(Capsule())
        }
    }

    // MARK: - Progress Rings
    private var progressRingsSection: some View {
        VStack(spacing: 16) {
            Text("Today's Progress")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 24) {
                ProgressRing(
                    progress: todayProgress?.lldCompleted == true ? 1.0 : 0.0,
                    color: .purple,
                    label: "LLD",
                    icon: "cube.fill"
                )

                ProgressRing(
                    progress: todayProgress?.hldCompleted == true ? 1.0 : 0.0,
                    color: .blue,
                    label: "HLD",
                    icon: "cloud.fill"
                )

                ProgressRing(
                    progress: todayProgress?.dsaCompleted == true ? 1.0 : 0.0,
                    color: .green,
                    label: "DSA",
                    icon: "function"
                )
            }
            .padding()
            .background(.regularMaterial)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    // MARK: - Today's Topics
    private var todayTopicsSection: some View {
        VStack(spacing: 16) {
            Text("What You'll Learn Today")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            VStack(spacing: 12) {
                TopicCard(
                    category: .lld,
                    title: "OOP Fundamentals",
                    subtitle: "Classes, Objects, Encapsulation",
                    isCompleted: todayProgress?.lldCompleted ?? false,
                    week: currentWeek,
                    day: currentDay
                )

                TopicCard(
                    category: .hld,
                    title: "Client-Server Basics",
                    subtitle: "HTTP/HTTPS, Request-Response",
                    isCompleted: todayProgress?.hldCompleted ?? false,
                    week: currentWeek,
                    day: currentDay
                )

                TopicCard(
                    category: .dsa,
                    title: "Two Sum",
                    subtitle: "Arrays & Hashing Pattern",
                    isCompleted: todayProgress?.dsaCompleted ?? false,
                    week: currentWeek,
                    day: currentDay
                )
            }
        }
    }

    // MARK: - Quick Actions
    private var quickActionsSection: some View {
        VStack(spacing: 16) {
            Text("Quick Actions")
                .font(.headline)
                .frame(maxWidth: .infinity, alignment: .leading)

            HStack(spacing: 12) {
                QuickActionButton(
                    title: "Journal",
                    icon: "pencil.and.scribble",
                    color: .purple
                ) {
                    // Navigate to journal
                }

                QuickActionButton(
                    title: "AI Quiz",
                    icon: "brain.head.profile",
                    color: .blue
                ) {
                    // Start AI quiz
                }

                QuickActionButton(
                    title: "Resources",
                    icon: "link",
                    color: .green
                ) {
                    // Show resources
                }
            }
        }
    }
}

// MARK: - Progress Ring Component
struct ProgressRing: View {
    let progress: Double
    let color: Color
    let label: String
    let icon: String

    var body: some View {
        VStack(spacing: 8) {
            ZStack {
                Circle()
                    .stroke(color.opacity(0.2), lineWidth: 8)

                Circle()
                    .trim(from: 0, to: progress)
                    .stroke(color, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .rotationEffect(.degrees(-90))
                    .animation(.spring, value: progress)

                Image(systemName: progress >= 1.0 ? "checkmark" : icon)
                    .font(.title2)
                    .foregroundStyle(color)
            }
            .frame(width: 70, height: 70)

            Text(label)
                .font(.caption.bold())
                .foregroundStyle(.secondary)
        }
    }
}

// MARK: - Topic Card Component
struct TopicCard: View {
    let category: TopicCategory
    let title: String
    let subtitle: String
    let isCompleted: Bool
    let week: Int
    let day: Int

    private var categoryColor: Color {
        switch category {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    var body: some View {
        HStack(spacing: 16) {
            // Category indicator
            RoundedRectangle(cornerRadius: 4)
                .fill(categoryColor)
                .frame(width: 4)

            // Content
            VStack(alignment: .leading, spacing: 4) {
                HStack {
                    Text(category.rawValue)
                        .font(.caption.bold())
                        .foregroundStyle(categoryColor)

                    Text("Week \(week), Day \(day)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Text(title)
                    .font(.headline)

                Text(subtitle)
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Completion status
            Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                .font(.title2)
                .foregroundStyle(isCompleted ? categoryColor : .secondary)
        }
        .padding()
        .background(.background)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: .black.opacity(0.05), radius: 5, y: 2)
    }
}

// MARK: - Quick Action Button
struct QuickActionButton: View {
    let title: String
    let icon: String
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: icon)
                    .font(.title2)
                Text(title)
                    .font(.caption.bold())
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(color.opacity(0.15))
            .foregroundStyle(color)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }
}

#Preview {
    TodayView()
        .modelContainer(for: [Topic.self, DailyProgress.self, JournalEntry.self])
}
