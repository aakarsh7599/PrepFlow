import SwiftUI
import SwiftData
import Charts

struct QuizAnalyticsView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedTimeframe: AnalyticsTimeframe = .week
    @State private var selectedCategory: TopicCategoryType?

    // Animation states
    @State private var hasAppeared = false
    @State private var statsVisible = false
    @State private var chartVisible = false
    @State private var weakAreasVisible = false

    enum AnalyticsTimeframe: String, CaseIterable {
        case week = "Week"
        case month = "Month"
        case all = "All Time"
    }

    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                timeframePicker
                categoryFilter
                overallStatsSection
                scoreTrendChart
                categoryBreakdown
                weakAreasSection
            }
            .padding()
        }
        .background(Color(.systemGroupedBackground))
        .navigationTitle("Quiz Analytics")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            if !hasAppeared {
                animateEntrance()
                hasAppeared = true
            }
        }
    }

    private func animateEntrance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
            statsVisible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            chartVisible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
            weakAreasVisible = true
        }
    }

    // MARK: - Timeframe Picker
    private var timeframePicker: some View {
        Picker("Timeframe", selection: $selectedTimeframe) {
            ForEach(AnalyticsTimeframe.allCases, id: \.self) { timeframe in
                Text(timeframe.rawValue).tag(timeframe)
            }
        }
        .pickerStyle(.segmented)
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", isSelected: selectedCategory == nil) {
                    selectedCategory = nil
                }

                ForEach(TopicCategoryType.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: category.color
                    ) {
                        selectedCategory = category
                    }
                }
            }
        }
    }

    // MARK: - Overall Stats
    private var overallStatsSection: some View {
        let stats = QuizHistoryManager.shared.getOverallStats(from: modelContext)

        return VStack(alignment: .leading, spacing: 16) {
            Text("Overall Performance")
                .font(.headline)

            HStack(spacing: 16) {
                AnalyticsStatCard(
                    title: "Total Quizzes",
                    value: "\(stats.totalQuizzes)",
                    icon: "brain.head.profile",
                    color: .purple
                )

                AnalyticsStatCard(
                    title: "Avg Score",
                    value: stats.formattedAverageScore,
                    icon: "star.fill",
                    color: .orange
                )

                AnalyticsStatCard(
                    title: "Questions",
                    value: "\(stats.totalQuestions)",
                    icon: "questionmark.circle.fill",
                    color: .blue
                )
            }
        }
        .opacity(statsVisible ? 1 : 0)
        .offset(y: statsVisible ? 0 : 20)
    }

    // MARK: - Score Trend Chart
    private var scoreTrendChart: some View {
        let trendData = QuizHistoryManager.shared.getImprovementTrend(
            from: modelContext,
            category: selectedCategory?.rawValue
        )

        return VStack(alignment: .leading, spacing: 16) {
            Text("Score Trend")
                .font(.headline)

            if trendData.count >= 2 {
                Chart {
                    ForEach(Array(trendData.enumerated()), id: \.offset) { index, score in
                        LineMark(
                            x: .value("Quiz", index + 1),
                            y: .value("Score", score)
                        )
                        .foregroundStyle(selectedCategory?.color ?? .purple)
                        .interpolationMethod(.catmullRom)

                        PointMark(
                            x: .value("Quiz", index + 1),
                            y: .value("Score", score)
                        )
                        .foregroundStyle(selectedCategory?.color ?? .purple)
                    }

                    RuleMark(y: .value("Target", 7))
                        .foregroundStyle(.green.opacity(0.5))
                        .lineStyle(StrokeStyle(lineWidth: 1, dash: [5]))
                        .annotation(position: .top, alignment: .trailing) {
                            Text("Target")
                                .font(.caption2)
                                .foregroundStyle(.green)
                        }
                }
                .chartYScale(domain: 0...10)
                .chartYAxis {
                    AxisMarks(values: [0, 2, 4, 6, 8, 10])
                }
                .frame(height: 200)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                HStack {
                    Image(systemName: "chart.line.uptrend.xyaxis")
                        .foregroundStyle(.secondary)
                    Text("Complete more quizzes to see trends")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
        }
        .opacity(chartVisible ? 1 : 0)
        .offset(y: chartVisible ? 0 : 20)
    }

    // MARK: - Category Breakdown
    private var categoryBreakdown: some View {
        let categoryStats = QuizHistoryManager.shared.getCategoryStats(from: modelContext)

        return VStack(alignment: .leading, spacing: 16) {
            Text("Category Performance")
                .font(.headline)

            VStack(spacing: 12) {
                ForEach(categoryStats) { stat in
                    CategoryStatRow(stat: stat)
                }
            }
        }
        .opacity(chartVisible ? 1 : 0)
        .offset(y: chartVisible ? 0 : 20)
    }

    // MARK: - Weak Areas
    private var weakAreasSection: some View {
        let weakAreas = QuizHistoryManager.shared.getWeakAreas(
            from: modelContext,
            category: selectedCategory?.rawValue
        )

        return VStack(alignment: .leading, spacing: 16) {
            HStack {
                Text("Areas to Improve")
                    .font(.headline)
                Spacer()
                if !weakAreas.isEmpty {
                    Text("\(weakAreas.count) areas")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }
            }

            if weakAreas.isEmpty {
                HStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                    Text("No weak areas identified yet. Keep practicing!")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            } else {
                VStack(spacing: 8) {
                    ForEach(weakAreas.prefix(5)) { area in
                        WeakAreaRow(area: area)
                    }
                }
            }
        }
        .opacity(weakAreasVisible ? 1 : 0)
        .offset(y: weakAreasVisible ? 0 : 20)
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    var color: Color = .purple
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.caption.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : Color(.systemGray5))
                .foregroundStyle(isSelected ? .white : .primary)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Analytics Stat Card
struct AnalyticsStatCard: View {
    let title: String
    let value: String
    let icon: String
    let color: Color

    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.title3)
                .foregroundStyle(color)

            Text(value)
                .font(.title2.bold())

            Text(title)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Category Stat Row
struct CategoryStatRow: View {
    let stat: CategoryStats

    var body: some View {
        HStack(spacing: 16) {
            // Category indicator
            Circle()
                .fill(stat.category.color)
                .frame(width: 12, height: 12)

            VStack(alignment: .leading, spacing: 4) {
                Text(stat.category.rawValue)
                    .font(.subheadline.bold())

                Text("\(stat.quizCount) quizzes")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Score with trend
            HStack(spacing: 8) {
                VStack(alignment: .trailing, spacing: 2) {
                    Text(String(format: "%.1f", stat.averageScore))
                        .font(.headline.bold())
                    Text("avg")
                        .font(.caption2)
                        .foregroundStyle(.secondary)
                }

                Image(systemName: stat.trend.icon)
                    .foregroundStyle(stat.trend.color)
                    .font(.caption)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

// MARK: - Weak Area Row
struct WeakAreaRow: View {
    let area: WeakArea

    private var categoryColor: Color {
        TopicCategoryType(rawValue: area.category)?.color ?? .gray
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text(area.topic)
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "exclamationmark.triangle.fill")
                        .foregroundStyle(.orange)
                        .font(.caption)
                    Text(String(format: "%.1f", area.averageScore))
                        .font(.caption.bold())
                        .foregroundStyle(.orange)
                }
            }

            if !area.missedConcepts.isEmpty {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Commonly missed:")
                        .font(.caption2)
                        .foregroundStyle(.secondary)

                    ForEach(area.missedConcepts.prefix(2), id: \.self) { concept in
                        HStack(spacing: 4) {
                            Circle()
                                .fill(.orange.opacity(0.5))
                                .frame(width: 4, height: 4)
                            Text(concept)
                                .font(.caption)
                                .foregroundStyle(.secondary)
                                .lineLimit(1)
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }
}

#Preview {
    NavigationStack {
        QuizAnalyticsView()
    }
    .modelContainer(for: [QuizSession.self, QuizQuestionRecord.self])
}
