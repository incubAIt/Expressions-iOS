//
//  Date+Extensions.swift
//  hyperlocalNews
//
//  Created by Andrius Steponavicius on 27/06/2017.
//  Copyright © 2017 Andrius Steponavicius. All rights reserved.
//

import Foundation

extension Date {
    
    private static let timeAgoFormatter:DateFormatter = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Bundle.main.preferredLocalizations[0])
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    private static let dateCompononentsFormatter:DateComponentsFormatter = {
        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar = calendar
        return formatter
    }()
    
    private static let calendar:Calendar = {
        var calendar = Calendar.current
        calendar.locale = Locale(identifier:Date.locale)

        return calendar
    }()
    
    
    private static let locale = Bundle.main.preferredLocalizations.first ?? "GBP"   // TODO tidy this up a bit as it looks a little odd
    
    var timeAgoDescription:String {
        
        let interval = Date.calendar.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute], from: self, to: Date())

        let formatter = Date.dateCompononentsFormatter
        
        if let year = interval.year, year > 0 {
            formatter.allowedUnits = [.year]
        } else if let month = interval.month, month > 0 {
            formatter.allowedUnits = [.month]
        } else if let week = interval.weekOfYear, week > 0 {
            formatter.allowedUnits = [.weekOfMonth]
        } else if let day = interval.day, day > 0 {
            formatter.allowedUnits = [.day]
        } else if let hour = interval.hour, hour > 0 {
            formatter.allowedUnits = [.hour]
        } else if let minute = interval.hour, minute > 0 {
            formatter.allowedUnits = [.minute]
        } else {
            return Date.timeAgoFormatter.string(from: self)
        }
        if let string = formatter.string(from: self, to: Date()) {
            return string + " AGO"
        }
        return ""
    }
}

extension Int {

    var timeAgoString:String {
        return Date(timeIntervalSince1970: Double(self)/1000).timeAgoDescription
    }
}
