//
//  ListTaskViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/4/21.
//

import UIKit

class ListTaskViewController: UIViewController {

    var titleList: String?
    var sortMenu: UIMenu?
    
    @IBOutlet weak var progressView: UIProgressView!
    @IBOutlet var tableTaskView: UITableView!
    
    var taskListStore = [[TaskEntity](), [TaskEntity]()]
    
    func getData() {
        print("in list task view controller")
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        taskListStore = [tasks.filter{$0.isDone == false && $0.list == self.titleList}, tasks.filter{$0.isDone == true && $0.list == self.titleList}]
        
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
        self.sortMenu = UIMenu(title: "", children: [
            //TODO: Sort by task list function
            // Sort by title
            UIAction(title: "By Ascending Title", image: UIImage(systemName: "doc.on.doc")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskAscendingTitle()
                self.taskListStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                // Update user's preference local
                // Update user's preference DB
                self.tableTaskView.reloadData()
            },
             UIAction(title: "By Ascending Date", image: UIImage(systemName: "pencil")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskAscendingDate()
                self.taskListStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                self.tableTaskView.reloadData()
            },
            UIAction(title: "By Decending Title", image: UIImage(systemName: "doc.on.doc")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskDecendingTitle()
                self.taskListStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                self.tableTaskView.reloadData()
            },
             UIAction(title: "By Decending Date", image: UIImage(systemName: "pencil")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskDecendingDate()
                self.taskListStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                self.tableTaskView.reloadData()
            }
        ])
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleList
        getData()
        setupSortMenuItem()
        
        let sortButton = UIBarButtonItem(title: "Sort", menu: sortMenu)
        let shareButton = UIBarButtonItem(title: "Share", style: .plain, target: self, action: #selector(didTapShareButton))
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItems = [addButton, shareButton, sortButton]
        // Do any additional setup after loading the view.
    }
    
    @objc func didTapShareButton() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "share") as? SharingViewController else {
            return
        }
        vc.title = "Share with"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {email in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                DataBaseHelper.shareInstance.shareListDB(to: email, taskList: self.titleList!)
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
        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date, color in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                DataBaseHelper.shareInstance.saveTask(title: title, body: body, date: date, isDone: false, list: self.titleList!, color: color)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
        
    }
    

}

extension ListTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
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
        return taskListStore[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let topics = getTopics()
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let viewWithTag = cell.viewWithTag(100)
        viewWithTag?.removeFromSuperview()
        let date = taskListStore[indexPath.section][indexPath.row].date!
        let color = taskListStore[indexPath.section][indexPath.row].color
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        cell.textLabel?.text = taskListStore[indexPath.section][indexPath.row].title
        cell.textLabel?.sizeToFit()
        cell.detailTextLabel?.text = formatter.string(from: date)
        if !(color!.isEmpty) {
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
            
            DataBaseHelper.shareInstance.deleteTask(id: row.id!)
            
            self.getData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
