//
//  DescriptionViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/4/21.
//

import UIKit
import UserNotifications
import MapKit

class DescriptionViewController: UIViewController {

    var titleStr: String?
    
    var dateVal: Date?
    
    var recurring: String?
    
    var bodyStr: String?
    
    var topicStr: String?
    
    var priorityVal: Int?
    
    var notifications: Bool?
    
    var notificationDate: Date?
    
    var madeVal: String?
    var task: TaskEntity?
    
    var longitude: Double?
    var latitude: Double?
    var locationName: String?
    
    // Button outlets
    @IBOutlet var titleField: UILabel!
    @IBOutlet var dateField: UILabel!
    @IBOutlet var bodyField: UILabel!
    @IBOutlet var topicField: UILabel!
    @IBOutlet var priorityField: UILabel!
    @IBOutlet var locationField: UILabel!
    @IBOutlet var mapField: MKMapView!
    
    public var completion: ((String, String, Date, String, Int16, String, Date, Bool, Double, Double, String, String) -> Void)?
    
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
        locationName = task?.locationName
        longitude = task?.longitude
        latitude = task?.latitude
        recurring = task?.recurring
        
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
        
        // Location field display
        if (locationName != nil) {
            locationField.attributedText = NSMutableAttributedString().bodyNormal(locationName!)
            
            // Put pin and center map
            mapField.removeAnnotations(mapField.annotations)
            
            let pin = MKPointAnnotation()
            let coordinates = CLLocationCoordinate2D(latitude: latitude!, longitude: longitude!)
            pin.coordinate = coordinates
            
            mapField.addAnnotation(pin)
            mapField.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.1, longitudeDelta: 0.1)), animated: false)
        }
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditButton))
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
        vc.notifications = self.notifications
        vc.notificationDate = self.notificationDate
        vc.longitude = self.longitude
        vc.latitude = self.latitude
        vc.locationName = self.locationName
        vc.recurring = self.recurring
        
        vc.title = "Edit"
        vc.navigationItem.largeTitleDisplayMode = .never
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(madeVal!)])
        vc.completion = {title, body, date, color, priority, made, notiDate, notiOn, longitude, latitude, locationName, recurring in
            DispatchQueue.main.async {
                self.titleField.attributedText =  NSMutableAttributedString().boldTitle(title)
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY HH:mm"
                self.dateField.attributedText =  NSMutableAttributedString().bodyNormal(formatter.string(from: date))
                self.bodyField.attributedText =  NSMutableAttributedString().bodyNormal(body)
                self.topicField.attributedText =  NSMutableAttributedString().bodyNormal(color)
                self.madeVal = made
                self.titleStr = title
                self.bodyStr = body
                self.dateVal = date
                self.topicStr = color
                self.priorityVal = Int(priority)
                self.notificationDate = notiDate
                self.notifications = notiOn
                self.longitude = longitude
                self.latitude = latitude
                self.locationName = locationName
                self.recurring = recurring
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
                self.completion?(title, body, date, color, priority, made, notiDate, notiOn, longitude, latitude, locationName, recurring)
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
