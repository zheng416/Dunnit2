//
//  HomeViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import CoreData
import Firebase

extension NSMutableAttributedString {
    var fontSize:CGFloat { return 18 }
    var mediumFontSize:CGFloat { return 20 }
    var largeFontSize:CGFloat { return 30 }
    var boldFont:UIFont { return UIFont(name: "AvenirNext-Bold", size: fontSize) ?? UIFont.boldSystemFont(ofSize: fontSize) }
    var normalFont:UIFont { return UIFont(name: "AvenirNext-Regular", size: fontSize) ?? UIFont.systemFont(ofSize: fontSize)}
    var boldTitleFont:UIFont { return UIFont(name: "AvenirNext-Bold", size: largeFontSize) ?? UIFont.boldSystemFont(ofSize: largeFontSize) }
    var bodyNormalFont:UIFont { return UIFont(name: "AvenirNext-Regular", size: mediumFontSize) ?? UIFont.systemFont(ofSize: mediumFontSize) }
    
    func boldAndRed(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont,
            .foregroundColor : UIColor.red
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func boldTitle(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldTitleFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func bodyNormal(_ value:String) -> NSMutableAttributedString {
        let attributes:[NSAttributedString.Key : Any] = [
            .font : bodyNormalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func gray(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .foregroundColor : UIColor.gray
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func bold(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : boldFont
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
    
    func normal(_ value:String) -> NSMutableAttributedString {
        
        let attributes:[NSAttributedString.Key : Any] = [
            .font : normalFont,
        ]
        
        self.append(NSAttributedString(string: value, attributes:attributes))
        return self
    }
}

private var sortViewController: UIView!

class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    var topView: UIView?
    
    @IBOutlet weak var progressView: UIProgressView!
    
    var menu: MenuType?
    var sortMenu: UIMenu?

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var searchTasks = [[TaskEntity](), [TaskEntity]()]
    
    var searching = false
    
    var taskStore = [[TaskEntity](), [TaskEntity]()]
    var filteredTaskStore = [[TaskEntity](), [TaskEntity]()]
    var globalUser = [String: Any]()
    
    //helper functions
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
    
    //local
    func getData() {
        
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        
        let sortKey = user[0].sortKey
        let sortAscending = user[0].sortAscending
        let filterKey = user[0].filterKey
        
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask(key: sortKey, ascending: sortAscending, filterKey: filterKey)

        taskStore = [tasks.filter{$0.isDone == false && $0.owner == user[0].email}, tasks.filter{$0.isDone == true && $0.owner == user[0].email}]
        
        let progressCount = (Float(taskStore[1].count) / Float(taskStore[0].count + taskStore[1].count))
        print("% = ", progressCount, "indi = ", taskStore[1].count, (taskStore[1].count + taskStore[0].count))
        self.progressView.setProgress(progressCount, animated: true)
        
        tableView.reloadData()
    }
    
    func getTopics() -> [String: Any] {
        let user = DataBaseHelper.shareInstance.fetchTopics()
        print(user)
        var endUser = [String:Any]()
        for x in user as [TopicEntity] {
            endUser["red"] = x.red
            endUser["orange"] = x.orange
            endUser["yellow"] = x.yellow
            endUser["green"] = x.green
            endUser["blue"] = x.blue
            endUser["purple"] = x.purple
            endUser["indigo"] = x.indigo
            endUser["teal"] = x.teal
            endUser["pink"] = x.pink
            endUser["black"] = x.black
        }
        return endUser
    }
    
    @IBAction func didTapMenu(_ sender: UIBarButtonItem) {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let menuViewController = storyboard.instantiateViewController(withIdentifier: "MenuViewController") as? MenuViewController else { return }
        menuViewController.didTapMenuType = { menuType in
            self.transitionToNew(menuType)
        }
        menuViewController.modalPresentationStyle = .overCurrentContext
        menuViewController.transitioningDelegate = self
        present(menuViewController, animated: true)
    }
    
//    private let progressView: UIProgressView = {
//        let progressView = UIProgressView(progressViewStyle: .default)
//        progressView.trackTintColor = .gray
//        progressView.progressTintColor = .systemBlue
//        return progressView
//    }()
    
    func transitionToNew(_ menuType: MenuType) {
       
        let guest = globalUser["email"] as! String == "Guest"
        
        topView?.removeFromSuperview()
        switch menuType {
        case .progress:
            if (guest) {
                let dialogMessage = UIAlertController(title: "", message: "Please Sign In to Access Premium Feature", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                })
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            } else {
                let title = String(describing: menuType).capitalized
                self.title = title
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let listVC = storyboard.instantiateViewController(withIdentifier: "progressTabVC")
                view.addSubview(listVC.view)
                self.topView = listVC.view
                addChild(listVC)
                self.title = "Progress"

                navigationItem.rightBarButtonItems = nil
                menu = MenuType.progress
            }
        
        case .shared:
            if (guest) {
                let dialogMessage = UIAlertController(title: "", message: "Please Sign In to Access Premium Feature", preferredStyle: .alert)
                let ok = UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
                })
                dialogMessage.addAction(ok)
                self.present(dialogMessage, animated: true, completion: nil)
            } else {
                let title = String(describing: menuType).capitalized
                self.title = title
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let sharedVC = storyboard.instantiateViewController(withIdentifier: "sharedVC")
                view.addSubview(sharedVC.view)
                self.topView = sharedVC.view
                addChild(sharedVC)
                self.title = "Shared Lists"
                let inboxButton = UIBarButtonItem(title: "Inbox", style: .plain, target: self, action: #selector(didTapInboxButton))
                navigationItem.rightBarButtonItems = [inboxButton]
                menu = MenuType.shared
            }
        case .settings:
            let title = String(describing: menuType).capitalized
            self.title = title
            
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingVC = storyboard.instantiateViewController(withIdentifier: "settings")
            view.addSubview(settingVC.view)
            self.topView = settingVC.view
            addChild(settingVC)
            menu = MenuType.settings
            navigationItem.rightBarButtonItems = nil
            getData()
        case .myList:
            let title = String(describing: menuType).capitalized
            self.title = title
            
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let listVC = storyboard.instantiateViewController(withIdentifier: "listsVC")
            view.addSubview(listVC.view)
            self.topView = listVC.view
            addChild(listVC)
            self.title = "My Lists"
            
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
            navigationItem.rightBarButtonItems = [addButton]
            menu = MenuType.myList

        default:
            let title = String(describing: menuType).capitalized
            self.title = title
            
            print("Default")
            let sortButton = UIBarButtonItem(title: "Sort", menu: self.sortMenu)
            let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
            navigationItem.rightBarButtonItems = [addButton, sortButton]
            navigationItem.rightBarButtonItem?.isEnabled = true
            menu = MenuType.all
            getData()
            break
        }
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
    
    @objc func didTapInboxButton() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "inviteView") as? SharedInviteViewController else {
            return
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAddButton() {
        // Show add vc
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        
        
        
        if (menu == MenuType.myList) {
            // Do Stuff
            print(menu!)
            guard let addlistVC = storyboard.instantiateViewController(identifier: "addListVC") as? AddListViewController else {
                return
            }
            guard let listsVC = storyboard.instantiateViewController(identifier: "listsVC") as? ListsViewController else {
                return
            }
            
            addlistVC.title = "New List"
//            addlistVC.navigationItem.largeTitleDisplayMode = .never
            addlistVC.completion = {title in
//                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                DataBaseHelper.shareInstance.saveLocalList(title: title, shared: false, sharedWith: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//                    listsVC.viewWillAppear(true)
//                }
            }
            navigationController?.pushViewController(addlistVC, animated: true)
            return
        }
        
        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date, color, priority, made in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
//                DataBaseHelper.shareInstance.saveTask(title: title, body: body, date: date, isDone: false, list: "all", color: color, priority: priority, made: made)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Dropdown menu
    private func setupSortMenuItem() {
        let localUser = DataBaseHelper.shareInstance.fetchLocalUser()
        self.sortMenu = UIMenu(title: "", children: [
            // Sort by title
            UIAction(title: "By Title Ascending") { action in
                DataBaseHelper.shareInstance.updateSortPreference(key: "title", ascending: true, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "title", ascending: true, email: localUser[0].email ?? "")
                
                self.getData()
            },
            UIAction(title: "By Title Decending") { action in
                DataBaseHelper.shareInstance.updateSortPreference(key: "title", ascending: false, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "title", ascending: false, email: localUser[0].email ?? "")
                
                self.getData()
            },
             UIAction(title: "By Date Ascending") { action in
                DataBaseHelper.shareInstance.updateSortPreference(key: "date", ascending: true, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "date", ascending: true, email: localUser[0].email ?? "")
                
                self.getData()
            },
             UIAction(title: "By Date Decending") { action in
   
                DataBaseHelper.shareInstance.updateSortPreference(key: "date", ascending: false, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "date", ascending: false, email: localUser[0].email ?? "")
                
                self.getData()
            },
            UIAction(title: "By Priorities Ascending") { action in
                // Duplicate Menu Child Selected
                DataBaseHelper.shareInstance.updateSortPreference(key: "priority", ascending: true, email: localUser[0].email ?? "")
                self.getData()
            },
            UIAction(title: "By Priorities Decending") { action in
               // Duplicate Menu Child Selected
               DataBaseHelper.shareInstance.updateSortPreference(key: "priority", ascending: false, email: localUser[0].email ?? "")
               self.getData()
            },
             UIAction(title: "By Tags") { action in
                //Move Menu Child Selected
                DataBaseHelper.shareInstance.updateSortPreference(key: "color", ascending: true, email: localUser[0].email ?? "")
                self.getData()
            },
            UIAction(title: "Filter Today") { action in
                DataBaseHelper.shareInstance.updateFilterPreference(email: localUser[0].email ?? "", filterKey: "today")
                self.getData()
           },
            UIAction(title: "Filter This Month") { action in
                DataBaseHelper.shareInstance.updateFilterPreference(email: localUser[0].email ?? "", filterKey: "month")
                self.getData()
           },
            UIAction(title: "Filter This Year") { action in
                DataBaseHelper.shareInstance.updateFilterPreference(email: localUser[0].email ?? "", filterKey: "year")
                self.getData()
           },
            UIAction(title: "Clear Filter") { action in
                DataBaseHelper.shareInstance.updateFilterPreference(email: localUser[0].email ?? "", filterKey: "")
                self.getData()
           },
            
                ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // overrideUserInterfaceStyle = .light
        searchBar.autocapitalizationType = .none
        // Do any additional setup after loading the view.
        
        // Clear filter everytime relaunch app (prevent missed lists)
        let user = DataBaseHelper.shareInstance.fetchLocalUser()

        globalUser = DataBaseHelper.shareInstance.parsedLocalUser()
        
        DataBaseHelper.shareInstance.updateFilterPreference(email: user[0].email ?? "", filterKey: "")
        
        getData()
        setupSortMenuItem()
        
        let sortButton = UIBarButtonItem(title: "Sort", menu: self.sortMenu)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItems = [addButton, sortButton]
        
        let darkModeOn = globalUser["darkMode"] as! Bool
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
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}




extension HomeViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableView.indexPathForSelectedRow {
            let destination = segue.destination as? DescriptionViewController
            if searching {
                let id = searchTasks[indexPath.section][indexPath.row].id
                print("THE ID IS    ")
                print(id)
                destination?.titleStr = searchTasks[indexPath.section][indexPath.row].title!
                destination?.dateVal = searchTasks[indexPath.section][indexPath.row].date!
                destination?.bodyStr = searchTasks[indexPath.section][indexPath.row].body
                destination?.topicStr = searchTasks[indexPath.section][indexPath.row].color
                destination?.priorityVal = Int(searchTasks[indexPath.section][indexPath.row].priority)
                destination?.madeVal = searchTasks[indexPath.section][indexPath.row].made
                destination?.task = searchTasks[indexPath.section][indexPath.row]
                destination?.notifications = searchTasks[indexPath.section][indexPath.row].notiOn
                destination?.notificationDate = searchTasks[indexPath.section][indexPath.row].notiDate
                tableView.deselectRow(at: indexPath, animated: true)
                destination?.completion = {title, body, date, color, priority, made, notiDate, notiOn in
                    DispatchQueue.main.async {
                        DataBaseHelper.shareInstance.updateLocalTask(id: id!, body: body,color: color,date: date,title: title, priority: priority, made: made, notiDate: notiDate, notiOn: notiOn)
                        self.navigationController?.popViewController(animated: true)
                        self.getData()
                    }
                }
            } else {
                let id = taskStore[indexPath.section][indexPath.row].id
                print("THE ID IS    ")
                print(id)
                destination?.titleStr = taskStore[indexPath.section][indexPath.row].title!
                destination?.dateVal = taskStore[indexPath.section][indexPath.row].date!
                destination?.bodyStr = taskStore[indexPath.section][indexPath.row].body
                destination?.topicStr = taskStore[indexPath.section][indexPath.row].color
                destination?.priorityVal = Int(taskStore[indexPath.section][indexPath.row].priority)
                destination?.madeVal = taskStore[indexPath.section][indexPath.row].made
                destination?.task = taskStore[indexPath.section][indexPath.row]
                destination?.notifications = taskStore[indexPath.section][indexPath.row].notiOn
                destination?.notificationDate = taskStore[indexPath.section][indexPath.row].notiDate
                tableView.deselectRow(at: indexPath, animated: true)
                destination?.completion = {title, body, date, color, priority, made, notiDate, notiOn in
                    DispatchQueue.main.async {
                        DataBaseHelper.shareInstance.updateLocalTask(id: id!, body: body,color: color,date: date,title: title, priority: priority, made: made, notiDate: notiDate, notiOn: notiOn)
                        self.navigationController?.popViewController(animated: true)
                        self.getData()
                    }
                }
            }
        }
    }
}

extension HomeViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do" : "Done"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskStore.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchTasks[section].count
        }
        return taskStore[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topics = getTopics()
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let viewWithTag = cell.viewWithTag(100)
        viewWithTag?.removeFromSuperview()
        if searching {
            let date = searchTasks[indexPath.section][indexPath.row].date!
            let color = searchTasks[indexPath.section][indexPath.row].color
            let priority = searchTasks[indexPath.section][indexPath.row].priority
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, YYYY HH:mm"
            cell.textLabel?.attributedText = NSMutableAttributedString()
                .normal(searchTasks[indexPath.section][indexPath.row].title!)
            if (priority != 0) {
                var priorityText = ""
                if (priority == 1) {
                    priorityText = "!"
                } else if (priority == 2) {
                    priorityText = "!!"
                } else {
                    priorityText = "!!!"
                }
                cell.textLabel?.attributedText = NSMutableAttributedString()
                    .normal(searchTasks[indexPath.section][indexPath.row].title! + "  ( ")
                    .boldAndRed(priorityText)
                    .normal(" )")
            }
            cell.textLabel?.sizeToFit()
            if (date < Date() && indexPath.section != 1) {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)

                let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
                cell.detailTextLabel?.attributedText = mutableAttributedString
            } else {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)

                let userInfo = getUser()
                let darkModeOn = userInfo["darkMode"] as! Bool
                let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
                if darkModeOn {
                    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
                } else {
                    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
                }
                cell.detailTextLabel?.attributedText = mutableAttributedString
            }
//            if !(color!.isEmpty) {
            if (color != nil && !color!.isEmpty) {
                let label = UILabel()
                label.text = " " + color! + " "
                label.font = UIFont.boldSystemFont(ofSize: 16.0)
                label.textColor = .white
                label.sizeToFit()

                // Add a rectangle view
                let rectangle = UIView(frame: CGRect(x: (cell.textLabel?.frame.size.width)! + 50, y: (cell.textLabel?.frame.size.height)! - 10, width: label.frame.size.width, height: 20))

                var background = UIColor.white
                if (topics["red"] as? String) == color {
                    background = UIColor.systemRed
                }
                else if (topics["orange"] as? String) == color {
                    background = UIColor.systemOrange
                }
                else if (topics["yellow"] as? String) == color {
                    background = UIColor.systemYellow
                }
                else if (topics["green"] as? String) == color {
                    background = UIColor.systemGreen
                }
                else if (topics["blue"] as? String) == color {
                    background = UIColor.systemBlue
                }
                else if (topics["purple"] as? String) == color {
                    background = UIColor.systemPurple
                }
                else if (topics["indigo"] as? String) == color {
                    background = UIColor.systemIndigo
                }
                else if (topics["teal"] as? String) == color {
                    background = UIColor.systemTeal
                }
                else if (topics["pink"] as? String) == color {
                    background = UIColor.systemPink
                }
                else if (topics["black"] as? String) == color {
                    background = UIColor.black
                }
                
                rectangle.backgroundColor = background
                
                rectangle.layer.cornerRadius = 5
                
                rectangle.tag = 100
                
                if rectangle.backgroundColor != UIColor.white {
                
                    // Add the label to your rectangle
                    rectangle.addSubview(label)

                    // Add the rectangle to your cell
                    cell.addSubview(rectangle)
                }
            }
            
        }
        else {
            let date = taskStore[indexPath.section][indexPath.row].date!
            let color = taskStore[indexPath.section][indexPath.row].color
            let priority = taskStore[indexPath.section][indexPath.row].priority
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, YYYY HH:mm"
            cell.textLabel?.attributedText = NSMutableAttributedString()
                .normal(taskStore[indexPath.section][indexPath.row].title!)
            if (priority != 0) {
                var priorityText = ""
                if (priority == 1) {
                    priorityText = "!"
                } else if (priority == 2) {
                    priorityText = "!!"
                } else {
                    priorityText = "!!!"
                }
                cell.textLabel?.attributedText = NSMutableAttributedString()
                    .normal(taskStore[indexPath.section][indexPath.row].title! + "  ( ")
                    .boldAndRed(priorityText)
                    .normal(" )")
            }
            cell.textLabel?.sizeToFit()
            if (date < Date() && indexPath.section != 1) {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)

                let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.red, range: range)
                cell.detailTextLabel?.attributedText = mutableAttributedString
            } else {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)
                
                let userInfo = getUser()
                let darkModeOn = userInfo["darkMode"] as! Bool
                let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
                if darkModeOn {
                    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.white, range: range)
                } else {
                    mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
                }
                cell.detailTextLabel?.attributedText = mutableAttributedString
            }
//            if !(color!.isEmpty) {
            if (color != nil && !color!.isEmpty) {
                let label = UILabel()
                label.text = " " + color! + " "
                label.font = UIFont.boldSystemFont(ofSize: 16.0)
                label.textColor = .white
                label.sizeToFit()

                // Add a rectangle view
                let rectangle = UIView(frame: CGRect(x: (cell.textLabel?.frame.size.width)! + 50, y: (cell.textLabel?.frame.size.height)! - 10, width: label.frame.size.width, height: 20))

                var background = UIColor.white
                if (topics["red"] as? String) == color {
                    background = UIColor.systemRed
                }
                else if (topics["orange"] as? String) == color {
                    background = UIColor.systemOrange
                }
                else if (topics["yellow"] as? String) == color {
                    background = UIColor.systemYellow
                }
                else if (topics["green"] as? String) == color {
                    background = UIColor.systemGreen
                }
                else if (topics["blue"] as? String) == color {
                    background = UIColor.systemBlue
                }
                else if (topics["purple"] as? String) == color {
                    background = UIColor.systemPurple
                }
                else if (topics["indigo"] as? String) == color {
                    background = UIColor.systemIndigo
                }
                else if (topics["teal"] as? String) == color {
                    background = UIColor.systemTeal
                }
                else if (topics["pink"] as? String) == color {
                    background = UIColor.systemPink
                }
                else if (topics["black"] as? String) == color {
                    background = UIColor.black
                }
                
                rectangle.backgroundColor = background
                
                rectangle.layer.cornerRadius = 5
                
                rectangle.tag = 100
                
                if rectangle.backgroundColor != UIColor.white {

                    // Add the label to your rectangle
                    rectangle.addSubview(label)

                    // Add the rectangle to your cell
                    cell.addSubview(rectangle)
                }
            }
        }
        return cell
    }
}

