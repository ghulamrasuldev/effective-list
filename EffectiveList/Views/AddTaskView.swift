//
//  AddTaskView.swift
//

import SwiftUI
import WidgetKit

struct AddTaskView: View {
    @Environment(\.dismiss) private var dismiss
    @Environment(\.modelContext) private var ctx
    @Environment(AppSettings.self) private var settings

    @State private var title = ""
    @State private var notes = ""
    @State private var estimatedMinutes: Int = 5
    @State private var category = "Personal"
    @State private var recurrence: Recurrence = .once

    enum DurationPreset: Int, CaseIterable {
        case quick = 5
        case short = 15
        case medium = 60
        case long = 240

        var title: String {
            switch self {
            case .quick: return "Quick"
            case .short: return "Short"
            case .medium: return "Medium"
            case .long: return "Long"
            }
        }

        var subtitle: String {
            switch self {
            case .quick: return "< 5m"
            case .short: return "< 15m"
            case .medium: return "< 1h"
            case .long: return "4h+"
            }
        }
    }

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(alignment: .leading, spacing: 28) {
                    titleSection
                    durationSection
                    categorySection
                    recurrenceSection
                }
                .padding(20)
            }
            .background(Color.white)
            .navigationTitle("New Task")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .cancellationAction) {
                    Button("Cancel") { dismiss() }
                        .foregroundColor(Color(hex: "6B6B6B"))
                }
                ToolbarItem(placement: .confirmationAction) {
                    Button("Add") {
                        add()
                        dismiss()
                    }
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(Color(hex: "FF4D4D"))
                    .disabled(title.trimmingCharacters(in: .whitespaces).isEmpty)
                }
            }
        }
    }

    private var titleSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Task")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            TextField("What needs to be done?", text: $title)
                .font(.system(size: 20, weight: .medium, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))

            TextField("Notes (optional)", text: $notes, axis: .vertical)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(Color(hex: "6B6B6B"))
                .lineLimit(3...6)
                .padding(16)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var durationSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Duration")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            HStack(spacing: 10) {
                ForEach(DurationPreset.allCases, id: \.self) { preset in
                    DurationButton(
                        title: preset.title,
                        subtitle: preset.subtitle,
                        selected: estimatedMinutes == preset.rawValue
                    ) {
                        estimatedMinutes = preset.rawValue
                    }
                }
            }

            HStack(spacing: 16) {
                Text("Or set custom:")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(hex: "6B6B6B"))

                Spacer()

                HStack(spacing: 12) {
                    Button {
                        if estimatedMinutes > 1 { estimatedMinutes -= 5 }
                    } label: {
                        Image(systemName: "minus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "FF4D4D"))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "FF4D4D").opacity(0.1))
                            .clipShape(Circle())
                    }
                    .disabled(estimatedMinutes <= 1)

                    Text(formattedDuration)
                        .font(.system(size: 18, weight: .semibold, design: .monospaced))
                        .foregroundColor(Color(hex: "0A0A0A"))
                        .frame(minWidth: 60)

                    Button {
                        estimatedMinutes += 5
                    } label: {
                        Image(systemName: "plus")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color(hex: "FF4D4D"))
                            .frame(width: 36, height: 36)
                            .background(Color(hex: "FF4D4D").opacity(0.1))
                            .clipShape(Circle())
                    }
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 12))
        }
    }

    private var formattedDuration: String {
        if estimatedMinutes < 60 {
            return "\(estimatedMinutes) min"
        } else if estimatedMinutes == 60 {
            return "1 hour"
        } else {
            let hours = estimatedMinutes / 60
            let mins = estimatedMinutes % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h \(mins)m"
            }
        }
    }

    private var categorySection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Category")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            ScrollView(.horizontal, showsIndicators: false) {
                HStack(spacing: 8) {
                    ForEach(settings.taskCategories, id: \.self) { cat in
                        CategoryChip(title: cat, selected: category == cat) {
                            category = cat
                        }
                    }
                }
            }
        }
    }

    private var recurrenceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Repeat")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            HStack(spacing: 0) {
                ForEach(Recurrence.allCases) { rec in
                    Button {
                        recurrence = rec
                    } label: {
                        Text(rec.rawValue)
                            .font(.system(size: 13, weight: .medium))
                            .foregroundColor(recurrence == rec ? .white : Color(hex: "0A0A0A"))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 10)
                            .background(recurrence == rec ? Color(hex: "FF4D4D") : Color.white)
                    }
                    .buttonStyle(.plain)

                    if rec != Recurrence.allCases.last {
                        Divider().frame(height: 20)
                    }
                }
            }
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
        }
    }

    private func add() {
        let newItem = TodoItem(
            title: title.trimmingCharacters(in: .whitespaces),
            notes: notes,
            estimatedMinutes: estimatedMinutes,
            category: category,
            recurrence: recurrence,
            scheduledDate: nil
        )
        ctx.insert(newItem)
        try? ctx.save()
        WidgetCenter.shared.reloadAllTimelines()
    }
}

fileprivate struct DurationButton: View {
    let title: String
    let subtitle: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            VStack(spacing: 4) {
                Text(title)
                    .font(.system(size: 14, weight: .semibold))
                Text(subtitle)
                    .font(.system(size: 10, weight: .medium, design: .monospaced))
            }
            .foregroundColor(selected ? .white : Color(hex: "0A0A0A"))
            .frame(maxWidth: .infinity)
            .padding(.vertical, 14)
            .background(selected ? Color(hex: "FF4D4D") : Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .shadow(color: selected ? Color(hex: "FF4D4D").opacity(0.3) : Color.black.opacity(0.04), radius: 4, x: 0, y: 2)
        }
        .buttonStyle(.plain)
    }
}

fileprivate struct CategoryChip: View {
    let title: String
    let selected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(selected ? .white : Color(hex: "0A0A0A"))
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(selected ? Color(hex: "FF4D4D") : Color.white)
                .clipShape(Capsule())
        }
        .buttonStyle(.plain)
    }
}

#Preview { AddTaskView().environment(AppSettings()).modelContainer(for: TodoItem.self, inMemory: true) }