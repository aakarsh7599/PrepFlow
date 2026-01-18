import Foundation

// MARK: - Curriculum Data
struct CurriculumData {
    static let lldTopics: [[TopicData]] = [
        // Week 1: OOP & SOLID
        [
            TopicData(title: "OOP Fundamentals: Classes & Objects", day: 1, week: 1,
                     content: "Understanding classes, objects, and encapsulation",
                     subtopics: ["Classes vs Objects", "Encapsulation", "Access modifiers", "Constructors"]),
            TopicData(title: "Inheritance & Polymorphism", day: 2, week: 1,
                     content: "Learn how to extend classes and achieve runtime polymorphism",
                     subtopics: ["Inheritance types", "Method overriding", "Polymorphism", "Super keyword"]),
            TopicData(title: "Abstraction & Interfaces", day: 3, week: 1,
                     content: "Abstract classes vs interfaces and when to use each",
                     subtopics: ["Abstract classes", "Interfaces", "When to use which", "Diamond problem"]),
            TopicData(title: "SOLID: SRP & OCP", day: 4, week: 1,
                     content: "Single Responsibility and Open/Closed Principles",
                     subtopics: ["Single Responsibility", "Open/Closed Principle", "Code examples", "Refactoring tips"]),
            TopicData(title: "SOLID: LSP & ISP", day: 5, week: 1,
                     content: "Liskov Substitution and Interface Segregation",
                     subtopics: ["Liskov Substitution", "Interface Segregation", "Violations", "Best practices"]),
            TopicData(title: "SOLID: Dependency Inversion", day: 6, week: 1,
                     content: "Dependency Inversion Principle and DI patterns",
                     subtopics: ["Dependency Inversion", "Dependency Injection", "IoC containers", "Testing benefits"]),
            TopicData(title: "Week 1 Review", day: 7, week: 1,
                     content: "Consolidate OOP and SOLID concepts",
                     subtopics: ["Practice problems", "Common mistakes", "Interview questions"]),
        ],
        // Week 2: Creational Patterns
        [
            TopicData(title: "Factory Pattern", day: 1, week: 2,
                     content: "Simple Factory and Factory Method patterns",
                     subtopics: ["Simple Factory", "Factory Method", "When to use", "Implementation"]),
            TopicData(title: "Abstract Factory", day: 2, week: 2,
                     content: "Creating families of related objects",
                     subtopics: ["Abstract Factory", "Product families", "Real-world examples", "Comparison with Factory"]),
            TopicData(title: "Builder Pattern", day: 3, week: 2,
                     content: "Step-by-step object construction",
                     subtopics: ["Builder pattern", "Fluent interface", "Director class", "Immutable objects"]),
            TopicData(title: "Singleton Pattern", day: 4, week: 2,
                     content: "Ensuring single instance with global access",
                     subtopics: ["Singleton implementation", "Thread safety", "Lazy initialization", "Anti-pattern concerns"]),
            TopicData(title: "Prototype Pattern", day: 5, week: 2,
                     content: "Creating objects by cloning",
                     subtopics: ["Prototype pattern", "Deep vs shallow copy", "Clone registry", "Use cases"]),
            TopicData(title: "Creational Patterns Review", day: 6, week: 2,
                     content: "Compare and practice all creational patterns",
                     subtopics: ["Pattern comparison", "When to use which", "Combined patterns"]),
            TopicData(title: "Week 2 Review", day: 7, week: 2,
                     content: "Consolidate creational patterns",
                     subtopics: ["Practice problems", "Interview questions", "Real-world scenarios"]),
        ],
        // Week 3: Structural Patterns
        [
            TopicData(title: "Adapter Pattern", day: 1, week: 3,
                     content: "Making incompatible interfaces work together",
                     subtopics: ["Class adapter", "Object adapter", "Two-way adapter", "Real examples"]),
            TopicData(title: "Bridge Pattern", day: 2, week: 3,
                     content: "Separating abstraction from implementation",
                     subtopics: ["Bridge pattern", "Abstraction hierarchy", "Implementation hierarchy", "Use cases"]),
            TopicData(title: "Composite Pattern", day: 3, week: 3,
                     content: "Tree structures for part-whole hierarchies",
                     subtopics: ["Composite pattern", "Leaf vs Composite", "Recursive operations", "File system example"]),
            TopicData(title: "Decorator Pattern", day: 4, week: 3,
                     content: "Adding responsibilities dynamically",
                     subtopics: ["Decorator pattern", "Wrapping", "Stacking decorators", "vs Inheritance"]),
            TopicData(title: "Facade Pattern", day: 5, week: 3,
                     content: "Simplified interface to complex subsystems",
                     subtopics: ["Facade pattern", "Subsystem hiding", "API design", "Real examples"]),
            TopicData(title: "Proxy Pattern", day: 6, week: 3,
                     content: "Controlling access to objects",
                     subtopics: ["Virtual proxy", "Protection proxy", "Remote proxy", "Caching proxy"]),
            TopicData(title: "Week 3 Review", day: 7, week: 3,
                     content: "Consolidate structural patterns",
                     subtopics: ["Pattern comparison", "Combined patterns", "Interview questions"]),
        ],
        // Week 4: Behavioral Patterns Part 1
        [
            TopicData(title: "Observer Pattern", day: 1, week: 4,
                     content: "One-to-many dependency between objects",
                     subtopics: ["Observer pattern", "Subject/Observer", "Push vs Pull", "Event systems"]),
            TopicData(title: "Strategy Pattern", day: 2, week: 4,
                     content: "Encapsulating interchangeable algorithms",
                     subtopics: ["Strategy pattern", "Context class", "Runtime switching", "vs State pattern"]),
            TopicData(title: "Command Pattern", day: 3, week: 4,
                     content: "Encapsulating requests as objects",
                     subtopics: ["Command pattern", "Invoker/Receiver", "Undo/Redo", "Macro commands"]),
            TopicData(title: "State Pattern", day: 4, week: 4,
                     content: "State-dependent behavior changes",
                     subtopics: ["State pattern", "State transitions", "Context class", "vs Strategy"]),
            TopicData(title: "Template Method", day: 5, week: 4,
                     content: "Defining algorithm skeleton",
                     subtopics: ["Template method", "Hook methods", "Hollywood Principle", "vs Strategy"]),
            TopicData(title: "Chain of Responsibility", day: 6, week: 4,
                     content: "Passing requests along a chain",
                     subtopics: ["Chain of Responsibility", "Handler interface", "Middleware example", "Logging example"]),
            TopicData(title: "Month 1 Review", day: 7, week: 4,
                     content: "Comprehensive month 1 review",
                     subtopics: ["All patterns review", "Practice problems", "Mock interview prep"]),
        ],
    ]

