//
//  EditViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/4/21.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {

    var titleStr: String?
    
    var dateVal: Date?
    
    var bodyStr: String?
    
    var topicStr: String?
    
    var priority: Int?
    
    var currentTopic: String?
    
    var currentPriority: Int?
    
    var noTopics: [String] = [String]()
    
    @IBOutlet var titleField: UITextField!
    
    @IBOutlet var dateField: UIDatePicker!
    
    @IBOutlet var bodyField: UITextField!
    
    @IBOutlet var topicPicker: UIPickerView!
    
    @IBOutlet var priorityPicker: UIPickerView!
    
    var topicPickerData: [String] = [String]()
    var priorityPickerData: [String] = [String]()
    
    public var completion: ((String, String, Date, String, Int16, String) -> Void)?
    
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

        titleField.text = titleStr
        dateField.date = dateVal!
        bodyField.text = bodyStr
        titleField.delegate = self
        bodyField.delegate = self
        
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
        if topicPickerData.count > 1 {
            var row = 0
            for i in 0..<topicPickerData.count {
                if topicPickerData[i] == topicStr {
                    row = i
                    break
                }
            }
            topicPicker.selectRow(row, inComponent: 0, animated: true)
            currentTopic = topicStr
        }
        
        priorityPicker.delegate = self
        priorityPicker.dataSource = self
        priorityPickerData.insert("None", at: 0)
        priorityPickerData.insert("(!) Low Priority", at: 1)
        priorityPickerData.insert("(!!) Medium Priority", at: 2)
        priorityPickerData.insert("(!!!) High Priority", at: 3)
        priorityPicker.selectRow(priority!, inComponent: 0, animated: true)
        
        noTopics = ["None"]
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self.description, action: #selector(didTapSaveButton))

        // Do any additional setup after loading the view.
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
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = dateField.date
            if noTopics.contains(currentTopic!) {
                currentTopic = ""
            }
            let selectedValue = topicPickerData[topicPicker.selectedRow(inComponent: 0)]
            let selectedPriorityValue = priorityPicker.selectedRow(inComponent: 0)
            
            let made = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"
            let madeDate = dateFormatter.string(from: made)
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
            
            completion?(titleText, bodyText, targetDate, selectedValue, Int16(selectedPriorityValue), madeDate)
            print("Saved")
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
