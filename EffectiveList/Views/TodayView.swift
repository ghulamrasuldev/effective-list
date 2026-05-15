//
//  TodayView.swift
//

import SwiftUI
import SwiftData

struct TodayView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(AppSettings.self) private var settings
    @Query private var allItems: [TodoItem]
    @State private var showAdd = false
    @State private var selectedItem: TodoItem?

    private var todayItems: [TodoItem] {
        let today = Calendar.current.startOfDay(for: Date())
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: today)!
        return allItems.filter { item in
            guard let scheduled = item.scheduledDate else { return false }
            return scheduled >= today && scheduled < tomorrow && !item.isCompleted
        }
    }

    private var completedToday: Int {
        let today = Calendar.current.startOfDay(for: Date())
        return allItems.filter { item in
            guard let completed = item.completedAt else { return false }
            return completed >= today
        }.count
    }

    private var totalTasks: Int {
        todayItems.count + completedToday
    }

    private var progress: Double {
        guard totalTasks > 0 else { return 0 }
        return Double(completedToday) / Double(totalTasks)
    }

    private func groupByCategory(_ items: [TodoItem]) -> [(TimeCategory, [TodoItem])] {
        var grouped: [TimeCategory: [TodoItem]] = [:]
        for item in items {
            let cat = TimeCategory.from(minutes: item.estimatedMinutes, thresholds: settings.thresholds)
            grouped[cat, default: []].append(item)
        }
        return TimeCategory.allCases.compactMap { cat in
            let its = grouped[cat] ?? []
            if its.isEmpty { return nil }
            return (cat, its)
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 32) {
                    headerSection

                    if todayItems.isEmpty {
                        emptyStateView
                    } else {
                        tasksSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            .navigationTitle("Today")
            .navigationBarTitleDisplayMode(.large)
            .toolbar {
                ToolbarItem(placement: .primaryAction) {
                    Button {
                        showAdd = true
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 18, weight: .semibold))
                            .foregroundColor(Color(hex: "FF4D4D"))
                    }
                }
            }
            .sheet(isPresented: $showAdd) { AddTaskView() }
            .sheet(item: $selectedItem) { item in
                DetailView(item: item)
            }
        }
    }

    private var headerSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Today")
                .font(.system(size: 48, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))

            Text(formattedDate)
                .font(.system(size: 14, weight: .medium, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))

            HStack(spacing: 20) {
                ProgressRing(progress: progress, completed: completedToday, total: totalTasks)
                VStack(alignment: .leading, spacing: 4) {
                    Text("\(completedToday) of \(totalTasks)")
                        .font(.system(size: 20, weight: .semibold, design: .default))
                        .foregroundColor(Color(hex: "0A0A0A"))
                    Text("tasks completed")
                        .font(.system(size: 13, weight: .medium, design: .default))
                        .foregroundColor(Color(hex: "6B6B6B"))
                }
                Spacer()
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 16) {
            Image(systemName: "checkmark")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(hex: "6B6B6B"))
            Text("All clear")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))
            Text("No tasks scheduled for today")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B6B6B"))
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var tasksSection: some View {
        VStack(spacing: 24) {
            ForEach(groupByCategory(todayItems), id: \.0) { category, tasks in
                VStack(alignment: .leading, spacing: 12) {
                    HStack {
                        Circle()
                            .fill(Color(hex: category.colorHex))
                            .frame(width: 8, height: 8)
                        Text(category.rawValue.uppercased())
                            .font(.system(size: 11, weight: .bold, design: .default))
                            .foregroundColor(Color(hex: "6B6B6B"))
                            .tracking(1.2)
                        Spacer()
                    }

                    VStack(spacing: 8) {
                        ForEach(tasks) { item in
                            TodayTaskCard(item: item, onTap: { selectedItem = item })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        ctx.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                                .transition(.asymmetric(
                                    insertion: .opacity.combined(with: .move(edge: .trailing)),
                                    removal: .opacity
                                ))
                        }
                    }
                }
            }
        }
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: todayItems.count)
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE, MMMM d"
        return formatter.string(from: Date())
    }
}

struct TodayTaskCard: View {
    @Bindable var item: TodoItem
    var onTap: () -> Void

    var body: some View {
        HStack(spacing: 14) {
            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    item.toggleCompletion()
                }
            } label: {
                ZStack {
                    Circle()
                        .stroke(item.isCompleted ? Color(hex: "22C55E") : Color(hex: "E5E5E5"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if item.isCompleted {
                        Circle()
                            .fill(Color(hex: "22C55E"))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
            }
            .buttonStyle(.plain)

            VStack(alignment: .leading, spacing: 6) {
                Text(item.title)
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(item.isCompleted ? Color(hex: "6B6B6B") : Color(hex: "0A0A0A"))
                    .strikethrough(item.isCompleted)

                HStack(spacing: 8) {
                    Label("\(item.estimatedMinutes)m", systemImage: "clock")
                        .font(.system(size: 11, weight: .medium, design: .monospaced))
                        .foregroundColor(Color(hex: "6B6B6B"))

                    Text(item.category)
                        .font(.system(size: 11, weight: .semibold))
                        .foregroundColor(Color(hex: categoryColor))
                        .padding(.horizontal, 8)
                        .padding(.vertical, 3)
                        .background(Color(hex: categoryColor).opacity(0.12))
                        .clipShape(Capsule())
                }
            }

            Spacer()

            Button {
                withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                    item.moveToTomorrow()
                }
            } label: {
                Image(systemName: "calendar.badge.plus")
                    .font(.system(size: 16, weight: .medium))
                    .foregroundColor(Color(hex: "2563EB"))
            }
            .buttonStyle(.plain)
        }
        .padding(16)
        .background(Color.white)
        .clipShape(RoundedRectangle(cornerRadius: 12))
        .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap()
        }
    }

    private var categoryColor: String {
        switch item.category {
        case "Home": return "22C55E"
        case "Personal": return "3B82F6"
        case "Work": return "F97316"
        default: return "A855F7"
        }
    }
}

struct ProgressRing: View {
    let progress: Double
    let completed: Int
    let total: Int

    @State private var animatedProgress: Double = 0

    var body: some View {
        ZStack {
            Circle()
                .stroke(Color(hex: "E5E5E5"), lineWidth: 6)

            Circle()
                .trim(from: 0, to: animatedProgress)
                .stroke(
                    Color(hex: "FF4D4D"),
                    style: StrokeStyle(lineWidth: 6, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))

            Text("\(Int(progress * 100))%")
                .font(.system(size: 18, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "0A0A0A"))
        }
        .frame(width: 80, height: 80)
        .onAppear {
            withAnimation(.easeOut(duration: 0.6)) {
                animatedProgress = progress
            }
        }
        .onChange(of: progress) { _, newValue in
            withAnimation(.easeOut(duration: 0.3)) {
                animatedProgress = newValue
            }
        }
    }
}

extension TimeCategory {
    var colorHex: String {
        switch self {
        case .quickWins: return "22C55E"
        case .shortTasks: return "3B82F6"
        case .mediumTasks: return "F97316"
        case .longTasks: return "A855F7"
        }
    }
}

#Preview { TodayView().environment(AppSettings()).modelContainer(for: TodoItem.self, inMemory: true) }