//
//  TimeCategory.swift
//

import Foundation

enum TimeCategory: String, CaseIterable, Codable, Identifiable {
    case quickWins = "Quick Wins"
    case shortTasks = "Short Tasks"
    case mediumTasks = "Medium Tasks"
    case longTasks = "Long Tasks"

    var id: String { rawValue }

    var maxMinutes: Int {
        switch self {
        case .quickWins: return 5
        case .shortTasks: return 15
        case .mediumTasks: return 60
        case .longTasks: return 240
        }
    }

    var color: String {
        switch self {
        case .quickWins: return "green"
        case .shortTasks: return "blue"
        case .mediumTasks: return "orange"
        case .longTasks: return "purple"
        }
    }

    static func from(minutes: Int, thresholds: (quick: Int, short: Int, medium: Int, long: Int)) -> TimeCategory {
        if minutes < thresholds.quick {
            return .quickWins
        } else if minutes < thresholds.short {
            return .shortTasks
        } else if minutes < thresholds.medium {
            return .mediumTasks
        } else if minutes < thresholds.long {
            return .longTasks
        } else {
            return .longTasks
        }
    }
}