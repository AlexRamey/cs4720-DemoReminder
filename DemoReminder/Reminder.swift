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
        
        print(self.uuid)
    }
    
    func getFormattedDateString() -> String {
        return dateFormatter.stringFromDate(self.date)
    }

}
