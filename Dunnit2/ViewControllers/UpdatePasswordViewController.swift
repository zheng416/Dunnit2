//
//  UpdatePasswordViewController.swift
//  Dunnit2
//
//  Created by Peter Zheng on 3/17/21.
//

import Foundation

import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

//self.updateUserPassword(email: "zheng460@purdue.edu", password: "123456@a", newpassword: "123456@b")

class UpdatePasswordViewController: UIViewController {

    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
     {
    oriPassField.resignFirstResponder()
    newPassField1.resignFirstResponder()
    newPassField1.resignFirstResponder()
            return true;
    }

    @IBOutlet weak var oriPassField: UITextField!
    @IBOutlet weak var newPassField1: UITextField!
    @IBOutlet weak var newPassField2: UITextField!
    func getUser() -> [String: Any] {
        var user = DataBaseHelper.shareInstance.fetchUser()
        if user.isEmpty{
            DataBaseHelper.shareInstance.createNewUser(name: "test", email:"test@email.com")
            user = DataBaseHelper.shareInstance.fetchUser()
        }
        
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
    func checkError(error : Error?,message: String)->Bool{
        if let error = error{
            print("error \(message) \(error)\n")
            return true
        }
        else {
            print("successfully \(message)\n")
            return false
        }
    }

    func reSignin(email:String, password:String,completion: @escaping (_ message: Bool) -> Void){
        Auth.auth().signIn(withEmail: email, password: password) { [weak self] authResult, error in
            guard let strongSelf = self else { completion(false); return}
            completion(true)
        }
    }
    func updateUserPassword(email:String, password: String,newpassword:String){
        reSignin(email: email, password: password, completion:{ result in
            if (result){
                let user = Auth.auth().currentUser

                user?.updatePassword(to: newpassword, completion: {error in
                    if self.checkError(error: error,message: "Update user password") {
                        return
                    }
                })
            }
            else {
                print("Authetication failed")
            }
        })
    }
    @IBAction func confButtonPress(_ sender: UIButton) {
        let oriPass = oriPassField.text!
        let newPass1 = newPassField1.text!
        let newPass2 = newPassField2.text!
        let user = self.getUser();
        let email = user["email"] as! String
        if (newPass1 == newPass2){
            updateUserPassword(email: email, password: oriPass, newpassword: newPass1)
        }
        else{
            print("Two passwords do not match")
        }
        
    }
}

