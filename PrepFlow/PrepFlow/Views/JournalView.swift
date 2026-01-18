import SwiftUI
import SwiftData

struct JournalView: View {
    @Environment(\.modelContext) private var modelContext
    @Query(sort: \JournalEntry.date, order: .reverse) private var entries: [JournalEntry]
    @State private var showNewEntrySheet = false

    var body: some View {
        NavigationStack {
            Group {
                if entries.isEmpty {
                    emptyState
                } else {
                    journalList
                }
            }
            .navigationTitle("Journal")
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        showNewEntrySheet = true
                    } label: {
                        Image(systemName: "plus")
                    }
                }
            }
            .sheet(isPresented: $showNewEntrySheet) {
                JournalEntrySheet(category: .lld, topicTitle: "General")
            }
        }
    }

    private var emptyState: some View {
        VStack(spacing: 24) {
            Image(systemName: "pencil.and.scribble")
                .font(.system(size: 60))
                .foregroundStyle(.purple.opacity(0.6))

            VStack(spacing: 8) {
                Text("No Journal Entries Yet")
                    .font(.title2.bold())

                Text("Start journaling your learnings to track your progress and get AI feedback.")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
            }

            Button {
                showNewEntrySheet = true
            } label: {
                Label("Write First Entry", systemImage: "pencil")
                    .font(.headline)
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(.purple)
                    .foregroundStyle(.white)
                    .clipShape(Capsule())
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private var journalList: some View {
        List {
            ForEach(groupedEntries, id: \.key) { date, dayEntries in
                Section {
                    ForEach(dayEntries) { entry in
                        JournalEntryRow(entry: entry)
                    }
                } header: {
                    Text(date, format: .dateTime.month().day().year())
                }
            }
            .onDelete(perform: deleteEntries)
        }
        .listStyle(.insetGrouped)
    }

    private var groupedEntries: [(key: Date, value: [JournalEntry])] {
        let grouped = Dictionary(grouping: entries) { entry in
            Calendar.current.startOfDay(for: entry.date)
        }
        return grouped.sorted { $0.key > $1.key }
    }

    private func deleteEntries(at offsets: IndexSet) {
        // Implementation for delete
    }
}

struct JournalEntryRow: View {
    let entry: JournalEntry

    private var categoryColor: Color {
        switch entry.category {
        case "LLD": return .purple
        case "HLD": return .blue
        case "DSA": return .green
        default: return .gray
        }
    }

    var body: some View {
        NavigationLink {
            JournalEntryDetailView(entry: entry)
        } label: {
            VStack(alignment: .leading, spacing: 8) {
                HStack {
                    Text(entry.category)
                        .font(.caption.bold())
                        .foregroundStyle(categoryColor)
                        .padding(.horizontal, 8)
                        .padding(.vertical, 4)
                        .background(categoryColor.opacity(0.15))
                        .clipShape(Capsule())

                    Spacer()

                    if let score = entry.aiValidationScore {
                        HStack(spacing: 4) {
                            Image(systemName: "brain.head.profile")
                            Text("\(score)/10")
                        }
                        .font(.caption.bold())
                        .foregroundStyle(scoreColor(score))
                    }
                }

                Text(entry.content)
                    .font(.body)
                    .lineLimit(2)
                    .foregroundStyle(.primary)

                Text(entry.date, format: .dateTime.hour().minute())
                    .font(.caption)
                    .foregroundStyle(.secondary)
            }
            .padding(.vertical, 4)
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 8...10: return .green
        case 5...7: return .orange
        default: return .red
        }
    }
}

struct JournalEntryDetailView: View {
    let entry: JournalEntry

    private var categoryColor: Color {
        switch entry.category {
        case "LLD": return .purple
        case "HLD": return .blue
        case "DSA": return .green
        default: return .gray
        }
    }

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                VStack(alignment: .leading, spacing: 8) {
                    HStack {
                        Text(entry.category)
                            .font(.subheadline.bold())
                            .foregroundStyle(categoryColor)
                            .padding(.horizontal, 12)
                            .padding(.vertical, 6)
                            .background(categoryColor.opacity(0.15))
                            .clipShape(Capsule())

                        Spacer()

                        Text(entry.date, format: .dateTime.month().day().year())
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }

                VStack(alignment: .leading, spacing: 8) {
                    Text("Your Entry")
                        .font(.headline)

                    Text(entry.content)
                        .font(.body)
                        .lineSpacing(4)
                }

                if let score = entry.aiValidationScore {
                    aiValidationSection(score: score)
                }

                if !entry.followUpQuestions.isEmpty {
                    followUpSection
                }

                if !entry.knowledgeGaps.isEmpty {
                    knowledgeGapsSection
                }
            }
            .padding()
        }
        .navigationTitle("Journal Entry")
        .navigationBarTitleDisplayMode(.inline)
    }

    private func aiValidationSection(score: Int) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Validation")
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                    Text("\(score)/10")
                        .font(.title3.bold())
                }
                .foregroundStyle(scoreColor(score))
            }

            if let feedback = entry.aiFeedback {
                Text(feedback)
                    .font(.body)
                    .foregroundStyle(.secondary)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
        }
    }

    private var followUpSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Follow-up Questions")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(entry.followUpQuestions, id: \.self) { question in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "questionmark.circle.fill")
                            .foregroundStyle(.blue)
                        Text(question)
                            .font(.body)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var knowledgeGapsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Areas to Review")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                ForEach(entry.knowledgeGaps, id: \.self) { gap in
                    HStack(alignment: .top, spacing: 12) {
                        Image(systemName: "exclamationmark.triangle.fill")
                            .foregroundStyle(.orange)
                        Text(gap)
                            .font(.body)
                    }
                }
            }
            .padding()
            .background(Color(.systemGray6))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 8...10: return .green
        case 5...7: return .orange
        default: return .red
        }
    }
}

