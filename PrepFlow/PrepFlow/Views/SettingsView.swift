import SwiftUI

struct SettingsView: View {
    @AppStorage("notificationsEnabled") private var notificationsEnabled = true
    @AppStorage("morningReminderTime") private var morningReminderTime = Date()
    @AppStorage("eveningJournalTime") private var eveningJournalTime = Date()
    @AppStorage("claudeAPIKey") private var claudeAPIKey = ""
    @AppStorage("currentWeek") private var currentWeek = 1
    @AppStorage("startDate") private var startDate = Date()

    @State private var showAPIKeyAlert = false
    @State private var showResetAlert = false

    var body: some View {
        NavigationStack {
            List {
                Section {
                    HStack {
                        Text("Current Week")
                        Spacer()
                        Text("Week \(currentWeek)").foregroundStyle(.secondary)
                    }
                    HStack {
                        Text("Started")
                        Spacer()
                        Text(startDate, format: .dateTime.month().day().year()).foregroundStyle(.secondary)
                    }
                    Button("Reset Progress") { showResetAlert = true }.foregroundStyle(.red)
                } header: { Text("Progress") }

                Section {
                    Toggle("Enable Notifications", isOn: $notificationsEnabled)
                    if notificationsEnabled {
                        DatePicker("Morning Reminder", selection: $morningReminderTime, displayedComponents: .hourAndMinute)
                        DatePicker("Evening Journal", selection: $eveningJournalTime, displayedComponents: .hourAndMinute)
                    }
                } header: { Text("Notifications") } footer: { Text("Get reminded to start your daily learning and journal your progress.") }

                Section {
                    HStack {
                        Text("Claude API Key")
                        Spacer()
                        Text(claudeAPIKey.isEmpty ? "Not Set" : "Set").foregroundStyle(.secondary)
                    }
                    .contentShape(Rectangle())
                    .onTapGesture { showAPIKeyAlert = true }

                    NavigationLink { AIPreferencesView() } label: { Text("AI Preferences") }
                } header: { Text("AI Integration") } footer: { Text("Get your API key from console.anthropic.com") }

                Section {
                    NavigationLink { ExportDataView() } label: { Label("Export Data", systemImage: "square.and.arrow.up") }
                    NavigationLink { ImportDataView() } label: { Label("Import Data", systemImage: "square.and.arrow.down") }
                } header: { Text("Data") }

                Section {
                    HStack {
                        Text("Version")
                        Spacer()
                        Text("1.0.0").foregroundStyle(.secondary)
                    }
                    NavigationLink { AboutView() } label: { Text("About PrepFlow") }
                } header: { Text("About") }
            }
            .navigationTitle("Settings")
            .alert("Enter API Key", isPresented: $showAPIKeyAlert) {
                TextField("sk-ant-...", text: $claudeAPIKey)
                Button("Save", action: {})
                Button("Cancel", role: .cancel, action: {})
            } message: { Text("Enter your Claude API key to enable AI features.") }
            .alert("Reset Progress", isPresented: $showResetAlert) {
                Button("Reset", role: .destructive) { resetProgress() }
                Button("Cancel", role: .cancel, action: {})
            } message: { Text("This will reset all your progress. This action cannot be undone.") }
        }
    }

    private func resetProgress() {
        currentWeek = 1
        startDate = Date()
    }
}

struct AIPreferencesView: View {
    @AppStorage("aiValidationStyle") private var validationStyle = "balanced"
    @AppStorage("aiQuizDifficulty") private var quizDifficulty = "medium"
    @AppStorage("aiFollowUpCount") private var followUpCount = 3

    var body: some View {
        List {
            Section {
                Picker("Feedback Style", selection: $validationStyle) {
                    Text("Encouraging").tag("encouraging")
                    Text("Balanced").tag("balanced")
                    Text("Critical").tag("critical")
                }
            } header: { Text("Validation Style") } footer: { Text("How the AI should provide feedback on your journal entries.") }

            Section {
                Picker("Difficulty", selection: $quizDifficulty) {
                    Text("Easy").tag("easy")
                    Text("Medium").tag("medium")
                    Text("Hard").tag("hard")
                }
                Stepper("Follow-up Questions: \(followUpCount)", value: $followUpCount, in: 1...5)
            } header: { Text("Quiz Settings") }
        }
        .navigationTitle("AI Preferences")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ExportDataView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.and.arrow.up").font(.system(size: 60)).foregroundStyle(.blue)
            Text("Export your data as JSON").font(.headline)
            Button { } label: {
                Label("Export", systemImage: "square.and.arrow.up").font(.headline).padding(.horizontal, 24).padding(.vertical, 12).background(.blue).foregroundStyle(.white).clipShape(Capsule())
            }
        }
        .navigationTitle("Export Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct ImportDataView: View {
    var body: some View {
        VStack(spacing: 24) {
            Image(systemName: "square.and.arrow.down").font(.system(size: 60)).foregroundStyle(.green)
            Text("Import data from a JSON file").font(.headline)
            Button { } label: {
                Label("Import", systemImage: "square.and.arrow.down").font(.headline).padding(.horizontal, 24).padding(.vertical, 12).background(.green).foregroundStyle(.white).clipShape(Capsule())
            }
        }
        .navigationTitle("Import Data")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct AboutView: View {
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                Image(systemName: "book.circle.fill").font(.system(size: 80)).foregroundStyle(.purple)
                Text("PrepFlow").font(.largeTitle.bold())
                Text("Your AI-powered interview preparation companion").font(.subheadline).foregroundStyle(.secondary).multilineTextAlignment(.center)
                VStack(alignment: .leading, spacing: 16) {
                    FeatureRow(icon: "calendar", title: "Daily Learning", description: "Structured curriculum for LLD, HLD, and DSA")
                    FeatureRow(icon: "pencil.and.scribble", title: "Journaling", description: "Reflect on your learnings daily")
                    FeatureRow(icon: "brain.head.profile", title: "AI Validation", description: "Get feedback from Claude AI")
                    FeatureRow(icon: "chart.line.uptrend.xyaxis", title: "Progress Tracking", description: "Visualize your journey")
                }
                .padding()
            }
            .padding()
        }
        .navigationTitle("About")
        .navigationBarTitleDisplayMode(.inline)
    }
}

struct FeatureRow: View {
    let icon: String
    let title: String
    let description: String

    var body: some View {
        HStack(spacing: 16) {
            Image(systemName: icon).font(.title2).foregroundStyle(.purple).frame(width: 32)
            VStack(alignment: .leading, spacing: 2) {
                Text(title).font(.headline)
                Text(description).font(.caption).foregroundStyle(.secondary)
            }
        }
    }
}

#Preview { SettingsView() }
