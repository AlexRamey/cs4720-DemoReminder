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
        if (difference < 3600*24)
        {
            cell.contentView.backgroundColor = self.redColor
        }
        else if (difference < 3600 * 24 * 3)
        {
            cell.contentView.backgroundColor = self.yellowColor
        }
        else
        {
            cell.contentView.backgroundColor = self.greenColor
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
        reminderList.removeAtIndex(indexPath.row)
        tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
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
        } else if segue.identifier == "AddReminder" {
            print("Adding new reminder")
        }

    }
    
    @IBAction func unwindToTableView(sender: UIStoryboardSegue) {
        // Downcast sourceViewController to AddViewController and get the reminder object
        if let sourceViewController = sender.sourceViewController as? AddViewController, reminder = sourceViewController.reminder {
            
            // Check if a row is selected
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                // Update item at the selected index
                print("selected index: \(selectedIndexPath.row)")
                reminderList[selectedIndexPath.row] = reminder
            } else {
                // Add new item to the list
                reminderList.append(reminder)
            }
            // Always re-sort and update the data
            reminderList.sortInPlace(sortByTime)
            tableView.reloadData()
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
        print(uuid)
    }
    
    func dismissReminder(uuid: String) {
        
    }


}
