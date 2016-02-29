//
//  Reminder.swift
//  DemoReminder
//
//  Created by Spencer Gennari on 2/20/16.
//  Copyright © 2016 money-apps. All rights reserved.
//

import UIKit

class Reminder: NSObject {
    
    var uuid : String
    var title : String
    var desc : String
    var date : NSDate
    
    let dateFormatter = NSDateFormatter()
    
    init(title : String, desc : String, date : NSDate) {
        self.uuid = NSUUID().UUIDString
        self.title = title
        self.desc = desc
        self.date = date
        
        dateFormatter.dateFormat = "HH:mm MM-dd-yyyy GGG"
    }
    
    func getFormattedDateString() -> String {
        return dateFormatter.stringFromDate(self.date)
    }

    func scheduleLocalNotification(){
        // Schedule local notification
        
        // If the date is in the past, set it to 1 second in the future
        // This solves a bug where the AppDelegate will attempt to show the UIAlertController on the wrong root view
        //  due to a race condition
        var fireDate = self.date
        let comparisonResult = self.date.compare(NSDate())
        if comparisonResult == NSComparisonResult.OrderedAscending {
            fireDate = NSDate().dateByAddingTimeInterval(1)
        }
        
        let reminderNotification = UILocalNotification()
        reminderNotification.fireDate = fireDate
        reminderNotification.alertTitle = self.title
        reminderNotification.alertBody = self.desc
        let userInfoDict = [
            "uuid" : self.uuid
        ]
        reminderNotification.userInfo = userInfoDict
        UIApplication.sharedApplication().scheduleLocalNotification(reminderNotification)
    }
    
}
