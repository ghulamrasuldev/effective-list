//
//  TodoItem.swift
//

import Foundation
import SwiftData

@Model
final class TodoItem {
    var id: UUID
    var title: String
    var notes: String
    var estimatedMinutes: Int
    var categoryRaw: String
    var recurrenceRaw: String
    var isCompleted: Bool
    var scheduledDate: Date?
    var completedAt: Date?

    var category: String {
        get { categoryRaw }
        set { categoryRaw = newValue }
    }

    var recurrence: Recurrence {
        get { Recurrence(rawValue: recurrenceRaw) ?? .once }
        set { recurrenceRaw = newValue.rawValue }
    }

    init(
        id: UUID = UUID(),
        title: String,
        notes: String = "",
        estimatedMinutes: Int = 5,
        category: String = "Personal",
        recurrence: Recurrence = .once,
        isCompleted: Bool = false,
        scheduledDate: Date? = nil,
        completedAt: Date? = nil
    ) {
        self.id = id
        self.title = title
        self.notes = notes
        self.estimatedMinutes = estimatedMinutes
        self.categoryRaw = category
        self.recurrenceRaw = recurrence.rawValue
        self.isCompleted = isCompleted
        self.scheduledDate = scheduledDate
        self.completedAt = completedAt
    }

    func toggleCompletion() {
        isCompleted.toggle()
        completedAt = isCompleted ? Date() : nil
    }

    func moveToTomorrow() {
        let tomorrow = Calendar.current.date(byAdding: .day, value: 1, to: Date())!
        let startOfTomorrow = Calendar.current.startOfDay(for: tomorrow)
        scheduledDate = startOfTomorrow
    }
}