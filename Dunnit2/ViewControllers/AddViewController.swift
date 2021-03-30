//
//  AddViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/23/21.
//

import UIKit


class AddViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var currentTopic: String?
    var currentListIndex: Int = 0
    var noTopics: [String] = [String]()
    
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet weak var topicPicker: UIPickerView!
    
    @IBOutlet weak var listPicker: UIPickerView!
    
    var pickerData: [String] = [String]()
    //var listPickerData: [Int:(String,String)] = [Int:(String,String)]()
    var listPickerData: [String] = [String]()
    public var completion: ((String, String, Date, String) -> Void)?
    
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlefield.delegate = self // rid of keyboard
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))

        // Do any additional setup after loading the view.
        topicPicker.tag = 1
        listPicker.tag = 2
        listPicker.delegate = self
        listPicker.dataSource = self
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
        noTopics = ["", "No Topics Available", "Add Topics in Settings"]
        listPickerData.removeAll()
        let list = getList()
        for (index, (id, title)) in list {
            if !((title as! String).isEmpty) {
                listPickerData.append(title as! String)
            }
        }
        
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
        if let titleText = titlefield.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            if noTopics.contains(currentTopic!) {
                currentTopic = ""
            }
            let selectedValue = pickerData[topicPicker.selectedRow(inComponent: 0)]
            completion?(titleText, bodyText, targetDate, selectedValue)
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
