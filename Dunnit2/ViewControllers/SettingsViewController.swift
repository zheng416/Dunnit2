//
//  SettingsViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 2/25/21.
//
import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var soundToggle: UISwitch!
    @IBOutlet weak var notificationsToggle: UISwitch!
    @IBOutlet weak var darkModeToggle: UISwitch!
    
    var userStore = [UserEntity]()
    var globalUser = [String: Any]()
    
    //  Access databse functions
    func getUser() -> [String: Any] {
        let user = DataBaseHelper.shareInstance.fetchUser()
        
        // Unpack user entity to dictionary
        var endUser = [String:Any]()
        for x in user as [UserEntity] {
            endUser["name"] = x.name
            endUser["email"] = x.email
            endUser["darkMode"] = x.darkMode
            endUser["notifications"] = x.notifications
            endUser["sound"] = x.sound
        }
        
        print("user is \(endUser)")
        
        return endUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = getUser()
        globalUser = user
        
        nameLabel.text =  user["name"] as! String
        emailLabel.text = user["email"] as! String
        soundToggle.isOn = user["sound"] as! Bool
        notificationsToggle.isOn = user["notifications"] as! Bool
        darkModeToggle.isOn = user["darkMode"] as! Bool
    }
    
    @IBAction func toggleSound(){
        if soundToggle.isOn {
            DataBaseHelper.shareInstance.updateSound(soundOn: true, email: globalUser["email"] as! String)
        } else {
            DataBaseHelper.shareInstance.updateSound(soundOn: false, email: globalUser["email"] as! String)
        }
        
        globalUser = self.getUser()
    }
    
    @IBAction func toggleNotifications(){
        if notificationsToggle.isOn {
            DataBaseHelper.shareInstance.updateNotifications(notificationsOn: true, email: globalUser["email"] as! String)
        } else {
            DataBaseHelper.shareInstance.updateNotifications(notificationsOn: false, email: globalUser["email"] as! String)
        }
        
        globalUser = self.getUser()
    }
    
    @IBAction func toggleDark(){
        if darkModeToggle.isOn {
            DataBaseHelper.shareInstance.updateDark(darkMode: true, email: globalUser["email"] as! String)
        } else {
            DataBaseHelper.shareInstance.updateDark(darkMode: false, email: globalUser["email"] as! String)
        }
        
        globalUser = self.getUser()
    }

}
