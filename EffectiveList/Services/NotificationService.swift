//
//  NotificationService.swift
//

import Foundation
import UserNotifications

final class NotificationService {
    static let shared = NotificationService()

    private init() {}

    func requestPermission() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound]) { granted, error in
            if granted {
                self.schedule()
            }
        }
    }

    func schedule() {
        let settings = AppSettings()
        schedule(hour: settings.notificationHour, minute: settings.notificationMinute)
    }

    func schedule(hour: Int, minute: Int) {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()

        let content = UNMutableNotificationContent()
        content.title = "Plan Your Tomorrow"
        content.body = "Time to select tasks for tomorrow. Open EffectiveList to plan your day."
        content.sound = .default

        var dateComponents = DateComponents()
        dateComponents.hour = hour
        dateComponents.minute = minute

        let trigger = UNCalendarNotificationTrigger(dateMatching: dateComponents, repeats: true)

        let request = UNNotificationRequest(
            identifier: "daily-planning-reminder",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error)")
            }
        }
    }
}