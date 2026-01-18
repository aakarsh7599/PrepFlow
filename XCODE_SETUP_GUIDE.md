# Xcode Setup Guide for PrepFlow

## After Xcode Installs

### Step 1: First Launch
1. Open Xcode from Applications
2. Accept the license agreement
3. Wait for "Installing components" to finish (2-3 min)

### Step 2: Create New Project
1. Click **"Create New Project"** (or File > New > Project)
2. Select:
   - Platform: **iOS** (top tabs)
   - Template: **App**
   - Click **Next**

### Step 3: Configure Project
Fill in these fields:
| Field | Value |
|-------|-------|
| Product Name | `PrepFlow` |
| Team | Your Apple ID (or "None" for now) |
| Organization Identifier | `com.yourname` |
| Interface | **SwiftUI** |
| Language | **Swift** |
| Storage | **SwiftData** (CHECK THIS!) |

Click **Next**

### Step 4: Save Location
1. Navigate to your preferred directory
2. Uncheck "Create Git repository" (optional)
3. Click **Create**

### Step 5: Delete Generated Files
In the left sidebar (Project Navigator), you'll see:
```
PrepFlow/
├── PrepFlowApp.swift      ← DELETE THIS
├── ContentView.swift      ← DELETE THIS
├── Assets.xcassets        ← KEEP
└── Preview Content/       ← KEEP
```

Right-click each file to delete → "Move to Trash"

### Step 6: Add Our Files
1. Clone this repository or download the source files

2. You'll see these folders:
   - Models/
   - Views/
   - Services/
   - Resources/
   - Widgets/
   - PrepFlowApp.swift

3. **Drag ALL these into Xcode's left sidebar** (under the PrepFlow folder)

4. When prompted:
   - Copy items if needed
   - Create folder references
   - Target: PrepFlow
   - Click **Finish**

### Step 7: Build & Run
1. Select a simulator: **iPhone 15 Pro** (top toolbar dropdown)
2. Press **Cmd + R** (or click the Play button)
3. Wait for build (first time takes 1-2 min)
4. App launches in simulator!

### Step 8: Add Widget (Optional, do later)
1. File > New > Target
2. Search for "Widget Extension"
3. Name it: `PrepFlowWidget`
4. Uncheck "Include Configuration App Intent"
5. Click Finish
6. Replace generated code with our widget code

---

## Troubleshooting

### "No team" error
- Go to: Xcode > Settings > Accounts
- Click "+" and sign in with Apple ID
- Come back to project, select your team

### "Module not found" errors
- Clean build: **Cmd + Shift + K**
- Build again: **Cmd + B**

### SwiftData not available
- Make sure you checked "Storage: SwiftData" when creating project
- Or add manually: File > Add Package > Search "SwiftData"

### Simulator won't launch
- Try: Device > Erase All Content and Settings
- Or select different simulator

---

## Xcode Keyboard Shortcuts

| Shortcut | Action |
|----------|--------|
| Cmd + R | Run app |
| Cmd + B | Build only |
| Cmd + . | Stop running |
| Cmd + Shift + K | Clean build |
| Cmd + 0 | Toggle Navigator (left panel) |
| Cmd + Option + Enter | Toggle Preview |
| Cmd + Click | Jump to definition |

---

## Project Structure After Setup

Your Xcode sidebar should look like:
```
PrepFlow
├── PrepFlowApp.swift
├── Models
│   └── Topic.swift
├── Views
│   ├── ContentView.swift
│   ├── TodayView.swift
│   ├── CurriculumView.swift
│   ├── TopicDetailView.swift
│   ├── JournalView.swift
│   ├── ProgressView.swift
│   ├── SettingsView.swift
│   └── AIQuizView.swift
├── Services
│   └── ClaudeService.swift
├── Resources
│   └── CurriculumData.swift
├── Widgets
│   └── PrepFlowWidget.swift
├── Assets.xcassets
└── Preview Content
```

---

## Next: Start Learning!

Once the app runs:
1. Explore each tab
2. Go to Settings and add your Claude API key
3. Start with Day 1 curriculum
4. Journal your learnings!