    static let hldTopics: [[TopicData]] = [
        // Week 1: Fundamentals
        [
            TopicData(title: "Client-Server Architecture", day: 1, week: 1,
                     content: "Understanding basic web architecture",
                     subtopics: ["Client-server model", "HTTP/HTTPS", "Request-response cycle", "Stateless vs Stateful"]),
            TopicData(title: "REST API Design", day: 2, week: 1,
                     content: "Designing RESTful APIs",
                     subtopics: ["REST principles", "HTTP methods", "Status codes", "API versioning"]),
            TopicData(title: "Database Fundamentals", day: 3, week: 1,
                     content: "SQL vs NoSQL databases",
                     subtopics: ["Relational DBs", "NoSQL types", "When to use which", "ACID properties"]),
            TopicData(title: "CAP Theorem", day: 4, week: 1,
                     content: "Understanding distributed system trade-offs",
                     subtopics: ["Consistency", "Availability", "Partition tolerance", "Real-world examples"]),
            TopicData(title: "ACID vs BASE", day: 5, week: 1,
                     content: "Transaction models comparison",
                     subtopics: ["ACID properties", "BASE properties", "Eventual consistency", "Use cases"]),
            TopicData(title: "Scaling Basics", day: 6, week: 1,
                     content: "Vertical vs Horizontal scaling",
                     subtopics: ["Vertical scaling", "Horizontal scaling", "Trade-offs", "When to scale"]),
            TopicData(title: "Week 1 Review", day: 7, week: 1,
                     content: "Consolidate fundamentals",
                     subtopics: ["Concept review", "Practice questions", "System design framework"]),
        ],
        // Week 2: Scaling Techniques
        [
            TopicData(title: "Load Balancing", day: 1, week: 2,
                     content: "Distributing traffic across servers",
                     subtopics: ["Load balancer types", "Round Robin", "Health checks", "Session persistence"]),
            TopicData(title: "Caching Strategies", day: 2, week: 2,
                     content: "Cache patterns and strategies",
                     subtopics: ["Cache-aside", "Write-through", "Write-back", "Cache invalidation"]),
            TopicData(title: "CDN & Edge Computing", day: 3, week: 2,
                     content: "Content delivery networks",
                     subtopics: ["CDN basics", "Edge locations", "Cache headers", "Static vs Dynamic"]),
            TopicData(title: "Database Replication", day: 4, week: 2,
                     content: "Scaling reads with replicas",
                     subtopics: ["Master-slave", "Master-master", "Replication lag", "Failover"]),
            TopicData(title: "Database Sharding", day: 5, week: 2,
                     content: "Horizontal partitioning strategies",
                     subtopics: ["Sharding strategies", "Shard key", "Cross-shard queries", "Resharding"]),
            TopicData(title: "Consistent Hashing", day: 6, week: 2,
                     content: "Distributed data partitioning",
                     subtopics: ["Hash ring", "Virtual nodes", "Adding/removing nodes", "Use cases"]),
            TopicData(title: "Week 2 Review", day: 7, week: 2,
                     content: "Consolidate scaling techniques",
                     subtopics: ["Technique comparison", "Combined approaches", "Interview questions"]),
        ],
        // Week 3-4 abbreviated for brevity
        [
            TopicData(title: "Sync vs Async Communication", day: 1, week: 3, content: "Communication patterns", subtopics: []),
            TopicData(title: "Message Queues", day: 2, week: 3, content: "Async messaging", subtopics: []),
            TopicData(title: "Pub/Sub Pattern", day: 3, week: 3, content: "Event broadcasting", subtopics: []),
            TopicData(title: "WebSockets & SSE", day: 4, week: 3, content: "Real-time communication", subtopics: []),
            TopicData(title: "gRPC & Protocol Buffers", day: 5, week: 3, content: "High-performance RPC", subtopics: []),
            TopicData(title: "API Gateway", day: 6, week: 3, content: "Centralized API management", subtopics: []),
            TopicData(title: "Week 3 Review", day: 7, week: 3, content: "Communication patterns review", subtopics: []),
        ],
        [
            TopicData(title: "Rate Limiting", day: 1, week: 4, content: "Protecting systems from overload", subtopics: []),
            TopicData(title: "Circuit Breaker", day: 2, week: 4, content: "Handling cascading failures", subtopics: []),
            TopicData(title: "Retry & Timeout", day: 3, week: 4, content: "Handling transient failures", subtopics: []),
            TopicData(title: "Data Replication", day: 4, week: 4, content: "Durability and availability", subtopics: []),
            TopicData(title: "Monitoring & Alerting", day: 5, week: 4, content: "Observability", subtopics: []),
            TopicData(title: "Disaster Recovery", day: 6, week: 4, content: "Plan for failure", subtopics: []),
            TopicData(title: "Month 1 HLD Review", day: 7, week: 4, content: "Comprehensive review", subtopics: []),
        ],
    ]

