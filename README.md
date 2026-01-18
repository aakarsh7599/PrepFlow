# PrepFlow - Interview Prep Companion

A premium iOS app to guide your daily interview preparation with AI-powered learning validation.

## Features

- **Daily Learning Dashboard**: See today's LLD, HLD, and DSA topics with progress rings
- **Structured Curriculum**: 6-month comprehensive curriculum broken into daily chunks
- **Learning Journal**: Reflect on your learnings with guided prompts
- **AI Validation**: Get feedback from Claude AI on your understanding
- **iOS Widgets**: Small, medium, and large widgets for quick glance
- **Progress Tracking**: Streaks, completion stats, and activity calendar

## Getting Started

### Prerequisites

- macOS with Xcode 15.0+
- iOS 17.0+ device or simulator
- Claude API key (get from console.anthropic.com)

### Xcode Project Setup

Since this is a Swift project, you need to create the Xcode project:

1. **Open Xcode** and select "Create New Project"

2. **Choose template**:
   - Platform: iOS
   - Template: App
   - Click "Next"

3. **Configure project**:
   - Product Name: `PrepFlow`
   - Team: Your Apple Developer Team
   - Organization Identifier: `com.yourname` (or your identifier)
   - Interface: **SwiftUI**
   - Language: **Swift**
   - Storage: **SwiftData** (check this!)
   - Click "Next"

4. **Save location**: Choose your preferred directory and click "Create"

5. **Replace generated files**:
   - Delete the auto-generated `ContentView.swift` and `PrepFlowApp.swift`
   - Drag the files from `PrepFlow/` folder into Xcode

6. **Add Widget Extension**:
   - File > New > Target
   - Choose "Widget Extension"
   - Product Name: `PrepFlowWidget`
   - Uncheck "Include Configuration App Intent"
   - Click "Finish"
   - Replace the generated widget code with `Widgets/PrepFlowWidget.swift`

7. **Configure App Groups** (for widget data sharing):
   - Select your app target > Signing & Capabilities
   - Click "+ Capability" > App Groups
   - Add: `group.com.yourname.prepflow`
   - Repeat for Widget target

### Building & Running

1. Select your target device (iPhone simulator or physical device)
2. Press `Cmd + R` to build and run
3. The app should launch with the Today view

### Setting up AI Features

1. Go to Settings in the app
2. Enter your Claude API key
3. Now journaling will include AI validation

## Project Structure

```
PrepFlow/
├── PrepFlowApp.swift          # App entry point
├── Models/
│   └── Topic.swift            # Data models (SwiftData)
├── Views/
│   ├── ContentView.swift      # Main tab view
│   ├── TodayView.swift        # Daily dashboard
│   ├── CurriculumView.swift   # Browse all topics
│   ├── TopicDetailView.swift  # Topic details
│   ├── JournalView.swift      # Journal entries
│   ├── ProgressView.swift     # Stats & progress
│   ├── SettingsView.swift     # App settings
│   └── AIQuizView.swift       # AI-powered quiz
├── Services/
│   └── ClaudeService.swift    # Claude API integration
├── Resources/
│   └── CurriculumData.swift   # All curriculum content
└── Widgets/
    └── PrepFlowWidget.swift   # iOS widgets
```

## Curriculum Overview

### Low Level Design (LLD)
- Weeks 1-4: OOP, SOLID, Design Patterns
- Weeks 5-8: Classic LLD problems (Parking Lot, Elevator, etc.)
- Weeks 9-24: Advanced systems (LinkedIn, Uber, etc.)

### High Level Design (HLD)
- Weeks 1-4: Fundamentals, Scaling, Communication, Storage
- Weeks 5-8: URL Shortener, Rate Limiter, Twitter, Instagram
- Weeks 9-24: YouTube, WhatsApp, Uber, Search Engine

### Data Structures & Algorithms (DSA)
- Weeks 1-4: Arrays, Two Pointers, Sliding Window, Stack
- Weeks 5-8: Binary Search, Linked Lists, Trees
- Weeks 9-24: Graphs, DP, Backtracking, Advanced topics

## Daily Routine

1. **Morning**: Check widget for today's topics
2. **LLD Session** (1 hour): Study and practice
3. **HLD Session** (1 hour): Study and design
4. **DSA Session** (30-60 min): Solve daily problem
5. **Evening**: Journal learnings, get AI feedback

## Tech Stack
- Swift 5.9+ / SwiftUI
- SwiftData for persistence
- WidgetKit for iOS widgets
- Claude API for AI features
- MVVM Architecture

## Resources

- [SwiftUI Documentation](https://developer.apple.com/documentation/swiftui)
- [SwiftData Guide](https://developer.apple.com/documentation/swiftdata)
- [100 Days of SwiftUI](https://www.hackingwithswift.com/100/swiftui) - Great for beginners
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)

Good luck with your interview prep!
