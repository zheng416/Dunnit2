//
//  EditTopicsViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/12/21.
//

import Foundation
import UIKit
import CoreData

class EditTopicsViewController: UITableViewController, UITextFieldDelegate {
    @IBOutlet var redTopic: UITextField!
    @IBOutlet var orangeTopic: UITextField!
    @IBOutlet var yellowTopic: UITextField!
    @IBOutlet var greenTopic: UITextField!
    @IBOutlet var blueTopic: UITextField!
    @IBOutlet var purpleTopic: UITextField!
    @IBOutlet var indigoTopic: UITextField!
    @IBOutlet var tealTopic: UITextField!
    @IBOutlet var pinkTopic: UITextField!
    @IBOutlet var blackTopic: UITextField!
    
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
        self.title = "Add / Edit Topics"
        
//        let user = getUser()
        let user = DataBaseHelper.shareInstance.parsedLocalUser()
        let topics = getTopics()
        redTopic.text = topics["red"] as? String
        orangeTopic.text = topics["orange"] as? String
        yellowTopic.text = topics["yellow"] as? String
        greenTopic.text = topics["green"] as? String
        blueTopic.text = topics["blue"] as? String
        purpleTopic.text = topics["purple"] as? String
        indigoTopic.text = topics["indigo"] as? String
        tealTopic.text = topics["teal"] as? String
        pinkTopic.text = topics["pink"] as? String
        blackTopic.text = topics["black"] as? String
        
        print(topics)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(didTapSaveButton))
        let userInfo = getUser()
        let darkModeOn = userInfo["darkMode"] as! Bool
        if darkModeOn {
            overrideUserInterfaceStyle = .dark
            navigationController?.navigationBar.barTintColor = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        } else {
            overrideUserInterfaceStyle = .light
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            
        }
    }
    
    @objc func didTapSaveButton() {
        print("LOL")
        if redTopic.text == nil {
            redTopic.text = ""
        }
        print(redTopic.text)
        if orangeTopic.text == nil {
            orangeTopic.text = ""
        }
        if yellowTopic.text == nil {
            yellowTopic.text = ""
        }
        if greenTopic.text == nil {
            greenTopic.text = ""
        }
        if blueTopic.text == nil {
            blueTopic.text = ""
        }
        if purpleTopic.text == nil {
            purpleTopic.text = ""
        }
        if indigoTopic.text == nil {
            indigoTopic.text = ""
        }
        if tealTopic.text == nil {
            tealTopic.text = ""
        }
        if pinkTopic.text == nil {
            pinkTopic.text = ""
        }
        if blackTopic.text == nil {
            blackTopic.text = ""
        }
        DispatchQueue.main.async { [self] in
//            let user = self.getUser()
            let user = DataBaseHelper.shareInstance.parsedLocalUser()
            
            // Update Name based on email
            if getTopics().isEmpty {
                DataBaseHelper.shareInstance.saveTopics(red: self.redTopic.text!, orange: self.orangeTopic.text!, yellow: self.yellowTopic.text!, green: self.greenTopic.text!, blue: self.blueTopic.text!, purple: self.purpleTopic.text!, indigo: self.indigoTopic.text!, teal: self.tealTopic.text!, pink: self.pinkTopic.text!, black: self.blackTopic.text!)
            }
            else {
                print("ALREADY EXISTS")
                DataBaseHelper.shareInstance.updateTopic(email: user["email"] as! String, red: self.redTopic.text!, orange: self.orangeTopic.text!, yellow: self.yellowTopic.text!, green: self.greenTopic.text!, blue: self.blueTopic.text!, purple: self.purpleTopic.text!, indigo: self.indigoTopic.text!, teal: self.tealTopic.text!, pink: self.pinkTopic.text!, black: self.blackTopic.text!)
            }
            self.navigationController?.popViewController(animated: true)
        }
    }
}

