//
//  EffectiveListApp.swift
//

import SwiftUI
import SwiftData
import UIKit
import WidgetKit

@main
struct EffectiveListApp: App {
    @State private var settings = AppSettings()

    init() {
        NotificationService.shared.requestPermission()

        if let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            windowScene.windows.forEach { window in
                window.overrideUserInterfaceStyle = .light
            }
        }

        let tabBarAppearance = UITabBarAppearance()
        tabBarAppearance.configureWithOpaqueBackground()
        tabBarAppearance.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.selected.iconColor = UIColor(red: 1.0, green: 0.30, blue: 0.30, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: UIColor(red: 1.0, green: 0.30, blue: 0.30, alpha: 1.0)]
        tabBarAppearance.stackedLayoutAppearance.normal.iconColor = UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.0)
        tabBarAppearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: UIColor(red: 0.42, green: 0.42, blue: 0.42, alpha: 1.0)]
        UITabBar.appearance().standardAppearance = tabBarAppearance
        UITabBar.appearance().scrollEdgeAppearance = tabBarAppearance

        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.configureWithOpaqueBackground()
        navBarAppearance.backgroundColor = UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        navBarAppearance.titleTextAttributes = [.foregroundColor: UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)]
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor(red: 0.10, green: 0.10, blue: 0.10, alpha: 1.0)]
        navBarAppearance.shadowColor = .clear
        UINavigationBar.appearance().standardAppearance = navBarAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = navBarAppearance
        UINavigationBar.appearance().compactAppearance = navBarAppearance
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(settings)
                .onReceive(NotificationCenter.default.publisher(for: UIApplication.willEnterForegroundNotification)) { _ in
                    WidgetCenter.shared.reloadAllTimelines()
                }
        }
        .modelContainer(modelContainer)
    }

    private var modelContainer: ModelContainer {
        let schema = Schema([TodoItem.self])
        let config = ModelConfiguration(
            isStoredInMemoryOnly: false,
            groupContainer: .identifier("group.com.effectivelist.app")
        )
        do {
            return try ModelContainer(for: schema, configurations: [config])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }
}