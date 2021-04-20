//
//  SharedInviteViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 4/13/21.
//

import UIKit

class SharedInviteViewController: UIViewController {

    @IBOutlet weak var InviteTable: UITableView!
    
    var inviteStore = [SharedEntity]()
    
    func getInvites() {
        DataBaseHelper.shareInstance.fetchInvites(completion: {
          invite in
          if invite != nil {
              self.inviteStore = invite
              print("InvitesInvites")
              print(self.inviteStore)
              self.InviteTable.reloadData()
          }
      })
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
        getInvites()
        // Do any additional setup after loading the view.
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

}

extension SharedInviteViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SharedInviteViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return inviteStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "invite", for: indexPath)
        cell.textLabel?.text = inviteStore[indexPath.row].taskList
        cell.detailTextLabel?.text = inviteStore[indexPath.row].email
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SharedInviteViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.inviteStore[indexPath.row]
            print("TITLEEEEE \(row.taskList)")
            let title = row.taskList!
            let email = row.email!
            let id = row.lid!
            // DataBaseHelper.shareInstance.deleteList(id: row.id!)
            
//            DataBaseHelper.shareInstance.removeSharedEmail(lid: self.lid!, email: row as! String)
            
            DataBaseHelper.shareInstance.removeSharedEntityDB(lid: row.lid!, sharedBy: row.email!, completion: {success in
                if success {
                    DataBaseHelper.shareInstance.removedSharedLocal(title: title, owner: email, id: id,  completion: {success in
                        if success {
                            print("Success")
//                            self.navigationController?.popToRootViewController(animated: true)
                        }
                    })
                }
            })
            
            DataBaseHelper.shareInstance.declineInvite(lid: id) 
            
            self.getInvites()
            
        }
        // TODO: Change to X button image
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            //QUESTION????? should this be intersectoin?
            let row = self.inviteStore[indexPath.row]
            
//            DataBaseHelper.shareInstance.updateLocalTask(id: row.id!, isDone: true)
            DataBaseHelper.shareInstance.acceptInvite(id: row.id!, lid: row.lid!)
            self.getInvites()
        }
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = .systemGreen
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
}
