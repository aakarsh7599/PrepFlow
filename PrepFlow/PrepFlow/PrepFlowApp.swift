import SwiftUI
import SwiftData

@main
struct PrepFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [Topic.self, DailyProgress.self, JournalEntry.self])
    }
}
