//
//  TableViewController.swift
//  DemoReminder
//
//  Created by Spencer Gennari on 2/20/16.
//  Copyright © 2016 money-apps. All rights reserved.
//

import UIKit

class TableViewController: UITableViewController {
    
    let cellReuseIdentifier = "ReminderCell"
    var reminderList = [Reminder]()
    var selectedReminder : Reminder? = nil
    
    // iOS9 colors
    let redColor = UIColor(colorLiteralRed: 250.0/255.0, green: 59.0/255.0, blue: 49.0/255.0, alpha: 1.0)
    let yellowColor = UIColor(colorLiteralRed: 253.0/255.0, green: 205.0/255.0, blue: 0.0, alpha: 1.0)
    let greenColor = UIColor(colorLiteralRed: 76.0/255.0, green: 218.0/255.0, blue: 100.0/255.0, alpha: 1.0)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let nibName = UINib(nibName: "ReminderTableViewCell", bundle:nil)
        self.tableView.registerNib(nibName, forCellReuseIdentifier: cellReuseIdentifier)
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reminderList.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellReuseIdentifier, forIndexPath: indexPath) as! ReminderTableViewCell

        let reminder = reminderList[indexPath.row]
        
        cell.titleView.text = reminder.title
        cell.dateView.text = reminder.getFormattedDateString()

        let difference = reminder.date.timeIntervalSinceNow
        if (difference < 60 * 5)
        {
            cell.dateView.textColor = self.redColor
        }
        else if (difference < 3600)
        {
            cell.dateView.textColor = self.yellowColor
        }
        else
        {
            cell.dateView.textColor = self.greenColor
        }
        
        return cell
    }
    
    // Trigger the ShowReminderDetail segue when a cell is selected
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.performSegueWithIdentifier("ShowReminderDetail", sender: indexPath)
    }
    

    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }

    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        
        // Have delete always available as a swipe option
        // Delete the row from the reminder list
        let removedReminder = reminderList.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        
        // Cancel the corresponding notification
        let sharedApp = UIApplication.sharedApplication()
        for notification in sharedApp.scheduledLocalNotifications! {
            let notificationUUID = notification.userInfo!["uuid"] as! String
            if (notificationUUID  == removedReminder.uuid) {
                sharedApp.cancelLocalNotification(notification)
            }
        }
        
        //----
        let count = UIApplication.sharedApplication().scheduledLocalNotifications!.count
        print("Notifications: \(count)")
    }

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if segue.identifier == "ShowReminderDetail" {
            let controller = segue.destinationViewController as! AddViewController
            let row = (sender as! NSIndexPath).row
            let reminder = reminderList[row]
            controller.reminder = reminder
            selectedReminder = reminder
            print("Editing reminder \(reminder.uuid)")
        } else if segue.identifier == "AddReminder" {
            print("Adding new reminder")
        }

    }
    
    @IBAction func unwindToTableView(sender: UIStoryboardSegue) {
        // Downcast sourceViewController to AddViewController and get the reminder object
        if let sourceViewController = sender.sourceViewController as? AddViewController, reminder = sourceViewController.reminder {
            
            // Check if a row is selected
            if (selectedReminder != nil) {
                // NOTE: Do NOT use index to update table because items could have been deleted
                
                // Cancel notification for old reminder
                let sharedApp = UIApplication.sharedApplication()
                for notification in sharedApp.scheduledLocalNotifications! {
                    let notificationUUID = notification.userInfo!["uuid"] as! String
                    if notificationUUID  == selectedReminder!.uuid {
                        sharedApp.cancelLocalNotification(notification)
                        break
                    }
                }
                
                // Update the selected reminder
                for var index = 0; index < reminderList.count; index++ {
                    if reminderList[index].uuid == selectedReminder!.uuid {
                        reminderList[index] = reminder
                        break
                    }
                }
                
                // Set selectedReminder to nil
                selectedReminder = nil
            } else {
                // Add new item to the list
                reminderList.append(reminder)
            }
            // Always re-sort and update the data
            reminderList.sortInPlace(sortByTime)
            tableView.reloadData()
            
            //----
            let count = UIApplication.sharedApplication().scheduledLocalNotifications!.count
            print("Notifications: \(count)")
        }
    }
    
    func sortByTime(lhs: Reminder, rhs: Reminder) -> Bool {
        let comparisonResult = lhs.date.compare(rhs.date)
        if comparisonResult == NSComparisonResult.OrderedSame {
            return (lhs.title.compare(rhs.title) == NSComparisonResult.OrderedAscending)
        }
        return (comparisonResult == NSComparisonResult.OrderedAscending)
    }
    
    func postponeReminder(uuid: String) {
        // NOTE: Notification activated, so no need to cancel it
        
        for reminder in reminderList {
            // Find reminded with specified UUID
            if (reminder.uuid == uuid) {
                // Update current time by 1 hr
                reminder.date = reminder.date.dateByAddingTimeInterval(60 * 60)
                
                // Schedule a new notification
                let reminderNotification = UILocalNotification()
                reminderNotification.fireDate = reminder.date
                reminderNotification.alertTitle = reminder.title
                reminderNotification.alertBody = reminder.desc
                let userInfoDict = [
                    "uuid" : reminder.uuid
                ]
                reminderNotification.userInfo = userInfoDict
                UIApplication.sharedApplication().scheduleLocalNotification(reminderNotification)
                
                //----
                let count = UIApplication.sharedApplication().scheduledLocalNotifications!.count
                print("Notifications: \(count)")
                
                // Always re-sort and update the data
                reminderList.sortInPlace(sortByTime)
                tableView.reloadData()
            }
        }
        print(uuid)
    }
    
    func dismissReminder(uuid: String) {
        // NOTE: Notification activated, so no need to cancel it
        
        // Use a filter to remove the Reminder from the list
        reminderList = reminderList.filter() {$0.uuid != uuid}
        
        //----
        let count = UIApplication.sharedApplication().scheduledLocalNotifications!.count
        print("Notifications: \(count)")
        
        // Update the table
        tableView.reloadData()
    }


}
