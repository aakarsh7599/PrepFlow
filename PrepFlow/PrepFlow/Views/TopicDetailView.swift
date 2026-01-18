import SwiftUI

struct TopicDetailView: View {
    let category: TopicCategory
    let title: String
    let week: Int
    let day: Int

    @State private var isCompleted = false
    @State private var showJournalSheet = false
    @State private var showAIQuiz = false

    private var categoryColor: Color {
        switch category {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                // Header
                headerSection

                // Learning objectives
                objectivesSection

                // Content
                contentSection

                // Subtopics checklist
                subtopicsSection

                // Resources
                resourcesSection

                // Actions
                actionsSection
            }
            .padding()
        }
        .navigationTitle(title)
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .topBarTrailing) {
                Button {
                    withAnimation {
                        isCompleted.toggle()
                    }
                } label: {
                    Image(systemName: isCompleted ? "checkmark.circle.fill" : "circle")
                        .foregroundStyle(isCompleted ? .green : .secondary)
                }
            }
        }
        .sheet(isPresented: $showJournalSheet) {
            JournalEntrySheet(category: category, topicTitle: title)
        }
        .sheet(isPresented: $showAIQuiz) {
            AIQuizView(category: category, topicTitle: title)
        }
    }

    // MARK: - Header Section
    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Label(category.rawValue, systemImage: category.icon)
                    .font(.subheadline.bold())
                    .foregroundStyle(categoryColor)
                    .padding(.horizontal, 12)
                    .padding(.vertical, 6)
                    .background(categoryColor.opacity(0.15))
                    .clipShape(Capsule())

                Spacer()

                Text("Week \(week), Day \(day)")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
            }

            Text(title)
                .font(.title.bold())

            Text("Estimated time: 1 hour")
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }

    // MARK: - Objectives Section
    private var objectivesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Learning Objectives")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ObjectiveRow(text: "Understand the core concepts")
                ObjectiveRow(text: "Be able to explain with examples")
                ObjectiveRow(text: "Apply in a real-world scenario")
                ObjectiveRow(text: "Identify common pitfalls")
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    // MARK: - Content Section
    private var contentSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Overview")
                .font(.headline)

            Text(getContentOverview())
                .font(.body)
                .foregroundStyle(.secondary)
                .lineSpacing(4)
        }
    }

    // MARK: - Subtopics Section
    private var subtopicsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Topics to Cover")
                .font(.headline)

            VStack(spacing: 8) {
                ForEach(getSubtopics(), id: \.self) { subtopic in
                    SubtopicRow(title: subtopic)
                }
            }
        }
    }

    // MARK: - Resources Section
    private var resourcesSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Resources")
                .font(.headline)

            VStack(spacing: 8) {
                ResourceLink(title: "Video Tutorial", icon: "play.circle.fill", color: .red)
                ResourceLink(title: "Documentation", icon: "doc.text.fill", color: .blue)
                ResourceLink(title: "Practice Problems", icon: "list.bullet.clipboard.fill", color: .green)
            }
        }
    }

    // MARK: - Actions Section
    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                showJournalSheet = true
            } label: {
                Label("Write Journal Entry", systemImage: "pencil.and.scribble")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(categoryColor)
                    .foregroundStyle(.white)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }

            Button {
                showAIQuiz = true
            } label: {
                Label("Test Your Knowledge", systemImage: "brain.head.profile")
                    .font(.headline)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(categoryColor.opacity(0.15))
                    .foregroundStyle(categoryColor)
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
        .padding(.top, 8)
    }

    // MARK: - Helpers
    private func getContentOverview() -> String {
        return "This topic covers the fundamental concepts that every software engineer should know. You'll learn the theory, see practical examples, and understand how to apply these concepts in real-world scenarios. Take your time to understand each concept deeply before moving on."
    }

    private func getSubtopics() -> [String] {
        return [
            "Introduction and key concepts",
            "Core principles and theory",
            "Practical examples",
            "Common use cases",
            "Best practices and pitfalls",
            "Interview questions"
        ]
    }
}

// MARK: - Supporting Views
struct ObjectiveRow: View {
    let text: String

    var body: some View {
        HStack(spacing: 12) {
            Image(systemName: "target")
                .foregroundStyle(.orange)
            Text(text)
                .font(.subheadline)
        }
    }
}

struct SubtopicRow: View {
    let title: String
    @State private var isChecked = false

    var body: some View {
        Button {
            withAnimation {
                isChecked.toggle()
            }
        } label: {
            HStack(spacing: 12) {
                Image(systemName: isChecked ? "checkmark.square.fill" : "square")
                    .foregroundStyle(isChecked ? .green : .secondary)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)
                    .strikethrough(isChecked)

                Spacer()
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

struct ResourceLink: View {
    let title: String
    let icon: String
    let color: Color

    var body: some View {
        Button {
            // Open resource
        } label: {
            HStack(spacing: 12) {
                Image(systemName: icon)
                    .foregroundStyle(color)

                Text(title)
                    .font(.body)
                    .foregroundStyle(.primary)

                Spacer()

                Image(systemName: "arrow.up.right")
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 8))
        }
    }
}

#Preview {
    NavigationStack {
        TopicDetailView(category: .lld, title: "OOP Fundamentals", week: 1, day: 1)
    }
}