    static let dsaTopics: [[TopicData]] = [
        // Week 1: Arrays & Hashing
        [
            TopicData(title: "Two Sum", day: 1, week: 1, content: "Hash map for complement lookup", subtopics: ["Hash map", "Time: O(n)", "Space: O(n)"]),
            TopicData(title: "Contains Duplicate", day: 2, week: 1, content: "Set for duplicate detection", subtopics: ["Set", "Sorting approach", "Time: O(n)"]),
            TopicData(title: "Valid Anagram", day: 3, week: 1, content: "Character frequency counting", subtopics: ["Hash map", "Array counting", "Unicode handling"]),
            TopicData(title: "Group Anagrams", day: 4, week: 1, content: "Grouping by sorted key", subtopics: ["Sorted key", "Character count key", "Time: O(n*k)"]),
            TopicData(title: "Top K Frequent Elements", day: 5, week: 1, content: "Bucket sort or heap", subtopics: ["Bucket sort", "Heap approach", "Time: O(n)"]),
            TopicData(title: "Product of Array Except Self", day: 6, week: 1, content: "Prefix and suffix products", subtopics: ["Prefix product", "Suffix product", "Space: O(1)"]),
            TopicData(title: "Valid Sudoku", day: 7, week: 1, content: "Set-based validation", subtopics: ["Row/Col/Box sets", "Time: O(81)", "Space: O(81)"]),
        ],
        // Week 2: Two Pointers
        [
            TopicData(title: "Valid Palindrome", day: 1, week: 2, content: "Two pointers from ends", subtopics: ["Two pointers", "Character filtering", "Time: O(n)"]),
            TopicData(title: "Two Sum II (Sorted)", day: 2, week: 2, content: "Two pointers on sorted array", subtopics: ["Two pointers", "Sorted input", "Space: O(1)"]),
            TopicData(title: "3Sum", day: 3, week: 2, content: "Fix one, two-pointer rest", subtopics: ["Sort first", "Skip duplicates", "Time: O(n^2)"]),
            TopicData(title: "Container With Most Water", day: 4, week: 2, content: "Maximize area with two pointers", subtopics: ["Greedy approach", "Move shorter pointer", "Time: O(n)"]),
            TopicData(title: "Trapping Rain Water", day: 5, week: 2, content: "Track max heights from both sides", subtopics: ["Two pointers", "Max tracking", "Time: O(n)"]),
            TopicData(title: "Move Zeroes", day: 6, week: 2, content: "Two pointers for in-place swap", subtopics: ["In-place", "Maintain order", "Time: O(n)"]),
            TopicData(title: "Remove Duplicates", day: 7, week: 2, content: "Slow-fast pointer technique", subtopics: ["Slow-fast pointers", "In-place", "Time: O(n)"]),
        ],
        // Week 3: Sliding Window
        [
            TopicData(title: "Best Time to Buy Stock", day: 1, week: 3, content: "Track minimum and max profit", subtopics: ["Single pass", "Track min", "Time: O(n)"]),
            TopicData(title: "Longest Substring No Repeat", day: 2, week: 3, content: "Sliding window with set", subtopics: ["Sliding window", "Hash set", "Time: O(n)"]),
            TopicData(title: "Longest Repeating Replacement", day: 3, week: 3, content: "Window with max frequency", subtopics: ["Sliding window", "Max frequency", "Time: O(n)"]),
            TopicData(title: "Permutation in String", day: 4, week: 3, content: "Fixed-size sliding window", subtopics: ["Fixed window", "Character count", "Time: O(n)"]),
            TopicData(title: "Minimum Window Substring", day: 5, week: 3, content: "Variable window with hash map", subtopics: ["Variable window", "Two pointers", "Time: O(n)"]),
            TopicData(title: "Max Consecutive Ones III", day: 6, week: 3, content: "Sliding window with flip count", subtopics: ["Sliding window", "Flip tracking", "Time: O(n)"]),
            TopicData(title: "Fruit Into Baskets", day: 7, week: 3, content: "Max window with K distinct", subtopics: ["Sliding window", "Hash map", "Time: O(n)"]),
        ],
        // Week 4: Stack
        [
            TopicData(title: "Valid Parentheses", day: 1, week: 4, content: "Stack for matching brackets", subtopics: ["Stack", "Hash map for pairs", "Time: O(n)"]),
            TopicData(title: "Min Stack", day: 2, week: 4, content: "Track minimum in O(1)", subtopics: ["Auxiliary stack", "Track min", "Space: O(n)"]),
            TopicData(title: "Evaluate RPN", day: 3, week: 4, content: "Stack-based expression evaluation", subtopics: ["Stack", "Operator handling", "Time: O(n)"]),
            TopicData(title: "Generate Parentheses", day: 4, week: 4, content: "Backtracking with validity check", subtopics: ["Backtracking", "Valid combinations", "Catalan number"]),
            TopicData(title: "Daily Temperatures", day: 5, week: 4, content: "Monotonic decreasing stack", subtopics: ["Monotonic stack", "Index tracking", "Time: O(n)"]),
            TopicData(title: "Car Fleet", day: 6, week: 4, content: "Stack with arrival times", subtopics: ["Sort by position", "Stack", "Time: O(n log n)"]),
            TopicData(title: "Largest Rectangle Histogram", day: 7, week: 4, content: "Monotonic stack for boundaries", subtopics: ["Monotonic stack", "Left/right bounds", "Time: O(n)"]),
        ],
    ]
}

// MARK: - Topic Data Structure
struct TopicData {
    let title: String
    let day: Int
    let week: Int
    let content: String
    let subtopics: [String]
    var resources: [String] = []
}
