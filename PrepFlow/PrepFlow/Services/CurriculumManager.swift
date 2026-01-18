import Foundation
import SwiftUI
import Combine

// MARK: - Curriculum Manager
class CurriculumManager: ObservableObject {
    static let shared = CurriculumManager()

    @Published var currentWeek: Int = 1
    @Published var currentDay: Int = 1

    private var startDate: Date {
        get { UserDefaults.standard.object(forKey: "startDate") as? Date ?? Date() }
        set { UserDefaults.standard.set(newValue, forKey: "startDate") }
    }

    private init() {
        let savedWeek = UserDefaults.standard.integer(forKey: "currentWeek")
        let savedDay = UserDefaults.standard.integer(forKey: "currentDay")
        currentWeek = savedWeek > 0 ? savedWeek : 1
        currentDay = savedDay > 0 ? savedDay : 1
        updateCurrentDay()
    }

    func saveProgress() {
        UserDefaults.standard.set(currentWeek, forKey: "currentWeek")
        UserDefaults.standard.set(currentDay, forKey: "currentDay")
    }

    func updateCurrentDay() {
        let calendar = Calendar.current
        let daysSinceStart = calendar.dateComponents([.day], from: startDate, to: Date()).day ?? 0

        if daysSinceStart >= 0 {
            let totalDays = daysSinceStart + 1
            currentWeek = ((totalDays - 1) / 7) + 1
            currentDay = ((totalDays - 1) % 7) + 1

            // Cap at 24 weeks
            if currentWeek > 24 {
                currentWeek = 24
                currentDay = 7
            }
        }
    }

    // MARK: - Get Today's Topics
    func getTodayLLD() -> CurriculumTopic {
        return getLLDTopic(week: currentWeek, day: currentDay)
    }

    func getTodayHLD() -> CurriculumTopic {
        return getHLDTopic(week: currentWeek, day: currentDay)
    }

    func getTodayDSA() -> CurriculumTopic {
        return getDSATopic(week: currentWeek, day: currentDay)
    }

    // MARK: - Get Specific Topics
    func getLLDTopic(week: Int, day: Int) -> CurriculumTopic {
        let weekIndex = min(week - 1, CurriculumContent.lldWeeks.count - 1)
        let dayIndex = min(day - 1, 6)

        guard weekIndex >= 0, weekIndex < CurriculumContent.lldWeeks.count else {
            return CurriculumTopic.placeholder(category: .lld)
        }

        let weekTopics = CurriculumContent.lldWeeks[weekIndex]
        guard dayIndex >= 0, dayIndex < weekTopics.count else {
            return CurriculumTopic.placeholder(category: .lld)
        }

        return weekTopics[dayIndex]
    }

    func getHLDTopic(week: Int, day: Int) -> CurriculumTopic {
        let weekIndex = min(week - 1, CurriculumContent.hldWeeks.count - 1)
        let dayIndex = min(day - 1, 6)

        guard weekIndex >= 0, weekIndex < CurriculumContent.hldWeeks.count else {
            return CurriculumTopic.placeholder(category: .hld)
        }

        let weekTopics = CurriculumContent.hldWeeks[weekIndex]
        guard dayIndex >= 0, dayIndex < weekTopics.count else {
            return CurriculumTopic.placeholder(category: .hld)
        }

        return weekTopics[dayIndex]
    }

    func getDSATopic(week: Int, day: Int) -> CurriculumTopic {
        let weekIndex = min(week - 1, CurriculumContent.dsaWeeks.count - 1)
        let dayIndex = min(day - 1, 6)

        guard weekIndex >= 0, weekIndex < CurriculumContent.dsaWeeks.count else {
            return CurriculumTopic.placeholder(category: .dsa)
        }

        let weekTopics = CurriculumContent.dsaWeeks[weekIndex]
        guard dayIndex >= 0, dayIndex < weekTopics.count else {
            return CurriculumTopic.placeholder(category: .dsa)
        }

        return weekTopics[dayIndex]
    }

