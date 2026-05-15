//
//  SettingsView.swift
//

import SwiftUI

struct SettingsView: View {
    @Environment(AppSettings.self) private var settings
    @State private var newCat = ""
    @State private var showAddCat = false

    var body: some View {
        NavigationStack {
            ScrollView {
                VStack(spacing: 24) {
                    headerSection
                    thresholdsSection
                    categoriesSection
                    notificationSection
                }
                .padding(20)
            }
            .background(Color.white)
        }
    }

    private var headerSection: some View {
        HStack {
            Text("Settings")
                .font(.system(size: 34, weight: .bold, design: .serif))
                .foregroundColor(Color(hex: "0A0A0A"))
            Spacer()
        }
        .padding(.bottom, 8)
    }

    private var thresholdsSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Duration Thresholds")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            VStack(spacing: 12) {
                ThresholdRow(
                    title: "Quick Wins",
                    value: settings.quickWinThreshold,
                    color: "22C55E",
                    onChange: { settings.quickWinThreshold = $0 }
                )

                ThresholdRow(
                    title: "Short Tasks",
                    value: settings.shortTaskThreshold,
                    color: "3B82F6",
                    onChange: { settings.shortTaskThreshold = $0 }
                )

                ThresholdRow(
                    title: "Medium Tasks",
                    value: settings.mediumTaskThreshold,
                    color: "F97316",
                    onChange: { settings.mediumTaskThreshold = $0 }
                )

                ThresholdRow(
                    title: "Long Tasks",
                    value: settings.longTaskThreshold,
                    color: "A855F7",
                    onChange: { settings.longTaskThreshold = $0 }
                )
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
    }

    private var categoriesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Task Categories")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            VStack(spacing: 0) {
                ForEach(settings.taskCategories, id: \.self) { cat in
                    HStack {
                        Text(cat)
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "0A0A0A"))

                        Spacer()

                        if !Self.defaultCategories.contains(cat) {
                            Button {
                                settings.removeCategory(cat)
                            } label: {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .bold))
                                    .foregroundColor(Color(hex: "6B6B6B"))
                                    .frame(width: 28, height: 28)
                                    .background(Color(hex: "F5F5F5"))
                                    .clipShape(Circle())
                            }
                        }
                    }
                    .padding(.vertical, 14)

                    if cat != settings.taskCategories.last {
                        Divider()
                    }
                }
            }
            .padding(.horizontal, 16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))

            Button {
                showAddCat = true
            } label: {
                HStack {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 18))
                    Text("Add Category")
                        .font(.system(size: 15, weight: .semibold))
                }
                .foregroundColor(Color(hex: "FF4D4D"))
                .frame(maxWidth: .infinity)
                .padding(.vertical, 14)
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 16))
            }
            .buttonStyle(.plain)
        }
    }

    private var notificationSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("Notifications")
                .font(.system(size: 12, weight: .bold, design: .default))
                .foregroundColor(Color(hex: "6B6B6B"))
                .tracking(0.5)

            VStack(alignment: .leading, spacing: 12) {
                HStack {
                    VStack(alignment: .leading, spacing: 2) {
                        Text("Daily Reminder")
                            .font(.system(size: 16, weight: .medium))
                            .foregroundColor(Color(hex: "0A0A0A"))
                        Text("Time to plan your tomorrow")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(Color(hex: "6B6B6B"))
                    }

                    Spacer()

                    Image(systemName: "bell.fill")
                        .font(.system(size: 18))
                        .foregroundColor(Color(hex: "2563EB"))
                }

                DatePicker("", selection: Binding(
                    get: { settings.notificationTime },
                    set: { settings.notificationTime = $0 }
                ), displayedComponents: .hourAndMinute)
                    .labelsHidden()
                    .datePickerStyle(.compact)

                Button {
                    NotificationService.shared.schedule()
                } label: {
                    Text("Reschedule Reminder")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(Color(hex: "FF4D4D"))
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 10)
                        .background(Color(hex: "FF4D4D").opacity(0.1))
                        .clipShape(RoundedRectangle(cornerRadius: 8))
                }
            }
            .padding(16)
            .background(Color.white)
            .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .alert("Add Category", isPresented: $showAddCat) {
            TextField("Name", text: $newCat)
            Button("Cancel", role: .cancel) { newCat = "" }
            Button("Add") {
                settings.addCategory(newCat)
                newCat = ""
            }
        }
    }

    static let defaultCategories = ["Home", "Personal", "Work"]
}

struct ThresholdRow: View {
    let title: String
    let value: Int
    let color: String
    let onChange: (Int) -> Void

    @State private var localValue: Int = 0

    var body: some View {
        HStack {
            Circle()
                .fill(Color(hex: color))
                .frame(width: 10, height: 10)

            Text(title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(Color(hex: "0A0A0A"))

            Spacer()

            HStack(spacing: 12) {
                Button {
                    if localValue > 4 { localValue -= 5; onChange(localValue) }
                } label: {
                    Image(systemName: "minus")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(Color(hex: "FF4D4D"))
                        .frame(width: 36, height: 36)
                        .background(Color(hex: "FF4D4D").opacity(0.1))
                        .clipShape(Circle())
                }
                .disabled(localValue <= 5)

                Text(formattedValue)
                    .font(.system(size: 16, weight: .semibold, design: .monospaced))
                    .foregroundColor(Color(hex: "0A0A0A"))
                    .frame(minWidth: 50)

                Button {
                    localValue += 5; onChange(localValue)
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
        .onAppear { localValue = value }
        .onChange(of: value) { _, newValue in localValue = newValue }
    }

    private var formattedValue: String {
        if localValue < 60 {
            return "\(localValue)m"
        } else if localValue == 60 {
            return "1h"
        } else {
            let hours = localValue / 60
            let mins = localValue % 60
            if mins == 0 {
                return "\(hours)h"
            } else {
                return "\(hours)h\(mins)m"
            }
        }
    }
}

#Preview { SettingsView().environment(AppSettings()) }