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
    var currentListIndex: Int = 0
    var noTopics: [String] = [String]()
    var list: ListEntity?
    var notificationsOn: Bool?
    
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var topicPicker: UIPickerView!
    @IBOutlet weak var priorityPicker: UIPickerView!
    @IBOutlet weak var listPicker: UIPickerView!
    @IBOutlet weak var topicLabel: UILabel!
    @IBOutlet weak var priorityLabel: UILabel!
    @IBOutlet weak var listLabel: UILabel!
    
    var topicPickerData: [String] = [String]()
    var priorityPickerData: [String] = [String]()
    //var task:TaskEntity?

    public var completion: ((String, String, Date, String, Int16, String) -> Void)?

    var pickerData: [String] = [String]()
    //var listPickerData: [Int:(String,String)] = [Int:(String,String)]()
    var listPickerData: [String] = [String]()
    var listDic:[Int:(id:String,title:String)] = [Int:(String,String)]()
    
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
            endUser["guest"] = x.guest
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
    func getList() -> Void {
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        let lists = DataBaseHelper.shareInstance.fetchLists()
        var i = 0
        
        for x in lists as [ListEntity] {
//            print("ownber \(x.owner) email \(user[0].email)")
            if (x.owner! == user[0].email!){
//                print("im in here \(user[0].email!) owner \(user[0].email!)")
                listDic[i] = (x.id!,x.title!)
                i+=1
                print("listdic \(x.id!) \(x.title!) \(listDic[i-1])")
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = getUser()
        notificationsOn = user["notification"] as! Bool
        
        titlefield.delegate = self // rid of keyboard
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        let date = datePicker.date
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        datePicker.date = modifiedDate
        // Do any additional setup after loading the view.
        
        let guest = user["guest"] as! Bool
        
        if (guest) {
            topicPicker.isHidden = true
            listPicker.isHidden = true
            priorityPicker.isHidden = true
            
            topicLabel.isHidden = true
            priorityLabel.isHidden = true
            listLabel.isHidden = true
            
        }
        
        topicPicker.tag = 1
        listPicker.tag = 3
        listPicker.delegate = self
        listPicker.dataSource = self
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
        listPickerData.removeAll()
        getList()
        print("list count \(listDic.count)")
        if listDic.count == 0{
            currentListIndex = 0
            listDic[listDic.count] = ("","")
            listPickerData.append("N/A")
            listPicker.selectRow(0, inComponent: 0, animated: false)
            listPicker.reloadAllComponents()
            return
        }
        var j = -1
        for i in 0...listDic.count - 1{
            if list != nil && list!.id == listDic[i]!.id{
                j = i
            }
            listPickerData.append(listDic[i]!.title as! String)
        }
        if j == -1 {
            j = listDic.count
        }
        currentListIndex = j
        listDic[listDic.count] = ("","")
        listPickerData.append("N/A")
        listPicker.selectRow(j, inComponent: 0, animated: false)
        listPicker.reloadAllComponents()
        
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return topicPickerData.count
        }
        else if (pickerView.tag == 2){
            return priorityPickerData.count
        } else {
          return listPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            currentTopic = topicPickerData[row]
            return topicPickerData[row]
        } else if pickerView.tag == 2  {
            currentPriority = row
            return priorityPickerData[row]
        }
      else {
            return listPickerData[row]
      }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 3 {
            currentListIndex = row
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
            DataBaseHelper.shareInstance.saveTask(title: titleText, body: bodyText, date: targetDate, isDone: false, list: listDic[currentListIndex]!.id, color: selectedTopicValue, priority: Int16(selectedPriorityValue), made: madeDate)
            completion?(titleText, bodyText, targetDate, selectedTopicValue, Int16(selectedPriorityValue), madeDate)
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
