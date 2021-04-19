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

class UpdatePasswordViewController: UIViewController,UITextFieldDelegate {
    
    @IBOutlet weak var oriPassField: UITextField!
    @IBOutlet weak var newPassField1: UITextField!
    @IBOutlet weak var newPassField2: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
        oriPassField.delegate = self
        newPassField1.delegate = self
        newPassField2.delegate = self
        oriPassField.isSecureTextEntry = true
        newPassField1.isSecureTextEntry = true
        newPassField2.isSecureTextEntry = true
        //oriPassField.addTarget(self, action: "textFieldDidChange", for:UIControlE)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool
     {
        switch textField {
        case self.oriPassField:
            self.newPassField1.becomeFirstResponder()
        case self.newPassField1:
            self.newPassField2.becomeFirstResponder()
        default:
            newPassField2.resignFirstResponder()
        }
        return true;
    }
    
    func showMessage(message:String){
        let dialogMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
        let ok = UIAlertAction(title: "OK", style: .default) {
            UIAlertAction in
            // TODO: Verification for peter? Not sure what else to add here
            print("Ok button pressed")
            
        }
        dialogMessage.addAction(ok)
        self.present(dialogMessage, animated: true, completion: nil)
    }
//    func getUser() -> [String: Any] {
//        var user = DataBaseHelper.shareInstance.fetchLocalUser()
//        if user.isEmpty{
//            DataBaseHelper.shareInstance.createNewUser(name: "test", email:"test@email.com")
//            user = DataBaseHelper.shareInstance.fetchLocalUser()
//        }
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
//        print("user is \(endUser)")
//
//        return endUser
//    }
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
            if ((error != nil)){
                print("Sign in error", error)
                completion(false)
            }
            else{
                completion(true)
            }

        }
    }
    func updateUserPassword(email:String, password: String,newpassword:String){
        reSignin(email: email, password: password, completion:{ result in
            if (result){
                print(result)
                let user = Auth.auth().currentUser

                user?.updatePassword(to: newpassword, completion: {error in
                    if self.checkError(error: error,message: "Update user password") {
                        return
                    }
                    else{
                        self.showMessage(message: "Succesfully update the password")
                    }
                })
            }
            else {
                self.showMessage(message: "Incorrect Password")
                print("Authetication failed")
            }
        })
    }
    @IBAction func confbutton(_ sender: Any) {
        let oriPass = oriPassField.text!
        let newPass1 = newPassField1.text!
        let newPass2 = newPassField2.text!
//        let user = self.getUser();
        let user = DataBaseHelper.shareInstance.parsedLocalUser()
        let email = user["email"] as! String
        if (newPass1 == newPass2){
            updateUserPassword(email: email, password: oriPass, newpassword: newPass1)
        }
        else{
            var message = "Two passwords do not match"
            let dialogMessage = UIAlertController(title: "", message: message, preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) {
                UIAlertAction in
                print("Ok button pressed")
            }
            dialogMessage.addAction(ok)
            self.present(dialogMessage, animated: true, completion: nil)
            print("Two passwords do not match")
        }
    }
}

