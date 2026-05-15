//
//  EffectiveListWidget.swift
//

import WidgetKit
import SwiftUI
import SwiftData
import AppIntents

@main
struct EffectiveListWidgetBundle: WidgetBundle {
    var body: some Widget { EffectiveListWidget() }
}

struct EffectiveListWidget: Widget {
    let kind = "EffectiveListWidget"

    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: Provider()) { entry in
            WidgetView(entry: entry)
                .containerBackground(Color.black, for: .widget)
        }
        .configurationDisplayName("Today's Tasks")
        .description("Your tasks for today.")
        .supportedFamilies([.systemLarge])
    }
}

struct Provider: TimelineProvider {
    func placeholder(in _: Context) -> Entry { Entry(date: .now, items: [], stats: WidgetStats(completed: 0, total: 0)) }

    func getSnapshot(in _: Context, completion: @escaping (Entry) -> Void) {
        let (items, stats) = fetchItemsAndStats()
        completion(Entry(date: .now, items: items, stats: stats))
    }

    func getTimeline(in _: Context, completion: @escaping (Timeline<Entry>) -> Void) {
        let (items, stats) = fetchItemsAndStats()
        let entry = Entry(date: .now, items: items, stats: stats)

        let refreshDate = Calendar.current.date(byAdding: .second, value: 5, to: Date()) ?? Date()
        let timeline = Timeline(entries: [entry], policy: .after(refreshDate))
        completion(timeline)
    }

    private func fetchItemsAndStats() -> ([WidgetTask], WidgetStats) {
        guard let container = try? ModelContainer(for: TodoItem.self, configurations: ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.effectivelist.app")
        )) else {
            return ([], WidgetStats(completed: 0, total: 0))
        }
        let ctx = ModelContext(container)

        let todayStart = Calendar.current.startOfDay(for: Date())
        let todayEnd = Calendar.current.date(byAdding: .day, value: 1, to: todayStart)!

        let allDesc = FetchDescriptor<TodoItem>(predicate: #Predicate<TodoItem> { !$0.isCompleted })
        let allItems = (try? ctx.fetch(allDesc)) ?? []

        let todayItems = allItems.filter { item in
            guard let scheduled = item.scheduledDate else { return false }
            return scheduled >= todayStart && scheduled < todayEnd
        }

        let completedToday = todayItems.filter { $0.isCompleted }.count

        let totalActive = todayItems.count

        let tasks = todayItems.map { WidgetTask(id: $0.id, title: $0.title, category: $0.category, isCompleted: $0.isCompleted, timeMinutes: $0.estimatedMinutes) }
        let stats = WidgetStats(completed: completedToday, total: totalActive)
        return (tasks, stats)
    }
}

struct Entry: TimelineEntry {
    let date: Date
    let items: [WidgetTask]
    let stats: WidgetStats
}

struct WidgetStats {
    let completed: Int
    let total: Int
}

struct WidgetTask: Identifiable {
    let id: UUID
    let title: String
    let category: String
    let isCompleted: Bool
    let timeMinutes: Int
}

struct WidgetView: View {
    let entry: Entry

    var body: some View {
        LargeView(entry: entry)
    }
}

struct SmallView: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .font(.system(size: 14, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Spacer()
            }

            if entry.items.isEmpty {
                VStack(spacing: 4) {
                    Image(systemName: "checkmark.circle")
                        .font(.system(size: 20))
                        .foregroundColor(Color(hex: "FF4D4D"))
                    Text("All done!")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(Color(hex: "9B9B9B"))
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.items.prefix(2)) { item in
                        WidgetTaskRow(item: item, backgroundColor: Color.black, textColor: .white)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
    }
}

struct MediumView: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                Text("Today")
                    .font(.system(size: 16, weight: .bold, design: .serif))
                    .foregroundColor(.white)
                Spacer()
                Text("\(entry.items.count) task\(entry.items.count == 1 ? "" : "s")")
                    .font(.system(size: 11, weight: .medium, design: .monospaced))
                    .foregroundColor(Color(hex: "9B9B9B"))
            }

            if entry.items.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 4) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 24))
                            .foregroundColor(Color(hex: "FF4D4D"))
                        Text("Make it happen")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "9B9B9B"))
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                VStack(alignment: .leading, spacing: 6) {
                    ForEach(entry.items.prefix(4)) { item in
                        WidgetTaskRow(item: item, showTime: true, backgroundColor: Color.black, textColor: .white)
                    }
                }
                Spacer()
            }
        }
        .padding(16)
    }
}

struct LargeView: View {
    let entry: Entry
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack {
                VStack(alignment: .leading, spacing: 2) {
                    Text("Today")
                        .font(.system(size: 20, weight: .bold, design: .serif))
                        .foregroundColor(.white)
                    Text(formattedDate)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(Color(hex: "9B9B9B"))
                }
                Spacer()
                if entry.stats.total > 0 {
                    VStack(alignment: .trailing, spacing: 2) {
                        Text("Done")
                            .font(.system(size: 9, weight: .bold))
                            .foregroundColor(Color(hex: "9B9B9B"))
                        Text("\(entry.stats.completed)/\(entry.stats.total)")
                            .font(.system(size: 13, weight: .semibold, design: .monospaced))
                            .foregroundColor(Color(hex: "FF4D4D"))
                    }
                }
            }

