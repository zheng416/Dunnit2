//
//  ListTaskViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/4/21.
//

import UIKit

class ListTaskViewController: UIViewController {

    var titleList: String?
    var id: String?
    var sortMenu: UIMenu?
    var list:ListEntity?
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var tableTaskView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var searchTasks = [[TaskEntity](), [TaskEntity]()]
    
    var searching = false
    
    var taskListStore = [[TaskEntity](), [TaskEntity]()]
    
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
    
    func getData() {
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        
        let sortKey = user[0].sortKey
        let sortAscending = user[0].sortAscending
        let filterKey = user[0].filterKey
        
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask(key: sortKey, ascending: sortAscending, filterKey: filterKey)
        
        print("THESE ARE THE TASKSS")
        print(tasks)
        
        taskListStore = [tasks.filter{$0.isDone == false && $0.list == self.list?.id}, tasks.filter{$0.isDone == true && $0.list == self.list?.id}]
        
        let progressCount = (Float(taskListStore[1].count) / Float(taskListStore[0].count + taskListStore[1].count))
        self.progressView.setProgress(progressCount, animated: true)
        

        tableTaskView.reloadData()
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
    
    // Dropdown menu
    private func setupSortMenuItem() {
        let localUser = DataBaseHelper.shareInstance.fetchLocalUser()
        self.sortMenu = UIMenu(title: "", children: [
            //TODO: Sort by task list function
            // Sort by title
            UIAction(title: "By Title Ascending") { action in
                // Update user's preference in db
                DataBaseHelper.shareInstance.updateSortPreference(key: "title", ascending: true, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "title", ascending: true, email: localUser[0].email ?? "")
                
                self.getData()
            },
            UIAction(title: "By Title Decending") { action in
                // Update user's preference in db
                DataBaseHelper.shareInstance.updateSortPreference(key: "title", ascending: false, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "title", ascending: false, email: localUser[0].email ?? "")
                
                self.getData()
            },
             UIAction(title: "By Date Ascending") { action in

                // Update user's preference in db
                DataBaseHelper.shareInstance.updateSortPreference(key: "date", ascending: true, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "date", ascending: true, email: localUser[0].email ?? "")
                
                self.getData()
            },
             UIAction(title: "By Date Decending") { action in
                
                // Update user's preference in db
                DataBaseHelper.shareInstance.updateSortPreference(key: "date", ascending: false, email: localUser[0].email ?? "")
                DataBaseHelper.shareInstance.updateSortPreferenceDB(key: "date", ascending: false, email: localUser[0].email ?? "")
                
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
        searchBar.autocapitalizationType = .none
        self.title = titleList
        getData()
        setupSortMenuItem()
        
        let sortButton = UIBarButtonItem(title: "Sort", menu: sortMenu)
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShareButton))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItems = [addButton, shareButton, sortButton]
        // Do any additional setup after loading the view.
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
    

    
    @objc func didTapShareButton() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "share") as? SharingViewController else {
            return
        }
        vc.title = "Share with"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.lid = self.id!
        vc.completion = {email in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                DataBaseHelper.shareInstance.saveDBSharedList(to: email, taskList: self.titleList!, lid: self.id!)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc func didTapAddButton() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.list = self.list
        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date, color, priority, made in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
//                DataBaseHelper.shareInstance.saveTask(title: title, body: body, date: date, isDone: false, list: self.titleList!, color: color, priority: priority, made: made)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
}

extension ListTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableTaskView.indexPathForSelectedRow {
            let destination = segue.destination as? DescriptionViewController
            destination?.task = taskListStore[indexPath.section][indexPath.row]
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
                tableTaskView.deselectRow(at: indexPath, animated: true)
                destination?.completion = {title, body, date, color, priority, made, notiDate, notiOn, longitude, latitude, locationName, recurring in
                    DispatchQueue.main.async {
                        DataBaseHelper.shareInstance.updateLocalTask(id: id!, body: body,color: color,date: date,title: title, priority: priority, made: made, notiDate: notiDate, notiOn: notiOn, recurring: recurring, longitude: longitude, latitude: latitude, locationName: locationName)
                        self.navigationController?.popViewController(animated: true)
                        self.getData()
                    }
                }
            } else {
                let id = taskListStore[indexPath.section][indexPath.row].id
                print("THE ID IS    ")
                print(id)
                destination?.titleStr = taskListStore[indexPath.section][indexPath.row].title!
                destination?.dateVal = taskListStore[indexPath.section][indexPath.row].date!
                destination?.bodyStr = taskListStore[indexPath.section][indexPath.row].body
                destination?.topicStr = taskListStore[indexPath.section][indexPath.row].color
                destination?.priorityVal = Int(taskListStore[indexPath.section][indexPath.row].priority)
                destination?.madeVal = taskListStore[indexPath.section][indexPath.row].made
                destination?.task = taskListStore[indexPath.section][indexPath.row]
                destination?.notifications = taskListStore[indexPath.section][indexPath.row].notiOn
                destination?.notificationDate = taskListStore[indexPath.section][indexPath.row].notiDate
                tableTaskView.deselectRow(at: indexPath, animated: true)
                destination?.completion = {title, body, date, color, priority, made, notiDate, notiOn, longitude, latitude, locationName, recurring in
                    DispatchQueue.main.async {
                        DataBaseHelper.shareInstance.updateLocalTask(id: id!, body: body,color: color,date: date,title: title, priority: priority, made: made, notiDate: notiDate, notiOn: notiOn, recurring: recurring, longitude: longitude, latitude: latitude, locationName: locationName)
                        self.navigationController?.popViewController(animated: true)
                        self.getData()
                    }
                }
            }
        }
    }
}

