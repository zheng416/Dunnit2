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
        
        nameField.text = user["name"] as! String
        nameField.returnKeyType = .done
        nameField.autocapitalizationType = .words
        nameField.autocorrectionType = .no
        nameField.becomeFirstResponder()
        nameField.delegate = self
    }
    
    @IBAction func buttonTapped() {
        nameField.resignFirstResponder()
        // Save stuff here?
        if nameField.text?.count ?? 0 <= 0 {
            let dialogMessage = UIAlertController(title: "", message: "Password must be more than 0 characters", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                print("Ok button 0 characters tapped")
            })
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
        }
        else if nameField.text?.count ?? 21 > 20 {
            let dialogMessage = UIAlertController(title: "", message: "Password cannot be more than 20 characters", preferredStyle: .alert)
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
                // TODO: Add routing after hit done
                
                // Create a new user should be used in create account
    
                let user = self.getUser()
                // Update Name based on email
                DataBaseHelper.shareInstance.updateName(name: name, email: user["email"] as! String)
            }
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        nameField.resignFirstResponder()
        // Save stuff here?
        if let text = nameField.text {
            print("Text is \(text)")
            // Update name here
        }
        return true
    }
}
