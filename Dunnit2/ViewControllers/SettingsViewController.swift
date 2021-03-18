//
//  SettingsViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 2/25/21.
//
import Foundation
import UIKit
import FirebaseAuth
import GoogleSignIn
import FBSDKLoginKit

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
    
    func loadLabelValues() {
//        if (DataBaseHelper.shareInstance.checkIfUserExists() == false) {
//            DataBaseHelper.shareInstance.createNewUser(name: "Andrew", email: "andrew123@gmail.com")
//        }
        
        let user = getUser()
        if user.isEmpty{
            print("user is empty")
            return
        }
        globalUser = user

        nameLabel.text =  user["name"] as? String
        emailLabel.text = user["email"] as? String
        soundToggle.isOn = user["sound"] as! Bool
        notificationsToggle.isOn = user["notifications"] as! Bool
        darkModeToggle.isOn = user["darkMode"] as! Bool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadLabelValues()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadLabelValues()
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
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//        print("selected row is :\(indexPath)")
        
        // Hardcoded rowIndex
        let logoutIndex = [4,0] as IndexPath
        let verifyEmailIndex = [1,2] as IndexPath
        
        if (indexPath == logoutIndex) {
            print("Logout?")
            let dialogMessage = UIAlertController(title: "", message: "Would you like to logout?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "OK", style: .default) {
                UIAlertAction in
                // Clear storage
                DataBaseHelper.shareInstance.logout(email: self.globalUser["email"] as! String)
                
                // Clear local firebase auth
                do {
                    try Auth.auth().signOut()
                    GIDSignIn.sharedInstance().signOut()
                    let loginManager = LoginManager()
                    loginManager.logOut() // this is an instance function
                    //TODO: FB Sign in still working?
                    
                } catch let signOutError as NSError {
                  print ("Error signing out: %@", signOutError)
                }
                
                // Redirect to login page
                let loginStory = UIStoryboard(name: "Main", bundle: nil)
                let startVC = loginStory.instantiateViewController(withIdentifier: "welcome")
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
                sceneDelegate.window?.rootViewController = startVC
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        } else if (indexPath == verifyEmailIndex){
            print("Verify Email Button Pressed!")
            
            
            let dialogMessage = UIAlertController(title: "", message: "Would you like to verify your email?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Yes", style: .default) {
                UIAlertAction in
                // TODO: Verification for peter? Not sure what else to add here
                print("Ok button pressed")
                
                
            }
            let cancel = UIAlertAction(title: "No", style: .cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
            
        }
    }

}
