//
//  Date+Extensions.swift
//  hyperlocalNews
//
//  Created by Andrius Steponavicius on 27/06/2017.
//  Copyright © 2017 Andrius Steponavicius. All rights reserved.
//

import Foundation

extension Date {

    var timeStamp: String {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: Bundle.main.preferredLocalizations[0])
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter.string(from: self)
    }
    
    var timeAgoDescription:String? {
        
        let dateNow = Date()
        let interval = Calendar.current.dateComponents([.year, .month, .weekOfYear, .day, .hour, .minute, .second], from: self, to: dateNow)

        let formatter = DateComponentsFormatter()
        formatter.unitsStyle = .full
        formatter.maximumUnitCount = 1
        formatter.calendar = Calendar.current
        
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
        } else if let minute = interval.minute, minute > 0 {
            formatter.allowedUnits = [.minute]
        } else if let second = interval.second, second > 0 {
            formatter.allowedUnits = [.second]
        }else {
            return timeStamp
        }
        
        return formatter.string(from: self, to: dateNow)
    }
}



extension Int {

    var timeAgoString:String? {
        return Date(timeIntervalSince1970: Double(self)/1000).timeAgoDescription
    }
    
    var timeStamp:String {
        return Date(timeIntervalSince1970: Double(self)/1000).timeStamp
    }
}
