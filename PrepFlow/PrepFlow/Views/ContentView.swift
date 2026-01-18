import SwiftUI

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "sun.max.fill")
                }
                .tag(0)

            CurriculumView()
                .tabItem {
                    Label("Curriculum", systemImage: "book.fill")
                }
                .tag(1)

            JournalView()
                .tabItem {
                    Label("Journal", systemImage: "pencil.and.scribble")
                }
                .tag(2)

            ProgressView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(3)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(4)
        }
        .tint(.purple)
    }
}

#Preview {
    ContentView()
}
