//
//  EditNameViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 2/28/21.
//

import Foundation
import UIKit
import CoreData

class EditNameViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var nameField: UITextField!
    @IBOutlet var doneEditButton: UIButton!
    
    var userStore = [UserEntity]()
    
    // Custom check function
    public var completion: ((String) -> Void)?
    
    //  Access databse functions
//    func getUser() -> [String: Any] {
//        let user = DataBaseHelper.shareInstance.fetchLocalUser()
//
//        // Unpack user entity to dictionary
//        var endUser = [String:Any]()
//        for x in user as [UserEntity] {
//            endUser["name"] = x.name
//            endUser["email"] = x.email
//            endUser["darkMode"] = x.darkMode
//            endUser["notification"] = x.notification
//            endUser["sound"] = x.sound
//        }
//
//        return endUser
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        let user = getUser()
        let user = DataBaseHelper.shareInstance.parsedLocalUser()
        
        nameField.text = user["name"] as! String
        nameField.returnKeyType = .done
        nameField.autocapitalizationType = .words
        nameField.autocorrectionType = .no
        nameField.becomeFirstResponder()
        nameField.delegate = self
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
    
    @IBAction func buttonTapped() {
        nameField.resignFirstResponder()
        // Save stuff here?
        if nameField.text?.count ?? 0 <= 0 {
            let dialogMessage = UIAlertController(title: "", message: "Name must be more than 0 characters", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button 0 characters tapped")
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else if nameField.text?.count ?? 21 > 20 {
            let dialogMessage = UIAlertController(title: "", message: "Name cannot be more than 20 characters", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button 20 characters tapped")
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else if let name = nameField.text {
            print("Text is \(name)")
            // Update name here
            let dialogMessage = UIAlertController(title: "", message: "Saved Changes", preferredStyle: .alert)
            self.present(dialogMessage, animated: true, completion: nil)
            let when = DispatchTime.now() + .seconds(1)
            DispatchQueue.main.asyncAfter(deadline: when) {
                dialogMessage.dismiss(animated: true, completion: nil)
            }
            DispatchQueue.main.async {
//                let user = self.getUser()
                let user = DataBaseHelper.shareInstance.parsedLocalUser()
                // Update Name based on email
                DataBaseHelper.shareInstance.updateName(name: name, email: user["email"] as! String)
                DataBaseHelper.shareInstance.updateNameDB(name: name, email: user["email"] as! String)
//                self.getUser()
                DataBaseHelper.shareInstance.parsedLocalUser()
                self.navigationController?.popViewController(animated: true)
                
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        // Save stuff here?
        if let name = nameField.text {
            print("Text is \(name)")
            // Update name here
            
            DispatchQueue.main.async {
//                let user = self.getUser()
                let user = DataBaseHelper.shareInstance.parsedLocalUser()
                // Update Name based on email
                DataBaseHelper.shareInstance.updateName(name: name, email: user["email"] as! String)
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        return true
    }
}
