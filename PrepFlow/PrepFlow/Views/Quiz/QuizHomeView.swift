import SwiftUI
import SwiftData

struct QuizHomeView: View {
    @Environment(\.modelContext) private var modelContext
    @State private var selectedCategory: TopicCategoryType?
    @State private var showingQuiz = false
    @State private var isRandomMode = false
    @State private var questionCount = 5
    @State private var selectedTopic: String = ""

    // Animation states
    @State private var hasAppeared = false
    @State private var categoryCardsVisible = false
    @State private var optionsVisible = false
    @State private var historyVisible = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    categorySection
                    if selectedCategory != nil {
                        quizOptionsSection
                    }
                    recentQuizzesSection
                }
                .padding()
            }
            .background(Color(.systemGroupedBackground))
            .navigationTitle("AI Quiz")
            .sheet(isPresented: $showingQuiz) {
                if let category = selectedCategory {
                    NavigationStack {
                        AIQuizView(
                            category: category,
                            topicTitle: isRandomMode ? "Random \(category.rawValue)" : selectedTopic,
                            isRandomMode: isRandomMode,
                            questionCount: questionCount
                        )
                    }
                }
            }
            .onAppear {
                if !hasAppeared {
                    animateEntrance()
                    hasAppeared = true
                }
            }
        }
    }

    private func animateEntrance() {
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.1)) {
            categoryCardsVisible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.3)) {
            optionsVisible = true
        }
        withAnimation(.spring(response: 0.5, dampingFraction: 0.8).delay(0.5)) {
            historyVisible = true
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Test Your Knowledge")
                .font(.title2.bold())
            Text("Select a category and start a quiz to reinforce your learning.")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }

    // MARK: - Category Selection
    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Choose Category")
                .font(.headline)

            HStack(spacing: 12) {
                ForEach(Array(TopicCategoryType.allCases.enumerated()), id: \.element) { index, category in
                    CategoryCard(
                        category: category,
                        isSelected: selectedCategory == category
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            if selectedCategory == category {
                                selectedCategory = nil
                            } else {
                                selectedCategory = category
                                updateSelectedTopic(for: category)
                            }
                        }
                    }
                    .opacity(categoryCardsVisible ? 1 : 0)
                    .offset(y: categoryCardsVisible ? 0 : 20)
                    .animation(.spring(response: 0.5, dampingFraction: 0.8).delay(Double(index) * 0.1), value: categoryCardsVisible)
                }
            }
        }
    }

    // MARK: - Quiz Options
    private var quizOptionsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Quiz Options")
                .font(.headline)

            VStack(spacing: 12) {
                // Random mode toggle
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Random Questions")
                            .font(.subheadline.bold())
                        Text("Questions from any topic in this category")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Toggle("", isOn: $isRandomMode)
                        .labelsHidden()
                        .tint(selectedCategory?.color ?? .blue)
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Question count
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Number of Questions")
                            .font(.subheadline.bold())
                        Text("\(questionCount) questions")
                            .font(.caption)
                            .foregroundStyle(.secondary)
                    }
                    Spacer()
                    Stepper("", value: $questionCount, in: 3...10)
                        .labelsHidden()
                }
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))

                // Topic selection (if not random)
                if !isRandomMode, let category = selectedCategory {
                    topicPicker(for: category)
                }

                // Start button
                Button {
                    showingQuiz = true
                } label: {
                    HStack {
                        Image(systemName: "brain.head.profile")
                        Text("Start Quiz")
                    }
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(selectedCategory?.color ?? .blue)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
                }
                .disabled(!AIService.shared.isConfigured)

                if !AIService.shared.isConfigured {
                    Text("Configure API key in Settings to use AI Quiz")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
            }
        }
        .opacity(optionsVisible ? 1 : 0)
        .offset(y: optionsVisible ? 0 : 20)
    }

    private func topicPicker(for category: TopicCategoryType) -> some View {
        VStack(alignment: .leading, spacing: 8) {
            Text("Select Topic")
                .font(.subheadline.bold())

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(getTopicsForCategory(category), id: \.self) { topic in
                        Button {
                            selectedTopic = topic
                        } label: {
                            Text(topic)
                                .font(.caption)
                                .padding(.horizontal, 12)
                                .padding(.vertical, 8)
                                .background(selectedTopic == topic ? category.color : Color(.systemGray5))
                                .foregroundStyle(selectedTopic == topic ? .white : .primary)
                                .clipShape(Capsule())
                        }
                    }
                }
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    // MARK: - Recent Quizzes
    private var recentQuizzesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Recent Quizzes")
                .font(.headline)

            let recentSessions = QuizHistoryManager.shared.getRecentSessions(from: modelContext, limit: 5)

            if recentSessions.isEmpty {
                HStack {
                    Image(systemName: "brain.head.profile")
                        .foregroundStyle(.secondary)
                    Text("No quizzes yet. Start your first quiz!")
                        .foregroundStyle(.secondary)
                        .font(.subheadline)
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(.regularMaterial)
                .clipShape(RoundedRectangle(cornerRadius: 12))
            } else {
                VStack(spacing: 8) {
                    ForEach(recentSessions) { session in
                        RecentQuizRow(session: session)
                    }
                }
            }
        }
        .opacity(historyVisible ? 1 : 0)
        .offset(y: historyVisible ? 0 : 20)
    }

    // MARK: - Helpers
    private func getTopicsForCategory(_ category: TopicCategoryType) -> [String] {
        switch category {
        case .lld:
            return CurriculumData.lldTopics.flatMap { $0 }.map { $0.title }
        case .hld:
            return CurriculumData.hldTopics.flatMap { $0 }.map { $0.title }
        case .dsa:
            return CurriculumData.dsaTopics.flatMap { $0 }.map { $0.title }
        }
    }

    private func updateSelectedTopic(for category: TopicCategoryType) {
        let topics = getTopicsForCategory(category)
        selectedTopic = topics.first ?? ""
    }
}

// MARK: - Category Card
struct CategoryCard: View {
    let category: TopicCategoryType
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title2)
                    .foregroundStyle(isSelected ? .white : category.color)

                Text(category.rawValue)
                    .font(.caption.bold())
                    .foregroundStyle(isSelected ? .white : .primary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, 20)
            .background(isSelected ? category.color : Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(isSelected ? category.color : Color.clear, lineWidth: 2)
            )
        }
        .buttonStyle(.plain)
    }
}

// MARK: - Recent Quiz Row
struct RecentQuizRow: View {
    let session: QuizSession

    private var categoryColor: Color {
        session.categoryType?.color ?? .gray
    }

    var body: some View {
        HStack(spacing: 12) {
            // Category indicator
            Circle()
                .fill(categoryColor)
                .frame(width: 8, height: 8)

            VStack(alignment: .leading, spacing: 4) {
                Text(session.topicTitle ?? "Random \(session.category)")
                    .font(.subheadline.bold())
                    .lineLimit(1)

                Text(session.startedAt.formatted(.dateTime.month().day().hour().minute()))
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }

            Spacer()

            // Score
            VStack(alignment: .trailing, spacing: 2) {
                Text(String(format: "%.1f", session.averageScore))
                    .font(.headline.bold())
                    .foregroundStyle(scoreColor(session.averageScore))
                Text("/10")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
        }
        .padding()
        .background(.regularMaterial)
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func scoreColor(_ score: Double) -> Color {
        switch score {
        case 8...10: return .green
        case 5..<8: return .orange
        default: return .red
        }
    }
}

#Preview {
    QuizHomeView()
        .modelContainer(for: [QuizSession.self, QuizQuestionRecord.self])
}
