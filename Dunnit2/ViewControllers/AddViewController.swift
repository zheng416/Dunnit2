//
//  AddViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/23/21.
//

import UIKit
import UserNotifications
import CoreLocation
import MapKit
import FloatingPanel

class AddViewController: UIViewController, UITextFieldDelegate, CLLocationManagerDelegate, MapViewControllerDelegate {
    
    var currentTopic: String?
    var currentPriority: Int?
    var currentList: String?
    var listString: String?
    var currentReminder: String?
    var notificationsOn: Bool?
    var list: ListEntity?
    var locationManager: CLLocationManager?
    var currentRecurring: String?
    
    var countTopics: Int?
    var countLists: Int?
    
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    @IBOutlet var recurringField: UILabel!
    
    // Premium Features
    @IBOutlet var topicField: UILabel!
    @IBOutlet var priorityField: UILabel!
    @IBOutlet var listField: UILabel!
    
    @IBOutlet var addTopic: UIButton!
    @IBOutlet var cancelTopic: UIButton!
    @IBOutlet var addPriority: UIButton!
    @IBOutlet var cancelPriority: UIButton!
    @IBOutlet var addList: UIButton!
    @IBOutlet var cancelList: UIButton!
    @IBOutlet var addRecurring: UIButton!
    @IBOutlet var cancelRecurring: UIButton!
    
    @IBOutlet weak var editLocationButton: UIButton!
    //    @IBOutlet weak var mapTitle: UILabel!
//    @IBOutlet weak var mapSearchField: UITextField!
    
    var recurringMenu: UIMenu?
    
    var topicMenu: UIMenu?
    var priorityMenu: UIMenu?
    var listMenu: UIMenu?
    
    @IBOutlet weak var notificationToggle: UISwitch!
    @IBOutlet var notificationLabel: UILabel!
    @IBOutlet var reminderField: UILabel!
    @IBOutlet var addReminder: UIButton!
    @IBOutlet var cancelReminder: UIButton!
    
//    Locations
    @IBOutlet weak var locationField: UILabel!
    @IBOutlet weak var addLocation: UIButton!
    @IBOutlet weak var cancelLocation: UIButton!
    
    var locationCoords: CLLocationCoordinate2D?
    var locationName: String?
    
    var reminderMenu: UIMenu?

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
    
    func getTopics() -> [String: Any] {
        let user = DataBaseHelper.shareInstance.fetchTopics()
        print(user)
        var endTopic = [String:Any]()
        for x in user as [TopicEntity] {
            endTopic["red"] = x.red
            endTopic["orange"] = x.orange
            endTopic["yellow"] = x.yellow
            endTopic["green"] = x.green
            endTopic["blue"] = x.blue
            endTopic["purple"] = x.purple
            endTopic["indigo"] = x.indigo
            endTopic["teal"] = x.teal
            endTopic["pink"] = x.pink
            endTopic["black"] = x.black
        }
        return endTopic
    }
    
    func getList() -> [String: Any] {
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        let lists = DataBaseHelper.shareInstance.fetchLocalLists()
        var endList = [String: Any]()
        for x in lists as [ListEntity] {
            if (x.owner! == user[0].email!){
                endList[x.id!] = x.title!
            }
        }
        return endList
    }
    
    func hidePremiumFields() -> Void {
        topicField.isHidden = true
        priorityField.isHidden = true
        listField.isHidden = true
        
        addTopic.isHidden = true
        cancelTopic.isHidden = true
        addPriority.isHidden = true
        cancelPriority.isHidden = true
        addList.isHidden = true
        cancelList.isHidden = true
        
        notificationToggle.isHidden = true
        notificationLabel.isHidden = true
        reminderField.isHidden = true
        addReminder.isHidden = true
        cancelReminder.isHidden = true
        
        locationField.isHidden = true
        addLocation.isHidden = true
        cancelLocation.isHidden = true
    }
    
//    func centerMap(with location: CLLocation) {
////        let pin = MKPointAnnotation()
////        pin.coordinate = location.coordinate
//        map.setRegion(MKCoordinateRegion(
//                        center: location.coordinate,
//                        span: MKCoordinateSpan(
//                            latitudeDelta: 0.7,
//                            longitudeDelta: 0.7)),
//                        animated: true)
////        map.addAnnotation(pin)
//    }
    