extension HomeViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var searchingTasks = [[TaskEntity](), [TaskEntity]()]
        if (taskStore[0].count >= 1) {
            for i in 0...taskStore[0].count - 1 {
                if ((taskStore[0][i].title!.lowercased().hasPrefix(searchText.lowercased())) || (taskStore[0][i].color!.lowercased().hasPrefix(searchText.lowercased()))) {
                    searchingTasks[0].append(taskStore[0][i])
                }
            }
        }
        
        if (taskStore[1].count >= 1) {
            for i in 0...taskStore[1].count - 1 {
                if ((taskStore[1][i].title!.lowercased().hasPrefix(searchText.lowercased())) || (taskStore[1][i].color!.lowercased().hasPrefix(searchText.lowercased()))) {
                    searchingTasks[1].append(taskStore[1][i])
                }
            }
        }
        searchTasks = searchingTasks
        if !searchText.isEmpty {
            searching = true
        }
        else {
            searching = false
        }
        self.getData()
    }
}

extension HomeViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.taskStore[0][indexPath.row]
            DataBaseHelper.shareInstance.updateLocalTask(id: row.id!,isDone: true, title: row.title!)
            
            self.getData()
        }
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = .systemGreen
        
        let duplicateAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            DataBaseHelper.shareInstance.duplicateTask(task: self.taskStore[0][indexPath.row])
            self.getData()
        }
        duplicateAction.image = UIImage(systemName: "doc.on.doc")
        duplicateAction.backgroundColor = .systemBlue
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction,duplicateAction]) : nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.taskStore[indexPath.section][indexPath.row]
            
            DataBaseHelper.shareInstance.deleteTask(id: row.id!)
            
            self.getData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

extension HomeViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = true
        return transition
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        transition.isPresenting = false
        return transition
    }
}
