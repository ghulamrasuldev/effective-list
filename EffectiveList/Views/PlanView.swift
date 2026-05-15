//
//  PlanView.swift
//

import SwiftUI
import SwiftData

struct PlanView: View {
    @Environment(\.modelContext) private var ctx
    @Environment(AppSettings.self) private var settings
    @Query private var allItems: [TodoItem]
    @State private var selectedDate = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
    @State private var showSelectionSheet = false
    @State private var showDatePicker = false
    @State private var selectedItem: TodoItem?

    private var scheduledItems: [TodoItem] {
        let startOfDay = Calendar.current.startOfDay(for: selectedDate)
        let endOfDay = Calendar.current.date(byAdding: .day, value: 1, to: startOfDay)!
        return allItems.filter { item in
            guard let scheduled = item.scheduledDate else { return false }
            return scheduled >= startOfDay && scheduled < endOfDay && !item.isCompleted
        }
    }

    private var isTomorrow: Bool {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        return Calendar.current.isDate(selectedDate, inSameDayAs: tomorrow)
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

    private func unscheduleItem(_ item: TodoItem) {
        withAnimation {
            item.scheduledDate = nil
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 24) {
                    Text("PLAN")
                        .font(.system(size: 12, weight: .bold))
                        .foregroundColor(Color(hex: "6B6B6B"))
                        .tracking(2)
                        .padding(.top, 8)
                    dateHeader

                    if scheduledItems.isEmpty {
                        emptyStateView
                    } else {
                        scheduledSection
                    }
                }
                .padding(.horizontal, 20)
                .padding(.top, 8)
                .padding(.bottom, 100)
            }
            .background(Color.white)
            .navigationTitle("Plan")
            .navigationBarTitleDisplayMode(.large)
            .sheet(isPresented: $showSelectionSheet) {
                PlanSelectionSheet(targetDate: selectedDate)
            }
            .sheet(item: $selectedItem) { item in
                DetailView(item: item)
            }
            .sheet(isPresented: $showDatePicker) {
                NavigationStack {
                    VStack {
                        DatePicker("", selection: $selectedDate, displayedComponents: .date)
                            .datePickerStyle(.graphical)
                            .padding()
                    }
                    .navigationTitle("Select Date")
                    .navigationBarTitleDisplayMode(.inline)
                    .toolbar {
                        ToolbarItem(placement: .confirmationAction) {
                            Button("Done") {
                                showDatePicker = false
                            }
                            .foregroundColor(Color(hex: "FF4D4D"))
                        }
                    }
                }
                .presentationDetents([.medium])
            }
        }
    }

    private var dateHeader: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .bottom) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(isTomorrow ? "Tomorrow" : dayOfWeek)
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "FF4D4D"))
                        .tracking(1.5)
                    Text(isTomorrow ? formattedDate : dayNumber)
                        .font(.system(size: 42, weight: .bold, design: .serif))
                        .foregroundColor(Color(hex: "0A0A0A"))
                    Text(isTomorrow ? "" : monthYear)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "6B6B6B"))
                }
                Spacer()
                Button {
                    showDatePicker.toggle()
                } label: {
                    Image(systemName: "calendar")
                        .font(.system(size: 20, weight: .medium))
                        .foregroundColor(Color(hex: "FF4D4D"))
                        .frame(width: 44, height: 44)
                        .background(Color(hex: "FF4D4D").opacity(0.1))
                        .clipShape(Circle())
                }
                .padding(.bottom, 4)
            }
            .padding(20)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
            .shadow(color: Color.black.opacity(0.08), radius: 12, x: 0, y: 4)
        }
    }

    private var emptyStateView: some View {
        VStack(spacing: 20) {
            Image(systemName: "calendar.badge.plus")
                .font(.system(size: 48, weight: .light))
                .foregroundColor(Color(hex: "6B6B6B"))

            Text("Plan your day")
                .font(.system(size: 24, weight: .semibold, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))

            Button {
                showSelectionSheet = true
            } label: {
                Text("Select Tasks")
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 14)
                    .background(Color(hex: "FF4D4D"))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding(.horizontal, 40)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 60)
    }

    private var scheduledSection: some View {
        VStack(spacing: 24) {
            ForEach(groupByCategory(scheduledItems), id: \.0) { category, tasks in
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
                        Button {
                            showSelectionSheet = true
                        } label: {
                            Text("Add more")
                                .font(.system(size: 12, weight: .medium))
                                .foregroundColor(Color(hex: "FF4D4D"))
                        }
                    }

                    VStack(spacing: 8) {
                        ForEach(tasks) { item in
                            PlanTaskCard(item: item, onTap: { selectedItem = item }, onUnschedule: { unscheduleItem(item) })
                                .swipeActions(edge: .trailing, allowsFullSwipe: true) {
                                    Button(role: .destructive) {
                                        ctx.delete(item)
                                    } label: {
                                        Label("Delete", systemImage: "trash")
                                    }
                                }
                        }
                    }
                }
            }
        }
    }

    private var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM d"
        return formatter.string(from: selectedDate)
    }

    private var dayOfWeek: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE"
        return formatter.string(from: selectedDate)
    }

    private var dayNumber: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "d"
        return formatter.string(from: selectedDate)
    }

    private var monthYear: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MMMM yyyy"
        return formatter.string(from: selectedDate)
    }
}

struct PlanTaskCard: View {
    @Bindable var item: TodoItem
    var onTap: () -> Void
    var onUnschedule: () -> Void

    var body: some View {
        HStack(spacing: 14) {
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

            Button {
                onUnschedule()
            } label: {
                Image(systemName: "calendar.badge.minus")
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

#Preview { PlanView().environment(AppSettings()).modelContainer(for: TodoItem.self, inMemory: true) }