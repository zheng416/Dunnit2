//
//  SharingViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/12/21.
//

import UIKit

class SharingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet weak var sharedEmails: UITableView!
    
    var emailStore = Array<Any>()
    
    var lid: String?
    
    public var completion: ((String) -> Void)?
    
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
    
    func getData() {
        DataBaseHelper.shareInstance.fetchSharedEmails(lid: lid!, completion: { share in
            if share != nil {
                print("GIT TTTTTT")
                self.emailStore = share
                self.sharedEmails.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapShareButton))
        
        getData()

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
    
    @objc func didTapShareButton() {
        
        if let emailText = emailField.text, !emailText.isEmpty {
            DataBaseHelper.shareInstance.validEmail(email: emailText, onSuccess: {success in
                if success {
                    let dialogMessage = UIAlertController(title: "", message: "Invite Sent", preferredStyle: .alert)
                    self.present(dialogMessage, animated: true, completion: nil)
                    let when = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        dialogMessage.dismiss(animated: true, completion: nil)
                        self.navigationController?.popViewController(animated: true)
                    }
                    self.completion?(emailText)
                } else {
                    let dialogMessage = UIAlertController(title: "", message: "Error: sharing failed", preferredStyle: .alert)
                    self.present(dialogMessage, animated: true, completion: nil)
                    let when = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        dialogMessage.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SharingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SharingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shareEmail", for: indexPath)
        cell.textLabel?.text = emailStore[indexPath.row] as! String
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SharingViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.emailStore[indexPath.row]
            
            // DataBaseHelper.shareInstance.deleteList(id: row.id!)
            
            DataBaseHelper.shareInstance.removeSharedEmail(lid: self.lid!, email: row as! String)
            
            self.getData()
            
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
