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
    
    override func viewDidLoad() {
        super.viewDidLoad()


        
        //bodyField.text = bodyStr
        titleStr = task?.title
        dateVal = task?.date
        bodyStr = task?.body
        topicStr = task?.color
        priorityVal = Int(task!.priority)
        madeVal = task?.made
        
        titleField.text = titleStr
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateField.text = formatter.string(from: self.dateVal!)
        bodyField.text = bodyStr! + "\(task?.list)"
        if (topicStr != nil && !topicStr!.isEmpty) {
            topicField.text = "Topic: " + topicStr!
        }
        else {
            topicField.text = topicStr
        }
        if (priorityVal == 0) {
            priorityField.text = ""
        } else if (priorityVal == 1) {
            priorityField.text = "Priority: Low"
        } else if (priorityVal == 2) {
            priorityField.text = "Priority: Medium"
        } else {
            priorityField.text = "Priority: High"
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
                self.titleField.text = title
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY"
                self.dateField.text = formatter.string(from: date)
                self.bodyField.text = body
                self.topicField.text = color
                self.madeVal = made
                /*DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false)*/
                if (priority == 0) {
                    self.priorityField.text = ""
                } else if (priority == 1) {
                    self.priorityField.text = "Priority: Low"
                } else if (priority == 2) {
                    self.priorityField.text = "Priority: Medium"
                } else {
                    self.priorityField.text = "Priority: High"
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
