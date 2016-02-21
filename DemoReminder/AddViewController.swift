//
//  AddViewController.swift
//  DemoReminder
//
//  Created by Spencer Gennari on 2/20/16.
//  Copyright © 2016 money-apps. All rights reserved.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: Properties
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var descriptionTextField: UITextField!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    
    // Value passed by TableViewController in segue or created as part of adding a new Reminder
    var reminder: Reminder?
    var keyboardHeight:CGFloat = 0
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        // register to be notified when keyboard is about to show by calling our keyboardWillShow: method
        NSNotificationCenter.defaultCenter().addObserver(self, selector: "keyboardWillShow:", name: UIKeyboardWillShowNotification, object: nil)
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Handle text field's user input via delegate callback
        titleTextField.delegate = self
        descriptionTextField.delegate = self

        // Do any additional setup after loading the view.
        if let reminder = reminder {
            navigationItem.title = "Edit Reminder"
            titleTextField.text = reminder.title
            descriptionTextField.text = reminder.desc
            datePicker.setDate(reminder.date, animated: true)
        }
        
        checkValidInput()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Respond to notification from notification center that keyboard is about to show
    func keyboardWillShow(notification:NSNotification) {
        print("notified")
        // we only care if it's the description field b/c keyboard covers it up
        if (descriptionTextField.editing){
            let userInfo:NSDictionary = notification.userInfo!
            let keyboardFrame:NSValue = userInfo.valueForKey(UIKeyboardFrameEndUserInfoKey) as! NSValue
            let keyboardRectangle = keyboardFrame.CGRectValue()
            self.keyboardHeight = keyboardRectangle.height
            self.shiftViewForKeyboardHiddenState(false)
        }
        
    }
    
    // shift the view up or down depending on if keyboard is hidden
    func shiftViewForKeyboardHiddenState(isHidden:Bool){
        UIView .animateWithDuration(0.1, animations: { () -> Void in
            self.view.frame = CGRectMake(self.view.frame.origin.x, (isHidden ? 0 : -1) * self.keyboardHeight, self.view.frame.width, self.view.frame.height)
        });
    }
    
    // MARK: UIGestureRecognizer IBAction
    
    // dismiss keyboard if user taps background
    @IBAction func tapRecieved(sender: AnyObject){
        print("tap received")
        self.view.endEditing(true)
    }
    
    // MARK: UITextFieldDelegate
    func textFieldShouldReturn(textField : UITextField) -> Bool {
        // Hide the keyboard
        textField.resignFirstResponder()
        return true
    }
    
    func checkValidInput() {
        // Disable save button if title field is empty
        let text = titleTextField.text ?? ""
        saveButton.enabled = !text.isEmpty
    }
    
    func textFieldDidBeginEditing(textField: UITextField) {
        // Disable save button while editing title
        if textField === titleTextField {
            saveButton.enabled = false
        }
    }
    
    func textFieldDidEndEditing(textField: UITextField) {
        if textField === titleTextField {
            // Validate input when user is done
            checkValidInput()
        }
        if textField == descriptionTextField{
            self.shiftViewForKeyboardHiddenState(true)
        }
    }
    
    // MARK: - Navigation
    @IBOutlet weak var cancel: UIBarButtonItem!
    @IBAction func cancel(sender: UIBarButtonItem) {
        // Check if the view is in it's own navigation controller
        let isPresentingInAddReminderMode = presentingViewController is UINavigationController
        if isPresentingInAddReminderMode {
            // Dismiss the extra nav controller for adding a view
            dismissViewControllerAnimated(true, completion: nil)
        } else {
            // Pop the view if it is on the nva controller stack
            navigationController!.popViewControllerAnimated(true)
        }
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if saveButton === sender {
            let title = titleTextField.text ?? ""
            let desc = descriptionTextField.text ?? ""
            let date = datePicker.date
            
            // Set the Reminder object to be passed to TableViewController after the unwind segue
            reminder = Reminder(title: title, desc: desc, date: date)
        }
    }
    
}
