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
    
    var userStore = [UserEntity]()
    
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
        
        return endUser
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = getUser()
        
        nameLabel.text =  user["name"] as! String
        emailLabel.text = user["email"] as! String
    }
}
