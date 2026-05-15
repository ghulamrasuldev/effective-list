//
//  ContentView.swift
//

import SwiftUI
import WidgetKit

struct ContentView: View {
    @State private var selectedTab = 0

    var body: some View {
        TabView(selection: $selectedTab) {
            TodayView()
                .tabItem {
                    Label("Today", systemImage: "checkmark.circle")
                        .foregroundColor(selectedTab == 0 ? Color(hex: "FF4D4D") : Color(hex: "6B6B6B"))
                }
                .tag(0)

            PlanView()
                .tabItem {
                    Label("Plan", systemImage: "calendar")
                        .foregroundColor(selectedTab == 1 ? Color(hex: "FF4D4D") : Color(hex: "6B6B6B"))
                }
                .tag(1)

            ListView()
                .tabItem {
                    Label("List", systemImage: "tray")
                        .foregroundColor(selectedTab == 2 ? Color(hex: "FF4D4D") : Color(hex: "6B6B6B"))
                }
                .tag(2)

            SettingsView()
                .tabItem {
                    Label("Settings", systemImage: "gear")
                        .foregroundColor(selectedTab == 3 ? Color(hex: "FF4D4D") : Color(hex: "6B6B6B"))
                }
                .tag(3)
        }
        .tint(Color(hex: "FF4D4D"))
        .preferredColorScheme(.light)
        .onOpenURL { url in
            if url.host == "tomorrow" { selectedTab = 1 }
            WidgetCenter.shared.reloadAllTimelines()
        }
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

#Preview { ContentView().environment(AppSettings()).modelContainer(for: TodoItem.self, inMemory: true) }