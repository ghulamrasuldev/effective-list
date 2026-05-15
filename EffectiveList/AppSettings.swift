//
//  AppSettings.swift
//

import Foundation

@Observable
final class AppSettings {
    private let defaults = UserDefaults.standard

    private enum Keys {
        static let quickWinThreshold = "timeThreshold.quickWin"
        static let shortTaskThreshold = "timeThreshold.shortTask"
        static let mediumTaskThreshold = "timeThreshold.mediumTask"
        static let longTaskThreshold = "timeThreshold.longTask"
        static let taskCategories = "taskCategories"
        static let notificationHour = "notificationHour"
        static let notificationMinute = "notificationMinute"
    }

    static let defaultCategories = ["Home", "Personal", "Work"]
    static let defaultThresholds = (quick: 5, short: 15, medium: 60)

    var quickWinThreshold: Int {
        get { defaults.integer(forKey: Keys.quickWinThreshold).nonZeroOr(5) }
        set { defaults.set(newValue, forKey: Keys.quickWinThreshold) }
    }

    var shortTaskThreshold: Int {
        get { defaults.integer(forKey: Keys.shortTaskThreshold).nonZeroOr(15) }
        set { defaults.set(newValue, forKey: Keys.shortTaskThreshold) }
    }

    var mediumTaskThreshold: Int {
        get { defaults.integer(forKey: Keys.mediumTaskThreshold).nonZeroOr(60) }
        set { defaults.set(newValue, forKey: Keys.mediumTaskThreshold) }
    }

    var longTaskThreshold: Int {
        get { defaults.integer(forKey: Keys.longTaskThreshold).nonZeroOr(240) }
        set { defaults.set(newValue, forKey: Keys.longTaskThreshold) }
    }

    var taskCategories: [String] {
        get { defaults.stringArray(forKey: Keys.taskCategories) ?? Self.defaultCategories }
        set { defaults.set(newValue, forKey: Keys.taskCategories) }
    }

    var notificationHour: Int {
        get { defaults.integer(forKey: Keys.notificationHour).nonZeroOr(23) }
        set { defaults.set(newValue, forKey: Keys.notificationHour) }
    }

    var notificationMinute: Int {
        get { defaults.integer(forKey: Keys.notificationMinute).nonZeroOr(0) }
        set { defaults.set(newValue, forKey: Keys.notificationMinute) }
    }

    var notificationTime: Date {
        get {
            var components = DateComponents()
            components.hour = notificationHour
            components.minute = notificationMinute
            return Calendar.current.date(from: components) ?? Date()
        }
        set {
            let components = Calendar.current.dateComponents([.hour, .minute], from: newValue)
            notificationHour = components.hour ?? 23
            notificationMinute = components.minute ?? 0
        }
    }

    var thresholds: (quick: Int, short: Int, medium: Int, long: Int) {
        (quickWinThreshold, shortTaskThreshold, mediumTaskThreshold, longTaskThreshold)
    }

    func addCategory(_ name: String) {
        guard !name.isEmpty, !taskCategories.contains(name) else { return }
        taskCategories.append(name)
    }

    func removeCategory(_ name: String) {
        taskCategories.removeAll { $0 == name }
    }
}

private extension Int {
    func nonZeroOr(_ defaultValue: Int) -> Int {
        self > 0 ? self : defaultValue
    }
}