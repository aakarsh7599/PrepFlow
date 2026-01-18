import SwiftUI
import SwiftData

struct CurriculumView: View {
    @State private var selectedCategory: TopicCategory? = nil
    @State private var selectedWeek: Int = 1
    @State private var searchText = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                // Category filter
                categoryFilter

                // Week selector
                weekSelector

                // Topics list
                topicsList
            }
            .navigationTitle("Curriculum")
            .searchable(text: $searchText, prompt: "Search topics...")
        }
    }

    // MARK: - Category Filter
    private var categoryFilter: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 12) {
                FilterChip(
                    title: "All",
                    isSelected: selectedCategory == nil,
                    color: .gray
                ) {
                    selectedCategory = nil
                }

                ForEach(TopicCategory.allCases, id: \.self) { category in
                    FilterChip(
                        title: category.rawValue,
                        isSelected: selectedCategory == category,
                        color: colorFor(category)
                    ) {
                        selectedCategory = category
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 12)
        }
        .background(.bar)
    }

    // MARK: - Week Selector
    private var weekSelector: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                ForEach(1...24, id: \.self) { week in
                    Button {
                        withAnimation {
                            selectedWeek = week
                        }
                    } label: {
                        Text("Week \(week)")
                            .font(.subheadline.bold())
                            .padding(.horizontal, 16)
                            .padding(.vertical, 8)
                            .background(selectedWeek == week ? Color.purple : Color.clear)
                            .foregroundStyle(selectedWeek == week ? .white : .primary)
                            .clipShape(Capsule())
                            .overlay {
                                if selectedWeek != week {
                                    Capsule()
                                        .stroke(Color.secondary.opacity(0.3), lineWidth: 1)
                                }
                            }
                    }
                }
            }
            .padding(.horizontal)
            .padding(.vertical, 8)
        }
    }

    // MARK: - Topics List
    private var topicsList: some View {
        List {
            Section("Week \(selectedWeek) - LLD") {
                ForEach(1...7, id: \.self) { day in
                    CurriculumTopicRow(
                        category: .lld,
                        title: lldTopicForDay(day),
                        week: selectedWeek,
                        day: day,
                        isCompleted: false
                    )
                }
            }

            Section("Week \(selectedWeek) - HLD") {
                ForEach(1...7, id: \.self) { day in
                    CurriculumTopicRow(
                        category: .hld,
                        title: hldTopicForDay(day),
                        week: selectedWeek,
                        day: day,
                        isCompleted: false
                    )
                }
            }

            Section("Week \(selectedWeek) - DSA") {
                ForEach(1...7, id: \.self) { day in
                    CurriculumTopicRow(
                        category: .dsa,
                        title: dsaTopicForDay(day),
                        week: selectedWeek,
                        day: day,
                        isCompleted: false
                    )
                }
            }
        }
        .listStyle(.insetGrouped)
    }

    // MARK: - Helpers
    private func colorFor(_ category: TopicCategory) -> Color {
        switch category {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    // Placeholder topic names - will be replaced with real data
    private func lldTopicForDay(_ day: Int) -> String {
        let topics = [
            "OOP Fundamentals",
            "Inheritance & Polymorphism",
            "SOLID Principles",
            "Factory Pattern",
            "Builder Pattern",
            "Singleton Pattern",
            "Review & Practice"
        ]
        return topics[(day - 1) % topics.count]
    }

    private func hldTopicForDay(_ day: Int) -> String {
        let topics = [
            "Client-Server Architecture",
            "REST API Design",
            "Database Fundamentals",
            "CAP Theorem",
            "Scaling Basics",
            "Load Balancing",
            "Review & Practice"
        ]
        return topics[(day - 1) % topics.count]
    }

    private func dsaTopicForDay(_ day: Int) -> String {
        let topics = [
            "Two Sum",
            "Contains Duplicate",
            "Valid Anagram",
            "Group Anagrams",
            "Top K Frequent",
            "Product of Array",
            "Valid Sudoku"
        ]
        return topics[(day - 1) % topics.count]
    }
}

// MARK: - Filter Chip
struct FilterChip: View {
    let title: String
    let isSelected: Bool
    let color: Color
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.subheadline.bold())
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(isSelected ? color : color.opacity(0.15))
                .foregroundStyle(isSelected ? .white : color)
                .clipShape(Capsule())
        }
    }
}

// MARK: - Curriculum Topic Row
struct CurriculumTopicRow: View {
    let category: TopicCategory
    let title: String
    let week: Int
    let day: Int
    let isCompleted: Bool

    private var categoryColor: Color {
        switch category {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    var body: some View {
        NavigationLink {
            TopicDetailView(category: category, title: title, week: week, day: day)
        } label: {
            HStack(spacing: 12) {
                Image(systemName: category.icon)
                    .font(.title3)
                    .foregroundStyle(categoryColor)
                    .frame(width: 32)

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.body)

                    Text("Day \(day)")
                        .font(.caption)
                        .foregroundStyle(.secondary)
                }

                Spacer()

                if isCompleted {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundStyle(.green)
                }
            }
        }
    }
}

#Preview {
    CurriculumView()
}