    func mapViewController(_ vc: MapViewController, selectedLocationName: String, coordinates: CLLocationCoordinate2D?) {
        locationField.text = selectedLocationName
        locationName = selectedLocationName
        guard let coordinates = coordinates else { return }
        
        locationCoords = coordinates
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let user = DataBaseHelper.shareInstance.parsedLocalUser()
      
        notificationsOn = user["notification"] as! Bool
        titlefield.delegate = self // rid of keyboard
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        let date = datePicker.date
        let modifiedDate = Calendar.current.date(byAdding: .day, value: 1, to: date)!
        datePicker.date = modifiedDate
        // Do any additional setup after loading the view.
        
        self.currentRecurring = "Never"
        self.recurringField.attributedText = NSMutableAttributedString().gray("Never Repeat")
        self.cancelRecurring.tintColor = UIColor.gray
        
        setupRecurringMenuItem()
        
        self.addRecurring.menu = self.recurringMenu
        self.addRecurring.showsMenuAsPrimaryAction = true
        
        self.cancelRecurring.addTarget(self, action: #selector(removeRecurring), for: .touchUpInside)
        
        let guest = (user["email"] as! String == "Guest")
        
        if (guest) {
            hidePremiumFields()
        }
        
        self.addLocation.addTarget(self, action: #selector(didTapAddLocationButton), for: .touchUpInside)
        self.cancelLocation.addTarget(self, action: #selector(removeLocation), for: .touchUpInside)
        
        self.cancelTopic.tintColor = UIColor.gray
        self.cancelPriority.tintColor = UIColor.gray
        self.cancelList.tintColor = UIColor.gray
        self.cancelReminder.tintColor = UIColor.gray
        self.cancelLocation.tintColor = UIColor.gray
        
        setupTopicMenu()
        setupPriorityMenuItem()
        setupReminderMenuItem()
        
        self.currentTopic = ""
        self.currentPriority = 0
        if list == nil {
            self.currentList = ""
        } else {
            self.currentList = list?.id
        }
        self.topicField.attributedText = NSMutableAttributedString().gray("Add a Topic")
        self.priorityField.attributedText = NSMutableAttributedString().gray("Add a Priority")
        self.locationField.attributedText = NSMutableAttributedString().gray("Add a Location")
        
        self.addTopic.menu = self.topicMenu
        self.addTopic.showsMenuAsPrimaryAction = true
        self.addPriority.menu = self.priorityMenu
        self.addPriority.showsMenuAsPrimaryAction = true
      
        self.cancelTopic.addTarget(self, action: #selector(removeTopic), for: .touchUpInside)
        self.cancelPriority.addTarget(self, action: #selector(removePriority), for: .touchUpInside)
        
        if self.countTopics == 0 {
            self.addTopic.isEnabled = false
            self.cancelTopic.isEnabled = false
        }
        
        if list != nil {
            self.listString = ""
            self.listField.attributedText = NSMutableAttributedString().normal((list?.title)!)
            self.addList.isEnabled = false
            self.cancelList.isEnabled = false
        } else {
            setupListMenuItem()
            self.listField.attributedText = NSMutableAttributedString().gray("Add a List")
            self.addList.menu = self.listMenu
            self.addList.showsMenuAsPrimaryAction = true
            self.cancelList.addTarget(self, action: #selector(removeList), for: .touchUpInside)
            if self.countLists == 0 {
                self.addList.isEnabled = false
                self.cancelList.isEnabled = false
            }
        }
        
        
        self.currentReminder = ""
        self.notificationLabel.attributedText = NSMutableAttributedString().bold("Notification")
        self.notificationToggle.isOn = false
        self.reminderField.attributedText = NSMutableAttributedString().gray("Add a Reminder")
        self.addReminder.isEnabled = false
        self.cancelReminder.isEnabled = false
        
        self.addReminder.menu = self.reminderMenu
        self.addReminder.showsMenuAsPrimaryAction = true
        self.cancelReminder.addTarget(self, action: #selector(removeReminder), for: .touchUpInside)
        
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
    
    @objc private func didTapAddLocationButton() {
        // Show add mapVC
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let mapVC = storyboard.instantiateViewController(identifier: "map") as? MapViewController else {
            return
        }
        mapVC.delegate = self
        
        navigationController?.pushViewController(mapVC, animated: true)
    }
    
    @objc private func removeLocation() {
        self.locationName = ""
        self.locationCoords = nil
        self.locationField.attributedText = NSMutableAttributedString().gray("Add a Location")
        self.addLocation.isEnabled = true
    }
    
    
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if status == .authorizedAlways {
            print("Location authorized\n")
        }
    }
    
    private func setupRecurringMenuItem() {
        self.recurringMenu = UIMenu(title: "", children: [
            UIAction(title: "Daily") {action in
                self.currentRecurring = "Daily"
                self.recurringField.attributedText = NSMutableAttributedString().normal("Daily")
                self.addRecurring.isEnabled = false
            },
            UIAction(title: "Weekly") {action in
                self.currentRecurring = "Weekly"
                self.recurringField.attributedText = NSMutableAttributedString().normal("Weekly")
                self.addRecurring.isEnabled = false
            },
            UIAction(title: "Monthly") {action in
                self.currentRecurring = "Monthly"
                self.recurringField.attributedText = NSMutableAttributedString().normal("Monthly")
                self.addRecurring.isEnabled = false
            }
        ])
    }
    
    private func setupTopicMenu() {
        let topics = getTopics()
        var topicsData = [String]()
        self.countTopics = 0
        for (_, topic) in topics {
            if !((topic as! String).isEmpty) {
                topicsData.append(topic as! String)
                self.countTopics! += 1
            }
        }
        topicsData.sort()
        var topicsChildren = [UIAction]()
        for child in topicsData {
            print(child)
            topicsChildren.append(
                UIAction(title: child) {action in
                    self.currentTopic = child
                    self.topicField.attributedText = NSMutableAttributedString().normal(child)
                    self.addTopic.isEnabled = false
                }
            )
        }
        self.topicMenu = UIMenu(title: "", children: topicsChildren)
    }
    
    private func setupPriorityMenuItem() {
        self.priorityMenu = UIMenu(title: "", children: [
            UIAction(title: "Low Priority") {action in
                self.currentPriority = 1
                self.priorityField.attributedText = NSMutableAttributedString().normal("Low Priority")
                self.addPriority.isEnabled = false
            },
            UIAction(title: "Medium Priority") {action in
                self.currentPriority = 2
                self.priorityField.attributedText = NSMutableAttributedString().normal("Medium Priority")
                self.addPriority.isEnabled = false
            },
            UIAction(title: "High Priority") {action in
                self.currentPriority = 3
                self.priorityField.attributedText = NSMutableAttributedString().normal("High Priority")
                self.addPriority.isEnabled = false
            }
        ])
    }
    
    private func setupListMenuItem() {
        let lists = getList()
        var listsId = [String]()
        var listsData = [String]()
        self.countLists = 0
        for (id, list) in lists {
            if !((list as! String).isEmpty) {
                listsId.append(id)
                listsData.append(list as! String)
                self.countLists! += 1
            }
        }
        var listsChildren = [UIAction]()
        for (childId, childName) in zip(listsId, listsData) {
            listsChildren.append(
                UIAction(title: childName) {action in
                    self.currentList = childId
                    self.listString = childName
                    self.listField.attributedText = NSMutableAttributedString().normal(childName)
                    self.addList.isEnabled = false
                }
            )
        }
        self.listMenu = UIMenu(title: "", children: listsChildren)
    }
    
    private func setupReminderMenuItem() {
        self.reminderMenu = UIMenu(title: "", children: [
            UIAction(title: "Deadline") {action in
                self.currentReminder = "Deadline"
                self.reminderField.attributedText = NSMutableAttributedString().normal("Deadline")
                self.addReminder.isEnabled = false
            },
            UIAction(title: "15 Minutes") {action in
                self.currentReminder = "15 Minutes"
                self.reminderField.attributedText = NSMutableAttributedString().normal("15 Minutes")
                self.addReminder.isEnabled = false
            },
            UIAction(title: "30 Minutes") {action in
                self.currentReminder = "30 Minutes"
                self.reminderField.attributedText = NSMutableAttributedString().normal("30 Minutes")
                self.addReminder.isEnabled = false
            },
            UIAction(title: "1 Hour") {action in
                self.currentReminder = "1 Hour"
                self.reminderField.attributedText = NSMutableAttributedString().normal("1 Hour")
                self.addReminder.isEnabled = false
            },
            UIAction(title: "12 Hours") {action in
                self.currentReminder = "12 Hours"
                self.reminderField.attributedText = NSMutableAttributedString().normal("12 Hours")
                self.addReminder.isEnabled = false
            },
            UIAction(title: "24 Hours") {action in
                self.currentReminder = "24 Hours"
                self.reminderField.attributedText = NSMutableAttributedString().normal("24 Hours")
                self.addReminder.isEnabled = false
            }
        ])
    }
    
    @objc private func removeRecurring() {
        self.currentRecurring = "Never"
        self.recurringField.attributedText = NSMutableAttributedString().gray("Never Repeat")
        self.addRecurring.isEnabled = true
    }
    
    @objc private func removeTopic() {
        self.currentTopic = ""
        self.topicField.attributedText = NSMutableAttributedString().gray("Add a Topic")
        self.addTopic.isEnabled = true
    }
    
    @objc private func removePriority() {
        self.currentPriority = 0
        self.priorityField.attributedText = NSMutableAttributedString().gray("Add a Priority")
        self.addPriority.isEnabled = true
    }
    
    @objc private func removeList() {
        self.currentList = ""
        self.listField.attributedText = NSMutableAttributedString().gray("Add a List")
        self.addList.isEnabled = true
    }
    
    @objc private func removeReminder() {
        self.currentReminder = ""
        self.reminderField.attributedText = NSMutableAttributedString().gray("Add a Reminder")
        self.addReminder.isEnabled = true
    }
    
    @IBAction func toggleReminders() {
        if notificationToggle.isOn {
            self.notificationToggle.isOn = true
            if currentReminder == "" {
                self.reminderField.attributedText = NSMutableAttributedString().gray("Add a Reminder")
            } else {
                self.reminderField.attributedText = NSMutableAttributedString().normal(currentReminder!)
            }
            self.addReminder.isEnabled = true
            self.cancelReminder.isEnabled = true
        } else {
            self.notificationToggle.isOn = false
            if currentReminder == "" {
                self.reminderField.attributedText = NSMutableAttributedString().gray("Add a Reminder")
            } else {
                self.reminderField.attributedText = NSMutableAttributedString().gray(currentReminder!)
            }
            self.addReminder.isEnabled = false
            self.cancelReminder.isEnabled = false
        }
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titlefield.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            let made = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YY, MMM d, HH:mm:ss"
            let madeDate = dateFormatter.string(from: made)
            var notiDate: Date
            var notiOn: Bool
            
            notiDate = targetDate
            notiOn = false
            if (notificationsOn! && currentReminder != "") {
                notiOn = true
                var timeMultiplier = 0
                if currentReminder == "15 Minutes" {
                    timeMultiplier = 15
                } else if currentReminder == "30 Minutes" {
                    timeMultiplier = 30
                } else if currentReminder == "1 Hour" {
                    timeMultiplier = 60
                } else if currentReminder == "6 Hours" {
                    timeMultiplier = 60 * 6
                } else if currentReminder == "12 Hours" {
                    timeMultiplier = 60 * 12
                } else if currentReminder == "24 Hours" {
                    timeMultiplier = 60 * 24
                }
                let reminderDate = targetDate.addingTimeInterval(TimeInterval(-timeMultiplier * 60))
                notiDate = reminderDate
                let content = UNMutableNotificationContent()
                content.title = currentReminder! + ": " + titleText
                content.sound = .default
                content.body = bodyText
                var trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.year, .month, .day, .hour, .minute, .second], from: reminderDate), repeats: false)
                if currentRecurring == "Daily" {
                    trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute, .second], from: reminderDate), repeats: true)
                } else if currentRecurring == "Weekly" {
                    trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.hour, .minute, .second, .weekday], from: reminderDate), repeats: true)
                } else if currentRecurring == "Monthly" {
                    trigger = UNCalendarNotificationTrigger(dateMatching: Calendar.current.dateComponents([.day, .hour, .minute, .second], from: reminderDate), repeats: true)
                }
                let request = UNNotificationRequest(identifier: madeDate, content: content, trigger: trigger)
                UNUserNotificationCenter.current().add(request, withCompletionHandler: {error in
                    if error != nil {
                        print("error for adding notification")
                    }
                })
            }
            var longitude: Double = 0.0
            var latitude: Double = 0.0
            var location_name: String = ""
            if locationCoords != nil {
                longitude = locationCoords!.longitude
                latitude = locationCoords!.latitude
                location_name = locationName!
            }
            DataBaseHelper.shareInstance.saveTask(title: titleText, body: bodyText, date: targetDate, isDone: false, list: currentList!, color: currentTopic!, priority: Int16(currentPriority!), made: madeDate, notiDate: notiDate, notiOn: notiOn, recurring: currentRecurring!, longitude: longitude, latitude: latitude, locationName: location_name)
             
            completion?(titleText, bodyText, targetDate, currentTopic!, Int16(currentPriority!), madeDate)
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
