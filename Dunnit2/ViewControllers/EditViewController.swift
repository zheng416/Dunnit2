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
    var listDic:[Int:(id:String,title:String)] = [Int:(String,String)]()
    var task:TaskEntity?
    var currentListIndex:Int?
    var currentTopic: String?
    
    var currentPriority: Int?
    
    var notificationsOn: Bool?
    
    var noTopics: [String] = [String]()

    @IBOutlet var titleField: UITextField!
    
    @IBOutlet var dateField: UIDatePicker!
    
    @IBOutlet var bodyField: UITextField!
    
    @IBOutlet var topicPicker: UIPickerView!
    
    @IBOutlet var priorityPicker: UIPickerView!
    @IBOutlet weak var listPicker: UIPickerView!
    
    var topicPickerData: [String] = [String]()
    var priorityPickerData: [String] = [String]()
    var listPickerData: [String] = [String]()
  
    public var completion: ((String, String, Date, String, Int16, String) -> Void)?
    
    func getList() -> Void {
        let lists = DataBaseHelper.shareInstance.fetchLists()
        var i = 0
        for x in lists as [ListEntity] {
            listDic[i] = (x.id!,x.title!)
            i+=1
        }
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        


        
        topicPicker.tag = 1
        priorityPicker.tag = 2
        listPicker.tag = 3

        let user = getUser()
        notificationsOn = user["notification"] as! Bool        
        
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
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didTapSaveButton))
        
        listPicker.delegate = self
        listPicker.dataSource = self
        listPickerData.removeAll()
        getList()
        var j = -1
        for i in 0...listDic.count - 1{
            listPickerData.append(listDic[i]!.title as! String)
            if task!.list == listDic[i]!.id{
                j = i
            }
        }
        if j == -1 {
            j = listDic.count
        }
        currentListIndex = j
        listDic[listDic.count] = ("","")
        listPickerData.append("N/A")
        listPicker.selectRow(j, inComponent: 0, animated: false)
        listPicker.reloadAllComponents()
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if pickerView.tag == 3 {
            currentListIndex = row
            print(listDic[row])
            print("Value changed \(currentListIndex)")
        }
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
            print("modify here \(row)" )
            print(listDic[row])
            return listPickerData[row]
      }
    }
    
    @objc func didTapSaveButton() {
        print("Save taped")
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
            
            completion?(titleText, bodyText, targetDate, selectedValue, Int16(selectedPriorityValue), madeDate)
            print("Saved")
        }
        print("index \(currentListIndex) ID , \(listDic[currentListIndex!]!.id) Task List \(task!.list) ")
        print("title \(listDic[currentListIndex!]!.title)")
        if listDic[currentListIndex!]!.id != task!.list {
            task!.list = listDic[currentListIndex!]!.id
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            let managedContext = appDelegate.persistentContainer.viewContext
            do {
                DataBaseHelper.shareInstance.updateDBTask(id: task!.id!, list:listDic[currentListIndex!]!.id )
                print("Saved.")
                try managedContext.save()
            } catch let error as NSError {
                print("Could not save. \(error), \(error.userInfo)")
            }
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