extension ListTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do" : "Done"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskListStore.count
    }
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if searching {
            return searchTasks[section].count
        }
        return taskListStore[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topics = getTopics()
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
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
            } else if (date.isInSameDay(as: Date()) && indexPath.section != 1) {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)

                let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: range)
                cell.detailTextLabel?.attributedText = mutableAttributedString
            } else {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)

//                let userInfo = getUser()
                let userInfo = DataBaseHelper.shareInstance.parsedLocalUser()
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
            let date = taskListStore[indexPath.section][indexPath.row].date!
            let color = taskListStore[indexPath.section][indexPath.row].color
            let priority = taskListStore[indexPath.section][indexPath.row].priority
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, YYYY HH:mm"
            cell.textLabel?.attributedText = NSMutableAttributedString()
                .normal(taskListStore[indexPath.section][indexPath.row].title!)
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
                    .normal(taskListStore[indexPath.section][indexPath.row].title! + "  ( ")
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
            } else if (date.isInSameDay(as: Date()) && indexPath.section != 1) {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)

                let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
                mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.systemGreen, range: range)
                cell.detailTextLabel?.attributedText = mutableAttributedString
            } else {
                let dateStr = formatter.string(from: date)
                let range = (dateStr as NSString).range(of: dateStr)
                
//                let userInfo = getUser()
                let userInfo = DataBaseHelper.shareInstance.parsedLocalUser()
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

extension ListTaskViewController: UISearchBarDelegate {
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        var searchingTasks = [[TaskEntity](), [TaskEntity]()]
        if (taskListStore[0].count >= 1) {
            for i in 0...taskListStore[0].count - 1 {
                if ((taskListStore[0][i].title!.lowercased().hasPrefix(searchText.lowercased())) || (taskListStore[0][i].color!.lowercased().hasPrefix(searchText.lowercased()))) {
                    searchingTasks[0].append(taskListStore[0][i])
                }
            }
        }
        
        if (taskListStore[1].count >= 1) {
            for i in 0...taskListStore[1].count - 1 {
                if ((taskListStore[1][i].title!.lowercased().hasPrefix(searchText.lowercased())) || (taskListStore[1][i].color!.lowercased().hasPrefix(searchText.lowercased()))) {
                    searchingTasks[1].append(taskListStore[1][i])
                }
            }
        }
        searchTasks = searchingTasks
        print("SEARCHING...")
        print(searchText)
        if !searchText.isEmpty {
            searching = true
        }
        else {
            searching = false
        }
        self.getData()
    }
}

extension ListTaskViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            //QUESTION????? should this be intersectoin?
            let row = self.taskListStore[0][indexPath.row]
            
            DataBaseHelper.shareInstance.updateLocalTask(id: row.id!, isDone: true)
            
            self.getData()
        }
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = .systemGreen
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.taskListStore[indexPath.section][indexPath.row]
            UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [String(row.made!)])
            DataBaseHelper.shareInstance.deleteTask(id: row.id!)
            
            self.getData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}

