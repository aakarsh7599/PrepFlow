import SwiftUI
import SwiftData

@main
struct PrepFlowApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
        .modelContainer(for: [
            DailyProgress.self,
            JournalEntry.self,
            TopicCompletion.self,
            QuizSession.self,
            QuizQuestionRecord.self
        ])
    }
}
