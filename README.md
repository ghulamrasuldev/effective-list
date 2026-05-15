# Effective List

**A minimal todo app designed to get shit done.**

Most todo apps drown you in features, notifications, and noise. Effective List is different. It's a brutalist, no-nonsense tool built on one principle: **plan less, do more**.

---

## The Philosophy

### No Noise. No Fluff. Just Tasks.

We built Effective List because we were tired of todo apps that demand hours of setup, force complex project hierarchies, and interrupt you with reminders you didn't ask for. This app respects your time.

### The Core Loop

1. **Dump everything** into List — brain-dump without thinking about timing
2. **Plan tomorrow tonight** — pick what to tackle from your list
3. **Execute today** — focus only on what's scheduled, nothing else
4. **Repeat** — daily rhythm, not overwhelming systems

### Design Decisions

- **White background everywhere** — no dark mode distraction, clean focus
- **Red accent (#FF4D4D)** — urgency without aggression
- **Duration-first thinking** — every task has a time estimate because time is finite
- **Four time buckets** — Quick Wins (< 5m), Short Tasks (< 15m), Medium Tasks (< 1h), Long Tasks (4h+) — prevents overthinking task size
- **No subtasks** — if it needs subtasks, it's a project, not a todo
- **No due dates** — you pick when to do it, not an arbitrary deadline
- **Widget shows today only** — keeps you honest about what's actually today

---

## App Structure

### Today
Your command center for the day. Shows only tasks scheduled for today with a progress ring. Complete tasks by tapping the circle. Move to tomorrow if needed. The progress ring shows exactly how much you've crushed it.

### Plan
Your strategic layer. Pick a date (defaults to tomorrow) and select tasks from your List to schedule. When tomorrow is selected, it shows "Tomorrow" — because planning should feel intentional, not lazy.

### List
Your inbox. Brain-dump tasks here without thinking about timing or scheduling. These are raw ideas waiting to become action. No date, no pressure — just capture.

### Settings
Customize your thresholds for the four time categories based on your attention span. Add/remove categories to match your life (default: Home, Personal, Work). Set your daily planning reminder time.

---

## Setup

### Requirements
- macOS Sonoma 14+ or iOS 17+
- Xcode 15+

### Clone & Run

```bash
# Clone the repo
git clone git@github.com:ghulamrasuldev/effective-list.git
cd effective-list

# Generate Xcode project
xcodegen generate

# Open in Xcode
open EffectiveList.xcodeproj
```

### Build & Run
1. Select your target device/simulator in Xcode
2. Press `Cmd + R` to build and run

### Widget Setup
1. After installing the app, long-press on the Home Screen
2. Tap the `+` button to add a widget
3. Search for "Effective List"
4. Add the Large widget to see today's tasks

---

## Usage Guide

### Capturing Tasks (List Tab)
1. Tap the `+` in the top right
2. Enter task title
3. Set duration (Quick/Short/Medium/Long or custom with +/- 5min)
4. Pick a category (Home, Personal, Work)
5. Choose repeat behavior (Once, Daily, Weekly, Monthly)
6. Tap "Add"

Tasks sit in List until you're ready to schedule them.

### Planning Ahead (Plan Tab)
1. Tap the calendar icon to pick a date
2. Tap "Select Tasks"
3. Filter by category or time (Quick Wins, Short Tasks, etc.)
4. Tap tasks to add them to your plan
5. Tap "Add to [Date]" to confirm

Planning defaults to tomorrow because effective people plan tonight for tomorrow morning.

### Executing (Today Tab)
1. Wake up, open Today — see what's queued
2. Tap the circle to mark complete
3. Tap the calendar+ icon to move a task to tomorrow if needed
4. Watch the progress ring fill as you crush it

### Daily Rhythm
- **Night before**: Open Plan, pick tomorrow's tasks
- **Morning**: Open Today, execute without distraction
- **Throughout day**: Dump new ideas into List
- **Evening**: Plan tomorrow, repeat

---

## Project Architecture

```
EffectiveList/
├── Models/
│   ├── TodoItem.swift      # Core data model
│   ├── Recurrence.swift    # Repeat behavior
│   └── TimeCategory.swift  # Duration grouping
├── Views/
│   ├── TodayView.swift     # Today's tasks + progress
│   ├── PlanView.swift      # Schedule future tasks
│   ├── ListView.swift      # Inbox/brain dump
│   ├── SettingsView.swift  # App configuration
│   ├── AddTaskView.swift   # Create new task
│   ├── DetailView.swift    # Edit task
│   └── PlanSelectionSheet.swift # Task picker
├── Services/
│   └── NotificationService.swift # Daily reminders
└── AppSettings.swift       # User preferences

EffectiveListWidget/
└── EffectiveListWidget.swift # Home screen widget
```

### Data Persistence
- Uses **SwiftData** for persistence
- App Group (`group.com.effectivelist.app`) shared between app and widget
- Widget reads directly from the shared container

### Widget Refresh
- Auto-refreshes every 5 seconds via TimelineProvider policy
- Manual refresh on:
  - App foreground
  - Widget tap (opens app)
  - Task add/edit/delete

---

## Why This Works

### Time-Based Planning
Most todo apps ask "when is this due?" — the wrong question. Effective List asks "how long does this take?" because you can't change deadlines, but you can make better time decisions.

### No Due Dates
Due dates create false urgency. A task "due Friday" doesn't mean you should work on it Friday — it means you should complete it by Friday. Effective List forces you to explicitly schedule when you'll work on something, not just when it needs to be done.

### Four Buckets, Not Five
Quick Wins (< 5m) catch those tiny tasks that otherwise pile up. Short Tasks (< 15m) handle most normal todos. Medium Tasks (< 1h) are for real work blocks. Long Tasks (4h+) acknowledge that some things need serious time investment. No hour-by-hour planning noise.

### Separation of Capture and Planning
List is inbox — pure capture without commitment. Plan is scheduling — deliberate choice about when. Today is execution — focused action without decision fatigue. This separation prevents the common trap: constantly reorganizing instead of doing.

---

## License

Private. Build your own version if you want.