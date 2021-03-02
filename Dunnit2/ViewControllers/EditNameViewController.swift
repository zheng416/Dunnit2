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
        if let name = nameField.text {
            print("Text is \(name)")
            // Update name here
            
            DispatchQueue.main.async {
                let user = self.getUser()
                // Update Name based on email
                DataBaseHelper.shareInstance.updateName(name: name, email: user["email"] as! String)
                self.getUser()
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
                let user = self.getUser()
                // Update Name based on email
                DataBaseHelper.shareInstance.updateName(name: name, email: user["email"] as! String)
                self.getUser()
                self.navigationController?.popViewController(animated: true)
                
            }
        }
        return true
    }
}