struct JournalEntrySheet: View {
    let category: TopicCategory
    let topicTitle: String

    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var modelContext
    @State private var content = ""
    @State private var isValidating = false
    @State private var validationResult: AIValidationResult?

    private var categoryColor: Color {
        switch category {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Journaling for")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)

                        HStack {
                            Label(category.rawValue, systemImage: category.icon)
                                .font(.headline)
                                .foregroundStyle(categoryColor)

                            Text("- \(topicTitle)")
                                .font(.headline)
                        }
                    }

                    promptsSection

                    VStack(alignment: .leading, spacing: 8) {
                        Text("Your Learnings")
                            .font(.headline)

                        TextEditor(text: $content)
                            .frame(minHeight: 200)
                            .padding(8)
                            .background(Color(.systemGray6))
                            .clipShape(RoundedRectangle(cornerRadius: 12))
                    }

                    if let result = validationResult {
                        validationResultSection(result)
                    }

                    actionsSection
                }
                .padding()
            }
            .navigationTitle("Journal Entry")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .topBarLeading) {
                    Button("Cancel") {
                        dismiss()
                    }
                }

                ToolbarItem(placement: .topBarTrailing) {
                    Button("Save") {
                        saveEntry()
                    }
                    .disabled(content.isEmpty)
                }
            }
        }
    }

    private var promptsSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Reflection Prompts")
                .font(.headline)

            VStack(alignment: .leading, spacing: 8) {
                PromptRow(text: "What are the key concepts you learned?")
                PromptRow(text: "Can you explain this to someone else?")
                PromptRow(text: "How would you apply this in a real project?")
                PromptRow(text: "What questions do you still have?")
            }
            .padding()
            .background(categoryColor.opacity(0.1))
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private func validationResultSection(_ result: AIValidationResult) -> some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("AI Feedback")
                    .font(.headline)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "brain.head.profile")
                    Text("\(result.score)/10")
                        .font(.title3.bold())
                }
                .foregroundStyle(scoreColor(result.score))
            }

            Text(result.feedback)
                .font(.body)
                .foregroundStyle(.secondary)
                .padding()
                .background(Color(.systemGray6))
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var actionsSection: some View {
        VStack(spacing: 12) {
            Button {
                validateWithAI()
            } label: {
                if isValidating {
                    ProgressView()
                        .tint(.white)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(categoryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                } else {
                    Label("Validate with AI", systemImage: "brain.head.profile")
                        .font(.headline)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(categoryColor.opacity(0.15))
                        .foregroundStyle(categoryColor)
                        .clipShape(RoundedRectangle(cornerRadius: 12))
                }
            }
            .disabled(content.isEmpty || isValidating)
        }
    }

    private func validateWithAI() {
        isValidating = true
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            validationResult = AIValidationResult(
                score: 7,
                feedback: "Good understanding of the core concepts! You've explained the fundamentals well. Consider adding more specific examples to strengthen your explanation.",
                followUpQuestions: [
                    "How would this pattern handle concurrent requests?",
                    "What are the trade-offs compared to alternative approaches?"
                ],
                knowledgeGaps: [
                    "Consider exploring thread safety implications"
                ]
            )
            isValidating = false
        }
    }

    private func saveEntry() {
        let entry = JournalEntry(
            date: Date(),
            category: category.rawValue,
            content: content,
            aiValidationScore: validationResult?.score,
            aiFeedback: validationResult?.feedback,
            followUpQuestions: validationResult?.followUpQuestions ?? [],
            knowledgeGaps: validationResult?.knowledgeGaps ?? []
        )
        modelContext.insert(entry)
        dismiss()
    }

    private func scoreColor(_ score: Int) -> Color {
        switch score {
        case 8...10: return .green
        case 5...7: return .orange
        default: return .red
        }
    }
}

struct PromptRow: View {
    let text: String

    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            Image(systemName: "lightbulb.fill")
                .foregroundStyle(.yellow)
                .font(.caption)
            Text(text)
                .font(.subheadline)
                .foregroundStyle(.secondary)
        }
    }
}

struct AIValidationResult {
    let score: Int
    let feedback: String
    let followUpQuestions: [String]
    let knowledgeGaps: [String]
}

#Preview {
    JournalView()
        .modelContainer(for: [JournalEntry.self])
}
