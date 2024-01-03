//
//  Event.swift
//  YourHealthyList
//
//  Created by Андрей Соколов on 03.01.2024.
//

import Foundation

enum EventType: String, CaseIterable {
    static let type = "Type"
    
    case medicineIntake = "Medicine intake"
    case exersises = "Exersises"
   // case steps = "Steps count"
    case custom = "Custom"
    
}

enum Repetition: String, CaseIterable {
    static let repetition = "Repeat"
    
    case everyDay = "Every day"
    case everyWeek = "Every week"
    case everyTwoWeeks = "Every 2 weeks"
    case everyMonth = "Every month"
    case everyYear = "Every year"
    case custom = "Custom"
}

enum CustomRepetition: String, CaseIterable {
    static let frequency = "Frequency"
    static let everyString = "Every"
    
        case daily = "Day"
        case weekly = "Week"
        case monthly = "Month"
        case yearly = "Year"
    
    var plural: String {
        switch self {
        case .daily, .weekly, .monthly, .yearly:
            return "\(rawValue.lowercased())s"
        }
    }
    
    var frequency: String {
        switch self {
        case .weekly, .monthly, .yearly:
            return "\(rawValue)ly"
        case .daily:
            return "Daily"
        }
    }

}
    struct Event {
        let id = UUID()
        var type: EventType = EventType.allCases.first!
        var timesADay: Int = 0
        var timesADayList: [Date] = []
        var name: String? = nil
        var startDate: Date = Date()
        var endDate: Date = Date().addingTimeInterval(60 * 60 * 24)
        var repetition: Repetition = Repetition.allCases.first!
        var customRepetition: CustomRepetition? = nil
        var customRepetitionNumber: Int = 1
        var note: String? = nil
    }

