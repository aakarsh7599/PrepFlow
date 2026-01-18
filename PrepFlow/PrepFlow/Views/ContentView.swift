import SwiftUI
import SwiftData

struct ContentView: View {
    @State private var selectedTab = 0
    @AppStorage("appearanceMode") private var appearanceMode = "system"

    private var colorScheme: ColorScheme? {
        switch appearanceMode {
        case "light": return .light
        case "dark": return .dark
        default: return nil
        }
    }

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

            QuizHomeView()
                .tabItem {
                    Label("Quiz", systemImage: "brain.head.profile")
                }
                .tag(3)

            ProgressTabView()
                .tabItem {
                    Label("Progress", systemImage: "chart.line.uptrend.xyaxis")
                }
                .tag(4)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                }
                .tag(5)
        }
        .tint(.purple)
        .preferredColorScheme(colorScheme)
    }
}

// MARK: - Appearance Mode
enum AppearanceMode: String, CaseIterable {
    case system = "System"
    case light = "Light"
    case dark = "Dark"
    
    var icon: String {
        switch self {
        case .system: return "gear"
        case .light: return "sun.max.fill"
        case .dark: return "moon.fill"
        }
    }
}

// MARK: - Celebration Overlay
struct CelebrationOverlayModifier: ViewModifier {
    @Binding var isActive: Bool
    
    func body(content: Content) -> some View {
        content
            .overlay {
                if isActive {
                    ConfettiView()
                        .allowsHitTesting(false)
                        .onAppear {
                            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                                isActive = false
                            }
                        }
                }
            }
    }
}

extension View {
    func celebrationOverlay(isActive: Binding<Bool>) -> some View {
        modifier(CelebrationOverlayModifier(isActive: isActive))
    }
}

#Preview {
    ContentView()
        .modelContainer(for: [DailyProgress.self, JournalEntry.self, TopicCompletion.self, QuizSession.self, QuizQuestionRecord.self])
}