            if entry.items.isEmpty {
                HStack {
                    Spacer()
                    VStack(spacing: 8) {
                        Image(systemName: "checkmark.circle")
                            .font(.system(size: 28))
                            .foregroundColor(Color(hex: "FF4D4D"))
                        Text("Let's get it done")
                            .font(.system(size: 13, weight: .semibold, design: .serif))
                            .foregroundColor(.white)
                        Text("Add tasks to your list")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(Color(hex: "9B9B9B"))
                    }
                    Spacer()
                }
                .frame(maxHeight: .infinity)
            } else {
                LazyVStack(spacing: 8) {
                    ForEach(entry.items.prefix(6)) { item in
                        WidgetTaskRow(item: item, showTime: true, showCategory: true, backgroundColor: Color.black, textColor: .white)
                    }
                }
            }
        }
        .padding(12)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE, MMM d"
        return formatter.string(from: Date())
    }
}

struct WidgetTaskRow: View {
    let item: WidgetTask
    var showTime: Bool = false
    var showCategory: Bool = false
    var backgroundColor: Color = .white
    var textColor: Color = Color(hex: "0A0A0A")

    var body: some View {
        HStack(spacing: 10) {
            Button(intent: ToggleTaskIntent(id: item.id)) {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? Color(hex: "22C55E") : Color(hex: "555555"), lineWidth: 1.5)
                        .frame(width: 20, height: 20)

                    if item.isCompleted {
                        Circle()
                            .fill(Color(hex: "22C55E"))
                            .frame(width: 20, height: 20)
                        Image(systemName: "checkmark")
                            .font(.system(size: 10, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 2) {
                Text(item.title)
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(item.isCompleted ? Color(hex: "555555") : textColor)
                    .strikethrough(item.isCompleted)
                    .lineLimit(1)

                if showTime || showCategory {
                    HStack(spacing: 6) {
                        if showTime {
                            Label("\(item.timeMinutes)m", systemImage: "clock")
                                .font(.system(size: 10, weight: .medium, design: .monospaced))
                                .foregroundColor(Color(hex: "9B9B9B"))
                        }
                        if showCategory {
                            Text(item.category)
                                .font(.system(size: 9, weight: .semibold))
                                .foregroundColor(categoryColor)
                                .padding(.horizontal, 5)
                                .padding(.vertical, 2)
                                .background(categoryColor.opacity(0.2))
                                .clipShape(Capsule())
                        }
                    }
                }
            }

            Spacer()
        }
        .padding(.vertical, 5)
        .padding(.horizontal, 8)
        .background(Color(hex: "1A1A1A"))
        .clipShape(RoundedRectangle(cornerRadius: 6))
    }

    private var categoryColor: Color {
        switch item.category {
        case "Home": return Color(hex: "22C55E")
        case "Personal": return Color(hex: "3B82F6")
        case "Work": return Color(hex: "F97316")
        default: return Color(hex: "A855F7")
        }
    }
}

struct ToggleTaskIntent: AppIntent {
    static var title: LocalizedStringResource = "Toggle Task"
    @Parameter(title: "Task ID") var id: String

    init() { self.id = "" }
    init(id: UUID) { self.id = id.uuidString }

    func perform() async throws -> some IntentResult {
        guard let uuid = UUID(uuidString: id) else { return .result() }
        guard let container = try? ModelContainer(for: TodoItem.self, configurations: ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.effectivelist.app")
        )) else { return .result() }
        let ctx = ModelContext(container)
        let desc = FetchDescriptor<TodoItem>(predicate: #Predicate<TodoItem> { $0.id == uuid })
        if let item = try? ctx.fetch(desc).first {
            item.toggleCompletion()
            try? ctx.save()
            WidgetCenter.shared.reloadAllTimelines()
        }
        return .result()
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}

#Preview(as: .systemSmall) {
    EffectiveListWidget()
} timeline: {
    Entry(date: .now, items: [
        WidgetTask(id: UUID(), title: "Morning workout", category: "Personal", isCompleted: false, timeMinutes: 30),
        WidgetTask(id: UUID(), title: "Review report", category: "Work", isCompleted: false, timeMinutes: 15)
    ], stats: WidgetStats(completed: 2, total: 5))
}

#Preview(as: .systemMedium) {
    EffectiveListWidget()
} timeline: {
    Entry(date: .now, items: [
        WidgetTask(id: UUID(), title: "Morning workout", category: "Personal", isCompleted: false, timeMinutes: 30),
        WidgetTask(id: UUID(), title: "Review quarterly report", category: "Work", isCompleted: false, timeMinutes: 60),
        WidgetTask(id: UUID(), title: "Buy groceries", category: "Home", isCompleted: false, timeMinutes: 15),
        WidgetTask(id: UUID(), title: "Call mom", category: "Personal", isCompleted: false, timeMinutes: 5)
    ], stats: WidgetStats(completed: 2, total: 5))
}

#Preview(as: .systemLarge) {
    EffectiveListWidget()
} timeline: {
    Entry(date: .now, items: [
        WidgetTask(id: UUID(), title: "Morning workout", category: "Personal", isCompleted: false, timeMinutes: 30),
        WidgetTask(id: UUID(), title: "Review quarterly report", category: "Work", isCompleted: false, timeMinutes: 60),
        WidgetTask(id: UUID(), title: "Buy groceries", category: "Home", isCompleted: false, timeMinutes: 15),
        WidgetTask(id: UUID(), title: "Call mom", category: "Personal", isCompleted: false, timeMinutes: 5),
        WidgetTask(id: UUID(), title: "Read book", category: "Personal", isCompleted: false, timeMinutes: 30)
    ], stats: WidgetStats(completed: 2, total: 5))
}
