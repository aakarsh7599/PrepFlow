# PrepFlow - Feature List

## Core Features

### 1. Daily Learning System
- **Structured 6-month (24-week) curriculum** covering:
  - Low Level Design (LLD): OOP, SOLID, Design Patterns
  - High Level Design (HLD): System Design, Scalability, Distributed Systems
  - Data Structures & Algorithms (DSA): Arrays, Trees, Graphs, Dynamic Programming
- **Daily topic tracking** with completion status
- **Week/Day navigation** throughout the curriculum
- **Progress persistence** using SwiftData

### 2. AI-Powered Quiz System
- **Dynamic question generation** using Claude or OpenAI
- **Speech-to-text input** for verbal answers
- **Real-time answer evaluation** with:
  - Score (1-10 scale)
  - Detailed feedback
  - Points covered well
  - Areas for improvement
- **Quiz history and analytics**
- **Performance tracking** per category and topic
- **Weak areas identification**

### 3. Journal System
- **Daily journal entries** for each topic
- **AI validation** of journal content
- **Knowledge gap identification**
- **Follow-up questions** for deeper learning
- **Journal history** with search and filtering

### 4. Progress Tracking
- **Streak tracking** with visual calendar
- **Category breakdown** (LLD/HLD/DSA)
- **Recent activity feed**
- **Quiz performance analytics** with Charts
- **Trend analysis** (improving/declining/stable)

### 5. iOS Widgets
- **Small widget**: Daily progress circles
- **Medium widget**: Today's topics with completion
- **Lock screen widgets**:
  - Circular gauge (completion percentage)
  - Rectangular (week/day info + progress)
  - Inline (quick status)

### 6. Settings & Customization
- **Appearance modes**: System/Light/Dark
- **AI provider selection**: Claude or OpenAI
- **API key management** with secure entry
- **Notification settings** for reminders
- **Progress reset** option
- **Data export/import** (coming soon)

## Technical Features

### Architecture
- **SwiftUI** for modern declarative UI
- **SwiftData** for persistence
- **MVVM architecture** pattern
- **Async/await** for API calls
- **Combine** for reactive updates

### UI/UX
- **Smooth animations** throughout
- **Confetti celebration** on completing all daily topics
- **Staggered entrance animations**
- **Bounce and pulse effects**
- **Loading states** with shimmer effects

### AI Integration
- **Claude API** (Anthropic)
- **OpenAI API** (GPT-4)
- **Graceful fallbacks** on API errors
- **Response parsing** with JSON extraction

### Widget System
- **App Group** for data sharing
- **WidgetKit** integration
- **Timeline-based updates** (30-minute refresh)
- **Multiple widget families** support

## Curriculum Overview

### Month 1-2: Foundations
- OOP fundamentals
- SOLID principles
- Basic design patterns
- System design basics
- Arrays, hashing, two pointers

### Month 3-4: Intermediate
- Advanced design patterns
- Distributed systems
- Trees, graphs, binary search
- Dynamic programming basics

### Month 5-6: Advanced
- System design case studies
- Advanced algorithms
- Interview practice
- Comprehensive reviews

## Getting Started

1. Open the app and start with Week 1, Day 1
2. Study today's LLD, HLD, and DSA topics
3. Mark topics complete as you finish them
4. Write journal entries to reinforce learning
5. Take AI quizzes to test your understanding
6. Track your progress and maintain your streak!

---

*Built with SwiftUI & SwiftData for iOS 17+*
