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
    
    var task:TaskEntity?
    var currentListIndex:Int?
    var currentTopic: String?
    var noTopics: [String] = [String]()
    var listPickerData: [String] = [String]()
    @IBOutlet var titleField: UITextField!
    
    @IBOutlet var dateField: UIDatePicker!
    
    @IBOutlet var bodyField: UITextField!
    
    @IBOutlet var topicPicker: UIPickerView!
    
    @IBOutlet weak var listPicker: UIPickerView!
    var pickerData: [String] = [String]()
    
    public var completion: ((String, String, Date, String) -> Void)?
    
    func getList() -> [Int:(String,String)] {
        let lists = DataBaseHelper.shareInstance.fetchLists()
        print(lists)
        var userdic = [Int:(String,String)]()
        var i = 0
        for x in lists as [ListEntity] {
            userdic[i] = (x.id!,x.title!)
            i+=1
        }
        return userdic
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

        titleField.text = titleStr
        dateField.date = dateVal!
        bodyField.text = bodyStr
        titleField.delegate = self
        bodyField.delegate = self
        
        topicPicker.delegate = self
        topicPicker.dataSource = self
        pickerData = []
        let topics = getTopics()
        for (color, topics) in topics {
            if !((topics as! String).isEmpty) {
                pickerData.append(topics as! String)
            }
        }
        pickerData.sort()
        pickerData.insert("", at: 0)
        if pickerData.count == 1 {
            pickerData = ["No Topics Available", "Add Topics in Settings"]
        }
        else {
            var row = 0
            for i in 0..<pickerData.count {
                if pickerData[i] == topicStr {
                    row = i
                    break
                }
            }
            topicPicker.selectRow(row, inComponent: 0, animated: true)
            currentTopic = topicStr
        }
        noTopics = ["", "No Topics Available", "Add Topics in Settings"]
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self.description, action: #selector(didTapSaveButton))
        
        listPicker.delegate = self
        listPicker.dataSource = self
        listPickerData.removeAll()
        let list = getList()
        for (index, (id, title)) in list {
            if !((title as! String).isEmpty) {
                listPickerData.append(title as! String)
            }
        }
        // Do any additional setup after loading the view.
    }
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1{
            return pickerData.count
        }
        else {
            return listPickerData.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1{
            currentTopic = pickerData[row]
            return pickerData[row]
        }
        else {
            currentTopic = listPickerData[row]
            currentListIndex = row
            return listPickerData[row]
        }
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = dateField.date
            if noTopics.contains(currentTopic!) {
                currentTopic = ""
            }
            //task!.list = listPickerData[currentListIndex!].first!
            let selectedValue = pickerData[topicPicker.selectedRow(inComponent: 0)]
            completion?(titleText, bodyText, targetDate, selectedValue)
            print("Saved")
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