    // MARK: - Get Week Overview
    func getWeekTopics(week: Int) -> (lld: [CurriculumTopic], hld: [CurriculumTopic], dsa: [CurriculumTopic]) {
        let weekIndex = week - 1

        let lld = weekIndex < CurriculumContent.lldWeeks.count ? CurriculumContent.lldWeeks[weekIndex] : []
        let hld = weekIndex < CurriculumContent.hldWeeks.count ? CurriculumContent.hldWeeks[weekIndex] : []
        let dsa = weekIndex < CurriculumContent.dsaWeeks.count ? CurriculumContent.dsaWeeks[weekIndex] : []

        return (lld, hld, dsa)
    }

    // MARK: - Progress
    func advanceDay() {
        if currentDay < 7 {
            currentDay += 1
        } else if currentWeek < 24 {
            currentWeek += 1
            currentDay = 1
        }
    }

    func resetProgress() {
        currentWeek = 1
        currentDay = 1
        startDate = Date()
    }
}

// MARK: - Curriculum Topic Model
struct CurriculumTopic: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let category: TopicCategoryType
    let week: Int
    let day: Int
    let content: String
    let learningObjectives: [String]
    let keyPoints: [String]
    let resources: [TopicResource]
    let estimatedMinutes: Int

    static func placeholder(category: TopicCategoryType) -> CurriculumTopic {
        CurriculumTopic(
            title: "Coming Soon",
            subtitle: "Content being prepared",
            category: category,
            week: 0,
            day: 0,
            content: "This topic is being prepared.",
            learningObjectives: [],
            keyPoints: [],
            resources: [],
            estimatedMinutes: 60
        )
    }
}

enum TopicCategoryType: String, CaseIterable {
    case lld = "LLD"
    case hld = "HLD"
    case dsa = "DSA"

    var color: Color {
        switch self {
        case .lld: return .purple
        case .hld: return .blue
        case .dsa: return .green
        }
    }

    var icon: String {
        switch self {
        case .lld: return "cube.fill"
        case .hld: return "cloud.fill"
        case .dsa: return "function"
        }
    }

    var fullName: String {
        switch self {
        case .lld: return "Low Level Design"
        case .hld: return "High Level Design"
        case .dsa: return "Data Structures & Algorithms"
        }
    }
}

struct TopicResource: Identifiable {
    let id = UUID()
    let title: String
    let type: ResourceType
    let url: String?

    enum ResourceType {
        case video, article, practice, book

        var icon: String {
            switch self {
            case .video: return "play.circle.fill"
            case .article: return "doc.text.fill"
            case .practice: return "list.bullet.clipboard.fill"
            case .book: return "book.fill"
            }
        }

        var color: Color {
            switch self {
            case .video: return .red
            case .article: return .blue
            case .practice: return .green
            case .book: return .orange
            }
        }
    }
}

