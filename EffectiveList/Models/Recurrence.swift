//
//  Recurrence.swift
//

import Foundation

enum Recurrence: String, CaseIterable, Codable, Identifiable {
    case once = "Once"
    case daily = "Daily"
    case weekly = "Weekly"
    case monthly = "Monthly"

    var id: String { rawValue }

    var icon: String {
        switch self {
        case .once: return "1.circle"
        case .daily: return "sun.max"
        case .weekly: return "calendar"
        case .monthly: return "calendar.badge.clock"
        }
    }
}