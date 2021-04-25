//
//  CalenderViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 4/18/21.
//

import UIKit
import FSCalendar

class CalenderViewController: UIViewController, FSCalendarDelegate {
    
    var titleList: String?
    var id: String?
    var sortMenu: UIMenu?
    var list:ListEntity?
    @IBOutlet var calender: FSCalendar!
    @IBOutlet var dateLabel: UILabel!
    @IBOutlet var progressView: UIProgressView!
    @IBOutlet var tableTaskView: UITableView!
    
    var taskListStore = [[TaskEntity](), [TaskEntity]()]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        calender.delegate = self
        
        let today = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        dateLabel.text = formatter.string(from: today)
        
        self.title = titleList
        getData()
        setupSortMenuItem()
        
        let sortButton = UIBarButtonItem(title: "Sort", menu: sortMenu)
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShareButton))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItems = [addButton, shareButton, sortButton]
    }
    
    func calendar(_ calendar: FSCalendar, didSelect date: Date, at monthPosition: FSCalendarMonthPosition) {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEEE MM-dd-YYYY"
        
        let string = formatter.string(from: date)
        
        
        dateLabel.text = string
        getData(targetDate: date)
    }
    
    func getData(targetDate: Date? = nil) {
        let user = DataBaseHelper.shareInstance.fetchLocalUser()
        
        let sortKey = user[0].sortKey
        let sortAscending = user[0].sortAscending
        let filterKey = "date"
        
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask(key: sortKey, ascending: sortAscending, filterKey: filterKey, targetDate: targetDate)
        
        taskListStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
        
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

extension CalenderViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        //tableView.deselectRow(at: indexPath, animated: true)
        performSegue(withIdentifier: "showInfo", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let indexPath = tableTaskView.indexPathForSelectedRow {
            let destination = segue.destination as? DescriptionViewController
            destination?.task = taskListStore[indexPath.section][indexPath.row]
            tableTaskView.deselectRow(at: indexPath, animated: true)
            let id = taskListStore[indexPath.section][indexPath.row].id
            destination?.completion = {title, body, date, color, priority, made, notiDate, notiOn in
                DispatchQueue.main.async {
                    DataBaseHelper.shareInstance.updateLocalTask(id: id!, body: body,color: color,date: date,title: title, priority: priority, made: made)
                    self.navigationController?.popViewController(animated: true)
                    self.getData()
                }
            }
        }
    }
}

extension CalenderViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do" : "Done"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskListStore.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskListStore[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topics = getTopics()
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let viewWithTag = cell.viewWithTag(100)
        viewWithTag?.removeFromSuperview()
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
        } else {
            let dateStr = formatter.string(from: date)
            let range = (dateStr as NSString).range(of: dateStr)

            let mutableAttributedString = NSMutableAttributedString.init(string: dateStr)
            mutableAttributedString.addAttribute(NSAttributedString.Key.foregroundColor, value: UIColor.black, range: range)
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

            // Add the label to your rectangle
            rectangle.addSubview(label)

            // Add the rectangle to your cell
            cell.addSubview(rectangle)
        }
        return cell
    }
}

extension CalenderViewController {
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
            
            DataBaseHelper.shareInstance.deleteTask(id: row.id!)
            
            self.getData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
