//
//  MenuViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/1/21.
//

import UIKit

enum MenuType: Int {
    case all
    case shared
    case myList
    case progress
    case calendar
    case settings
}

class MenuViewController: UITableViewController {
    
    var didTapMenuType: ((MenuType) -> Void)?

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
        // Do any additional setup after loading the view.
        let userInfo = getUser()
        let darkModeOn = userInfo["darkMode"] as! Bool
        if darkModeOn {
            overrideUserInterfaceStyle = .dark
        } else {
            overrideUserInterfaceStyle = .light
        }
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        dismiss(animated: true) { [weak self] in
            print("Dismissing: \(menuType)")
            self?.didTapMenuType?(menuType)
        }
    }
}
