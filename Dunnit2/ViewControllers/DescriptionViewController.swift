//
//  DescriptionViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/4/21.
//

import UIKit
import UserNotifications

class DescriptionViewController: UIViewController {

    var titleStr: String?
    
    var dateVal: Date?
    
    var bodyStr: String?
    
    var topicStr: String?
    
    var priorityVal: Int?
    
    var madeVal: String?
    var task: TaskEntity?
    
    @IBOutlet var titleField: UILabel!
    
    @IBOutlet var dateField: UILabel!
    
    @IBOutlet var bodyField: UILabel!
    
    @IBOutlet var topicField: UILabel!
    
    @IBOutlet var priorityField: UILabel!
    
    public var completion: ((String, String, Date, String, Int16, String) -> Void)?
    
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

        let user = getUser()
        /*let darkModeOn = user["darkMode"] as! Bool
        if darkModeOn {
            overrideUserInterfaceStyle = .dark
        }*/
        
        //bodyField.text = bodyStr
        titleStr = task?.title
        dateVal = task?.date
        bodyStr = task?.body
        topicStr = task?.color
        priorityVal = Int(task!.priority)
        madeVal = task?.made
        
        titleField.attributedText =  NSMutableAttributedString().boldTitle(titleStr!)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY HH:mm"
        dateField.attributedText =  NSMutableAttributedString().bodyNormal(formatter.string(from: self.dateVal!))
        bodyField.attributedText =  NSMutableAttributedString().bodyNormal(bodyStr!)
        if (topicStr != nil && !topicStr!.isEmpty) {
            topicField.attributedText =  NSMutableAttributedString().bodyNormal("Topic: " + topicStr!)
        }
        else {
            topicField.attributedText =  NSMutableAttributedString().bodyNormal(topicStr!)
        }
        if (priorityVal == 0) {
            priorityField.attributedText =  NSMutableAttributedString().bodyNormal("")
        } else if (priorityVal == 1) {
            priorityField.attributedText =  NSMutableAttributedString().bodyNormal("Priority: Low")
        } else if (priorityVal == 2) {
            priorityField.attributedText =  NSMutableAttributedString().bodyNormal("Priority: Medium")
        } else {
            priorityField.attributedText =  NSMutableAttributedString().bodyNormal("Priority: High")
        }
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditButton))

    }
    
    @objc func didTapEditButton(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "editTask") as? EditViewController else {
            return
        }
        vc.titleStr = self.titleStr
        vc.dateVal = self.dateVal
        vc.bodyStr = self.bodyStr
        vc.topicStr = self.topicStr
        vc.priority = self.priorityVal
        vc.task = self.task
        vc.title = "Edit"
        vc.navigationItem.largeTitleDisplayMode = .never
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(madeVal!)])
        vc.completion = {title, body, date, color, priority, made in
            DispatchQueue.main.async {
                self.titleField.attributedText =  NSMutableAttributedString().boldTitle(title)
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY HH:mm"
                self.dateField.attributedText =  NSMutableAttributedString().bodyNormal(formatter.string(from: date))
                self.bodyField.attributedText =  NSMutableAttributedString().bodyNormal(body)
                self.topicField.attributedText =  NSMutableAttributedString().bodyNormal(color)
                self.madeVal = made
                /*DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false)*/
                if (priority == 0) {
                    self.priorityField.attributedText =  NSMutableAttributedString().bodyNormal("")
                } else if (priority == 1) {
                    self.priorityField.attributedText =  NSMutableAttributedString().bodyNormal("Priority: Low")
                } else if (priority == 2) {
                    self.priorityField.attributedText =  NSMutableAttributedString().bodyNormal("Priority: Medium")
                } else {
                    self.priorityField.attributedText =  NSMutableAttributedString().bodyNormal("Priority: High")
                }
                self.completion?(title, body, date, color, priority, made)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
