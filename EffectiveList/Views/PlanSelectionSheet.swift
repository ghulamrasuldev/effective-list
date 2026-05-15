//
//  PlanSelectionSheet.swift
//

import SwiftUI
import SwiftData

struct PlanSelectionSheet: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @Environment(AppSettings.self) private var settings
    @Query(filter: #Predicate<TodoItem> { $0.scheduledDate == nil && !$0.isCompleted }, sort: \TodoItem.completedAt, order: .reverse) private var listItems: [TodoItem]
    let targetDate: Date

    @State private var selectedItems: Set<UUID> = []
    @State private var filterCategory: String?
    @State private var filterTimeCategory: TimeCategory?

    private var filteredItems: [TodoItem] {
        listItems.filter { item in
            if let cat = filterCategory, item.category != cat { return false }
            if let timeCat = filterTimeCategory {
                let itemCat = TimeCategory.from(minutes: item.estimatedMinutes, thresholds: settings.thresholds)
                if itemCat != timeCat { return false }
            }
            return true
        }
    }

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                filterBar

                if filteredItems.isEmpty {
                    emptyView
                } else {
                    ScrollView {
                        LazyVStack(spacing: 8) {
                            ForEach(filteredItems) { item in
                                SelectionTaskCard(
                                    item: item,
                                    isSelected: selectedItems.contains(item.id)
                                ) {
                                    toggleSelection(item)
                                }
                            }
                        }
                        .padding(.horizontal, 20)
                        .padding(.vertical, 12)
                    }
                }

                if !selectedItems.isEmpty {
                    confirmButton
                }
            }
            .background(Color.white)
            .navigationTitle("Select Tasks")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "6B6B6B"))
                }
            }
        }
    }

    private var filterBar: some View {
        ScrollView(.horizontal, showsIndicators: false) {
            HStack(spacing: 8) {
                FilterChip(title: "All", selected: filterCategory == nil && filterTimeCategory == nil) {
                    filterCategory = nil; filterTimeCategory = nil
                }

                Divider().frame(height: 20)

                ForEach(settings.taskCategories, id: \.self) { cat in
                    FilterChip(title: cat, selected: filterCategory == cat) {
                        filterCategory = (filterCategory == cat) ? nil : cat
                    }
                }

                Divider().frame(height: 20)

                ForEach(TimeCategory.allCases) { timeCat in
                    FilterChip(title: timeCat.rawValue, selected: filterTimeCategory == timeCat) {
                        filterTimeCategory = (filterTimeCategory == timeCat) ? nil : timeCat
                    }
                }
            }
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
        }
    }

    private var emptyView: some View {
        VStack(spacing: 16) {
            Spacer()
            Image(systemName: "tray")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(hex: "6B6B6B"))
            Text("No tasks available")
                .font(.system(size: 18, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))
            Text("Add tasks in List tab first")
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B6B6B"))
            Spacer()
        }
    }

    private var confirmButton: some View {
        Button {
            confirmSelection()
        } label: {
            Text("Add \(selectedItems.count) task\(selectedItems.count == 1 ? "" : "s")")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding(.vertical, 16)
                .background(Color(hex: "FF4D4D"))
        }
    }

    private func toggleSelection(_ item: TodoItem) {
        if selectedItems.contains(item.id) {
            selectedItems.remove(item.id)
        } else {
            selectedItems.insert(item.id)
        }
    }

    private func confirmSelection() {
        let startOfDay = Calendar.current.startOfDay(for: targetDate)
        for item in listItems where selectedItems.contains(item.id) {
            item.scheduledDate = startOfDay
        }
        dismiss()
    }
}

struct SelectionTaskCard: View {
    @Bindable var item: TodoItem
    let isSelected: Bool
    let onTap: () -> Void

    var body: some View {
        Button(action: onTap) {
            HStack(spacing: 14) {
                ZStack {
                    Circle()
                        .stroke(isSelected ? Color(hex: "FF4D4D") : Color(hex: "E5E5E5"), lineWidth: 2)
                        .frame(width: 24, height: 24)

                    if isSelected {
                        Circle()
                            .fill(Color(hex: "FF4D4D"))
                            .frame(width: 24, height: 24)
                        Image(systemName: "checkmark")
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 6) {
                    Text(item.title)
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(Color(hex: "0A0A0A"))

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
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .shadow(color: Color.black.opacity(0.04), radius: 6, x: 0, y: 2)
        }
        .buttonStyle(.plain)
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

struct FilterChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(selected ? .white : Color(hex: "0A0A0A"))
                .padding(.horizontal, 14)
                .padding(.vertical, 7)
                .background(selected ? Color(hex: "FF4D4D") : Color(hex: "E5E5E5"))
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
        .animation(.easeInOut(duration: 0.15), value: selected)
    }
}

#Preview { PlanSelectionSheet(targetDate: Date()).environment(AppSettings()).modelContainer(for: TodoItem.self, inMemory: true) }