// MARK: - Curriculum Content
struct CurriculumContent {
    // MARK: - LLD Weeks
    static let lldWeeks: [[CurriculumTopic]] = [
        // Week 1: OOP & SOLID Foundations
        [
            CurriculumTopic(
                title: "OOP Fundamentals",
                subtitle: "Classes, Objects, Encapsulation",
                category: .lld, week: 1, day: 1,
                content: "Object-Oriented Programming (OOP) is a programming paradigm based on the concept of objects that contain data and code.",
                learningObjectives: ["Understand classes and objects", "Apply encapsulation", "Use access modifiers"],
                keyPoints: ["Classes are blueprints", "Objects are instances", "Encapsulation hides details"],
                resources: [TopicResource(title: "OOP Concepts Video", type: .video, url: nil)],
                estimatedMinutes: 60
            ),
            CurriculumTopic(title: "Inheritance & Polymorphism", subtitle: "Code reuse and flexibility", category: .lld, week: 1, day: 2, content: "Learn inheritance and polymorphism.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Abstraction & Interfaces", subtitle: "Contracts and implementations", category: .lld, week: 1, day: 3, content: "Abstract classes vs interfaces.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "SOLID: SRP & OCP", subtitle: "Single Responsibility & Open/Closed", category: .lld, week: 1, day: 4, content: "First two SOLID principles.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "SOLID: LSP & ISP", subtitle: "Liskov & Interface Segregation", category: .lld, week: 1, day: 5, content: "LSP and ISP principles.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "SOLID: Dependency Inversion", subtitle: "Depend on abstractions", category: .lld, week: 1, day: 6, content: "DIP and dependency injection.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Week 1 Review", subtitle: "Consolidate OOP & SOLID", category: .lld, week: 1, day: 7, content: "Review all concepts.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ],
        // Week 2-4 abbreviated
        [
            CurriculumTopic(title: "Factory Pattern", subtitle: "Object creation", category: .lld, week: 2, day: 1, content: "Factory patterns.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Abstract Factory", subtitle: "Product families", category: .lld, week: 2, day: 2, content: "Abstract factory.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Builder Pattern", subtitle: "Step-by-step construction", category: .lld, week: 2, day: 3, content: "Builder pattern.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Singleton Pattern", subtitle: "Single instance", category: .lld, week: 2, day: 4, content: "Singleton.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Prototype Pattern", subtitle: "Clone objects", category: .lld, week: 2, day: 5, content: "Prototype.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Creational Patterns Review", subtitle: "Compare patterns", category: .lld, week: 2, day: 6, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Week 2 Practice", subtitle: "Apply patterns", category: .lld, week: 2, day: 7, content: "Practice.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ],
        [
            CurriculumTopic(title: "Adapter Pattern", subtitle: "Interface compatibility", category: .lld, week: 3, day: 1, content: "Adapter.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Bridge Pattern", subtitle: "Separate abstraction", category: .lld, week: 3, day: 2, content: "Bridge.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Composite Pattern", subtitle: "Tree structures", category: .lld, week: 3, day: 3, content: "Composite.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Decorator Pattern", subtitle: "Dynamic behavior", category: .lld, week: 3, day: 4, content: "Decorator.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Facade Pattern", subtitle: "Simplified interface", category: .lld, week: 3, day: 5, content: "Facade.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Proxy Pattern", subtitle: "Access control", category: .lld, week: 3, day: 6, content: "Proxy.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Week 3 Review", subtitle: "Structural patterns", category: .lld, week: 3, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ],
        [
            CurriculumTopic(title: "Observer Pattern", subtitle: "Event notification", category: .lld, week: 4, day: 1, content: "Observer.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Strategy Pattern", subtitle: "Interchangeable algorithms", category: .lld, week: 4, day: 2, content: "Strategy.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Command Pattern", subtitle: "Encapsulate requests", category: .lld, week: 4, day: 3, content: "Command.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "State Pattern", subtitle: "State-dependent behavior", category: .lld, week: 4, day: 4, content: "State.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Template Method", subtitle: "Algorithm skeleton", category: .lld, week: 4, day: 5, content: "Template.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Chain of Responsibility", subtitle: "Request chain", category: .lld, week: 4, day: 6, content: "Chain.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Month 1 Review", subtitle: "All patterns", category: .lld, week: 4, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ]
    ]

    // MARK: - HLD Weeks
    static let hldWeeks: [[CurriculumTopic]] = [
        [
            CurriculumTopic(title: "Client-Server Architecture", subtitle: "HTTP basics", category: .hld, week: 1, day: 1, content: "Client-server model.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "REST API Design", subtitle: "RESTful principles", category: .hld, week: 1, day: 2, content: "REST APIs.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Database Fundamentals", subtitle: "SQL vs NoSQL", category: .hld, week: 1, day: 3, content: "Databases.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "CAP Theorem", subtitle: "Distributed trade-offs", category: .hld, week: 1, day: 4, content: "CAP.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "ACID vs BASE", subtitle: "Transaction models", category: .hld, week: 1, day: 5, content: "ACID BASE.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Scaling Basics", subtitle: "Vertical vs Horizontal", category: .hld, week: 1, day: 6, content: "Scaling.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Week 1 Review", subtitle: "Fundamentals", category: .hld, week: 1, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ],
        [
            CurriculumTopic(title: "Load Balancing", subtitle: "Traffic distribution", category: .hld, week: 2, day: 1, content: "Load balancing.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Caching Strategies", subtitle: "Speed up access", category: .hld, week: 2, day: 2, content: "Caching.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "CDN & Edge", subtitle: "Content delivery", category: .hld, week: 2, day: 3, content: "CDN.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Database Replication", subtitle: "Read scaling", category: .hld, week: 2, day: 4, content: "Replication.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Database Sharding", subtitle: "Write scaling", category: .hld, week: 2, day: 5, content: "Sharding.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Consistent Hashing", subtitle: "Data distribution", category: .hld, week: 2, day: 6, content: "Hashing.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Week 2 Review", subtitle: "Scaling techniques", category: .hld, week: 2, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ],
        [
            CurriculumTopic(title: "Sync vs Async", subtitle: "Communication patterns", category: .hld, week: 3, day: 1, content: "Communication.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Message Queues", subtitle: "Async messaging", category: .hld, week: 3, day: 2, content: "Queues.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Pub/Sub Pattern", subtitle: "Event broadcasting", category: .hld, week: 3, day: 3, content: "Pub/Sub.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "WebSockets & SSE", subtitle: "Real-time", category: .hld, week: 3, day: 4, content: "WebSockets.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "gRPC", subtitle: "High-performance RPC", category: .hld, week: 3, day: 5, content: "gRPC.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "API Gateway", subtitle: "Central entry point", category: .hld, week: 3, day: 6, content: "Gateway.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Week 3 Review", subtitle: "Communication", category: .hld, week: 3, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ],
        [
            CurriculumTopic(title: "Rate Limiting", subtitle: "Protect systems", category: .hld, week: 4, day: 1, content: "Rate limiting.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Circuit Breaker", subtitle: "Fail fast", category: .hld, week: 4, day: 2, content: "Circuit breaker.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Retry & Timeout", subtitle: "Handle failures", category: .hld, week: 4, day: 3, content: "Retry.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Data Replication", subtitle: "Durability", category: .hld, week: 4, day: 4, content: "Replication.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Monitoring & Alerting", subtitle: "Observability", category: .hld, week: 4, day: 5, content: "Monitoring.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Disaster Recovery", subtitle: "Plan for failure", category: .hld, week: 4, day: 6, content: "DR.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Month 1 HLD Review", subtitle: "Complete review", category: .hld, week: 4, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ]
    ]

    // MARK: - DSA Weeks
    static let dsaWeeks: [[CurriculumTopic]] = [
        [
            CurriculumTopic(title: "Two Sum", subtitle: "Hash map lookup", category: .dsa, week: 1, day: 1, content: "Two Sum problem.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Contains Duplicate", subtitle: "Set detection", category: .dsa, week: 1, day: 2, content: "Contains Duplicate.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "Valid Anagram", subtitle: "Character counting", category: .dsa, week: 1, day: 3, content: "Valid Anagram.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "Group Anagrams", subtitle: "Hash by sorted key", category: .dsa, week: 1, day: 4, content: "Group Anagrams.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Top K Frequent", subtitle: "Bucket sort or heap", category: .dsa, week: 1, day: 5, content: "Top K.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Product Except Self", subtitle: "Prefix/suffix products", category: .dsa, week: 1, day: 6, content: "Product.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Valid Sudoku", subtitle: "Set validation", category: .dsa, week: 1, day: 7, content: "Sudoku.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45)
        ],
        [
            CurriculumTopic(title: "Valid Palindrome", subtitle: "Two pointers", category: .dsa, week: 2, day: 1, content: "Palindrome.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "Two Sum II", subtitle: "Sorted array", category: .dsa, week: 2, day: 2, content: "Two Sum II.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "3Sum", subtitle: "Fix one, two-pointer rest", category: .dsa, week: 2, day: 3, content: "3Sum.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Container With Most Water", subtitle: "Maximize area", category: .dsa, week: 2, day: 4, content: "Container.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Trapping Rain Water", subtitle: "Track max heights", category: .dsa, week: 2, day: 5, content: "Rain Water.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Move Zeroes", subtitle: "In-place swap", category: .dsa, week: 2, day: 6, content: "Move Zeroes.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "Two Pointers Review", subtitle: "Pattern practice", category: .dsa, week: 2, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45)
        ],
        [
            CurriculumTopic(title: "Best Time to Buy Stock", subtitle: "Track minimum", category: .dsa, week: 3, day: 1, content: "Stock.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "Longest Substring No Repeat", subtitle: "Sliding window", category: .dsa, week: 3, day: 2, content: "Substring.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Longest Repeating Replacement", subtitle: "Max frequency", category: .dsa, week: 3, day: 3, content: "Replacement.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Permutation in String", subtitle: "Fixed window", category: .dsa, week: 3, day: 4, content: "Permutation.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Minimum Window Substring", subtitle: "Variable window", category: .dsa, week: 3, day: 5, content: "Window.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Sliding Window Maximum", subtitle: "Monotonic deque", category: .dsa, week: 3, day: 6, content: "Maximum.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Sliding Window Review", subtitle: "Pattern mastery", category: .dsa, week: 3, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45)
        ],
        [
            CurriculumTopic(title: "Valid Parentheses", subtitle: "Stack matching", category: .dsa, week: 4, day: 1, content: "Parentheses.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 30),
            CurriculumTopic(title: "Min Stack", subtitle: "O(1) minimum", category: .dsa, week: 4, day: 2, content: "Min Stack.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Evaluate RPN", subtitle: "Stack evaluation", category: .dsa, week: 4, day: 3, content: "RPN.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Generate Parentheses", subtitle: "Backtracking", category: .dsa, week: 4, day: 4, content: "Generate.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Daily Temperatures", subtitle: "Monotonic stack", category: .dsa, week: 4, day: 5, content: "Temperatures.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 45),
            CurriculumTopic(title: "Largest Rectangle", subtitle: "Stack for boundaries", category: .dsa, week: 4, day: 6, content: "Rectangle.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60),
            CurriculumTopic(title: "Month 1 DSA Review", subtitle: "All patterns", category: .dsa, week: 4, day: 7, content: "Review.", learningObjectives: [], keyPoints: [], resources: [], estimatedMinutes: 60)
        ]
    ]
}

// MARK: - Widget Data Manager (from App side)
class WidgetDataManager {
    static let shared = WidgetDataManager()
    private let groupIdentifier = "group.prepflow.shared"
    private let widgetDataKey = "widgetData"
    private let userDefaults: UserDefaults?

    private init() {
        userDefaults = UserDefaults(suiteName: groupIdentifier)
    }

    func updateFromAppState(
        lldTopic: CurriculumTopic,
        hldTopic: CurriculumTopic,
        dsaTopic: CurriculumTopic,
        lldCompleted: Bool,
        hldCompleted: Bool,
        dsaCompleted: Bool,
        currentStreak: Int,
        totalDaysCompleted: Int,
        currentWeek: Int,
        currentDay: Int
    ) {
        // Save to shared UserDefaults for widget
        // This is handled by WidgetKit when the app updates the shared container
    }
}
