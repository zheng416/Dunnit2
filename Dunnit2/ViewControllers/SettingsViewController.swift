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
import UserNotifications

class SettingsViewController: UITableViewController {
    
    // Button and label outlets
    @IBOutlet weak var verifyEmailButton: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var soundToggle: UISwitch!
    @IBOutlet weak var verifyLabel: UILabel!
    @IBOutlet weak var notificationsToggle: UISwitch!
    @IBOutlet weak var darkModeToggle: UISwitch!
    @IBOutlet weak var logoutLabel: UILabel!
    @IBOutlet weak var logoutButton: UITableViewCell!
    
    // Initialize store
    var userStore = [UserEntity]()
    var taskStore = [[TaskEntity](), [TaskEntity]()]
    var globalUser = [String: Any]()
    var authUser = Auth.auth().currentUser
    
    func getData() {
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        
        let sortKey = user[0].sortKey
        let sortAscending = user[0].sortAscending
        let filterKey = user[0].filterKey
        
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask(key: sortKey, ascending: sortAscending, filterKey: filterKey)

        taskStore = [tasks.filter{$0.isDone == false && $0.owner == user[0].email}, tasks.filter{$0.isDone == true && $0.owner == user[0].email}]
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
    
    func verifyEmail(){
        guard let user = Auth.auth().currentUser else{
            print("no user found when trying to verify the email")
            return
        }
        user.sendEmailVerification(completion: {error in
            self.checkError(error: error, message: "sending email")
            //Force Logout
        })
    }
    
    func loadLabelValues() {
        let user = DataBaseHelper.shareInstance.parsedLocalUser()
        if user.isEmpty{
            print("user is empty")
            return
        }
        globalUser = user

        nameLabel.text =  user["name"] as? String
        emailLabel.text = user["email"] as? String
        soundToggle.isOn = user["sound"] as! Bool
        notificationsToggle.isOn = user["notification"] as! Bool
        darkModeToggle.isOn = user["darkMode"] as! Bool
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getData()
        loadLabelValues()
        globalUser = DataBaseHelper.shareInstance.parsedLocalUser()
        
        // Guest check
        if (globalUser["email"] as! String == "Guest"){
            // Change logout button text to sign up
            logoutLabel.text = "Sign Up / Login"
        } else {
            authUser = Auth.auth().currentUser
            
            if authUser!.isEmailVerified{
                verifyEmailButton.isUserInteractionEnabled = false
                emailLabel.text = "Email Verified"
                verifyLabel.text = "Email Verified"
            }
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        loadLabelValues()
    }

    @IBAction func toggleSound(){
        if soundToggle.isOn {
            print("Updating Sound")
            DataBaseHelper.shareInstance.updateLocalUser(email: globalUser["email"] as! String,sound: true )
            DataBaseHelper.shareInstance.updateDBUser(email: globalUser["email"] as! String,sound: true )
        } else {
            DataBaseHelper.shareInstance.updateLocalUser(email: globalUser["email"] as! String,sound: false )
            DataBaseHelper.shareInstance.updateDBUser(email: globalUser["email"] as! String,sound: false )
        }
        
        globalUser = DataBaseHelper.shareInstance.parsedLocalUser()
    }
    
    @IBAction func toggleNotifications(){
        if notificationsToggle.isOn {
            if taskStore[0].count >= 1 {
                for i in 0...taskStore[0].count - 1 {
                    if taskStore[0][i].notiOn {
                        let titleText = taskStore[0][i].title
                        print("Title: " + titleText!)
                        let bodyText = taskStore[0][i].body
                        let targetDate = taskStore[0][i].date!
                        let notiDate = taskStore[0][i].notiDate!
                        let madeDate = taskStore[0][i].made!
                        var currentReminder: String
                        currentReminder = "Deadline"
                        if targetDate.addingTimeInterval(TimeInterval(-15 * 60)) == notiDate {
                            currentReminder = "15 Minutes"
                        } else if targetDate.addingTimeInterval(TimeInterval(-30 * 60)) == notiDate {
                            currentReminder = "30 Minutes"
                        } else if targetDate.addingTimeInterval(TimeInterval(-60 * 60)) == notiDate {
                            currentReminder = "1 Hour"
                        } else if targetDate.addingTimeInterval(TimeInterval(-360 * 60)) == notiDate {
                            currentReminder = "6 Hours"
                        } else if targetDate.addingTimeInterval(TimeInterval(-720 * 60)) == notiDate {
                            currentReminder = "12 Hours"
                        } else if targetDate.addingTimeInterval(TimeInterval(-1440 * 60)) == notiDate {
                            currentReminder = "24 Hours"
                        }
                        let formatter = DateFormatter()
                        formatter.dateFormat = "MMM dd, YYYY HH:mm"
                        let content = UNMutableNotificationContent()
                        content.title = currentReminder + ": " + titleText!
                        content.sound = .default
                        content.body = bodyText!
                        let trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: notiDate), repeats: false)
                        let request = UNNotificationRequest(identifier: madeDate, content: content, trigger: trigger)
                        UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                            if error != nil {
                                print("error for adding notification")
                            }
                        })
                    }
                }
            }
            DataBaseHelper.shareInstance.updateLocalUser(email: globalUser["email"] as! String,notification: true )
            DataBaseHelper.shareInstance.updateDBUser(email: globalUser["email"] as! String,notification: true )
        } else {
            UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
            DataBaseHelper.shareInstance.updateLocalUser(email: globalUser["email"] as! String,notification: false )
            DataBaseHelper.shareInstance.updateDBUser(email: globalUser["email"] as! String,notification: false )
        }
        
        // update global user
        globalUser = DataBaseHelper.shareInstance.parsedLocalUser()
    }
    
    @IBAction func toggleDark(){
        if darkModeToggle.isOn {
            DataBaseHelper.shareInstance.updateLocalUser(email: globalUser["email"] as! String,darkMode: true)
            DataBaseHelper.shareInstance.updateDBUser(email: globalUser["email"] as! String,darkMode: true)
            overrideUserInterfaceStyle = .dark
            navigationController?.navigationBar.barTintColor = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        } else {
            DataBaseHelper.shareInstance.updateLocalUser(email: globalUser["email"] as! String,darkMode: false)
            DataBaseHelper.shareInstance.updateDBUser(email: globalUser["email"] as! String,darkMode: false)
            overrideUserInterfaceStyle = .light
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
        }
        
        // update global user
        globalUser = DataBaseHelper.shareInstance.parsedLocalUser()
    }
    
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// Function to handle row click
        
        // Hardcoded rowIndex
        let logoutIndex = [4,0] as IndexPath
        let verifyEmailIndex = [1,2] as IndexPath
        
        if (indexPath == logoutIndex) {
            // Logout pop up
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
            
            // Assign action to dialog
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            
            // If guest then redirect to sign in page
            if (globalUser["email"] as! String != "Guest"){
                self.present(dialogMessage, animated: true, completion: nil)
            }
            else{
                DataBaseHelper.shareInstance.logout(email: self.globalUser["email"] as! String)
                let loginStory = UIStoryboard(name: "Main", bundle: nil)
                let startVC = loginStory.instantiateViewController(withIdentifier: "welcome")
                let sceneDelegate = UIApplication.shared.connectedScenes.first?.delegate as! SceneDelegate
                sceneDelegate.window?.rootViewController = startVC
            }
            
        } else if (indexPath == verifyEmailIndex){
            // Verify Email section
            if authUser!.isEmailVerified{
                print("User already verified")
                return
            }
            
            // Verify email pop up
            let dialogMessage = UIAlertController(title: "", message: "Would you like to verify your email?", preferredStyle: .alert)
            let ok = UIAlertAction(title: "Yes", style: .default) {
                UIAlertAction in
                self.verifyEmail()
            }
            let cancel = UIAlertAction(title: "No", style: .cancel) {
                UIAlertAction in
                NSLog("Cancel Pressed")
            }
            
            // Assign action to dialog
            dialogMessage.addAction(ok)
            dialogMessage.addAction(cancel)
            self.present(dialogMessage, animated: true, completion: nil)
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        let guestFlag = globalUser["email"] as! String == "Guest"

        // Hide premium settings feature for guest users
        if (guestFlag) {
            switch section {
            case 0: return 0.0
            case 1: return 0.0
            default:
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        let guestFlag = globalUser["email"] as! String == "Guest"

        // Hide premium settings feature for guest users
        if (guestFlag) {
            switch indexPath {
            case [0,0]: return 0.0
            case [0,1]: return 0.0
            case [1,0]: return 0.0
            case [1,1]: return 0.0
            case [1,2]: return 0.0
            default:
                return UITableView.automaticDimension
            }
        } else {
            return UITableView.automaticDimension
        }

    }

}
