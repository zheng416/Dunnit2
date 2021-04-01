//
//  AddViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/23/21.
//

import UIKit
import UserNotifications


class AddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var currentTopic: String?
    var currentPriority: Int?
    var noSelection: [String] = [String]()
    
    var notificationsOn: Bool?
    
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var topicPicker: UIPickerView!
    @IBOutlet weak var priorityPicker: UIPickerView!
    
    var topicPickerData: [String] = [String]()
    var priorityPickerData: [String] = [String]()
    
    public var completion: ((String, String, Date, String, Int16, String) -> Void)?
    
    func getUser() -> [String: Any] {
        var user = DataBaseHelper.shareInstance.fetchLocalUser()
        if user.isEmpty{
            DataBaseHelper.shareInstance.createNewUser(name: "test", email:"test@email.com")
            user = DataBaseHelper.shareInstance.fetchLocalUser()
        }
        
        // Unpack user entity to dictionary
        var endUser = [String:Any]()
        for x in user as [UserEntity] {
            endUser["name"] = x.name
            endUser["email"] = x.email
            endUser["darkMode"] = x.darkMode
            endUser["notification"] = x.notification
            endUser["sound"] = x.sound
        }
        
        print("user is \(endUser)")
        
        return endUser
    }
    
    func getTopics() -> [String: Any] {
        let user = DataBaseHelper.shareInstance.fetchTopics()
        print(user)
        var endUser = [String:Any]()
        for x in user as [TopicEntity] {
            endUser["red"] = x.red
            endUser["orange"] = x.orange
            endUser["yellow"] = x.yellow
            endUser["green"] = x.green
            endUser["blue"] = x.blue
            endUser["purple"] = x.purple
            endUser["indigo"] = x.indigo
            endUser["teal"] = x.teal
            endUser["pink"] = x.pink
            endUser["black"] = x.black
        }
        return endUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = getUser()
        notificationsOn = user["notification"] as! Bool
        
        titlefield.delegate = self // rid of keyboard
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))

        // Do any additional setup after loading the view.
        
        topicPicker.delegate = self
        topicPicker.dataSource = self
        topicPickerData = []
        let topics = getTopics()
        for (color, topics) in topics {
            if !((topics as! String).isEmpty) {
                topicPickerData.append(topics as! String)
            }
        }
        topicPickerData.sort()
        topicPickerData.insert("None", at: 0)
        
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        priorityPickerData.insert("None", at: 0)
        priorityPickerData.insert("(!) Low Priority", at: 1)
        priorityPickerData.insert("(!!) Medium Priority", at: 2)
        priorityPickerData.insert("(!!!) High Priority", at: 3)
        
        noSelection = ["None"]
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return topicPickerData.count
        } else {
            return priorityPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            currentTopic = topicPickerData[row]
            return topicPickerData[row]
        } else {
            currentPriority = row
            return priorityPickerData[row]
        }
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titlefield.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            if noSelection.contains(currentTopic!) {
                currentTopic = ""
            }
            let made = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"
            let madeDate = dateFormatter.string(from: made)
            if notificationsOn! {
                let content = UNMutableNotificationContent()
                content.title = "Deadline: " + titleText
                content.sound = .default
                content.body = bodyText
                let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: targetDate), repeats: false)
                let request = UNNotificationRequest(identifier: madeDate, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("error for adding notification")
                    }
                })
            }
            
            let selectedTopicValue = topicPickerData[topicPicker.selectedRow(inComponent: 0)]
            let selectedPriorityValue = priorityPicker.selectedRow(inComponent: 0)
            completion?(titleText, bodyText, targetDate, selectedTopicValue, Int16(selectedPriorityValue), madeDate)
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
