//
//  HomeViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import CoreData
import Firebase

private var sortViewController: UIView!

class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    var topView: UIView?
    
    var menu: MenuType?
    var sortMenu: UIMenu?

    @IBOutlet var tableView: UITableView!
    
    @IBOutlet var searchBar: UISearchBar!
    
    var searchTasks = [[TaskEntity](), [TaskEntity]()]
    
    var searching = false
    
    var taskStore = [[TaskEntity](), [TaskEntity]()]
    var filteredTaskStore = [[TaskEntity](), [TaskEntity]()]
    //local
    func getData() {
        
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        let user = DataBaseHelper.shareInstance.fetchUser()
        taskStore = [tasks.filter{$0.isDone == false && $0.owner == user[0].email}, tasks.filter{$0.isDone == true && $0.owner == user[0].email}]
        print("ALLLLLLLLL            TASKS")
        print(tasks)
        
        print("END        ALLLLLLLLL TASKS")
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
    
    func transitionToNew(_ menuType: MenuType) {
        let title = String(describing: menuType).capitalized
        self.title = title
        
        topView?.removeFromSuperview()
        switch menuType {
        
        // Switch VIEW CONTROLLERS
        // let profileVC = ProfileViewController()
        // view.addSubview(profileVC.view)
        // self.topView = profileVC.view
        // addChild(profileVC)
        
        
        case .shared:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let sharedVC = storyboard.instantiateViewController(withIdentifier: "sharedVC")
            view.addSubview(sharedVC.view)
            self.topView = sharedVC.view
            addChild(sharedVC)
            self.title = "Shared Lists"
            navigationItem.rightBarButtonItem?.isEnabled = false
            menu = MenuType.shared
        case .settings:
            let storyboard = UIStoryboard(name: "Settings", bundle: nil)
            let settingVC = storyboard.instantiateViewController(withIdentifier: "settings")
            view.addSubview(settingVC.view)
            self.topView = settingVC.view
            addChild(settingVC)
            menu = MenuType.settings
            navigationItem.rightBarButtonItem?.isEnabled = false
//        case .myList:
//            let storyboard = UIStoryboard(name: "Home", bundle: nil)
//            guard let vc = storyboard.instantiateViewController(identifier: "ListVC") as? ListViewController else {
//                return
//            }
//             view.addSubview(profileVC.view)
//             self.topView = profileVC.view
//             addChild(profileVC)
        
        case .myList:
            let storyboard = UIStoryboard(name: "Home", bundle: nil)
            let listVC = storyboard.instantiateViewController(withIdentifier: "listsVC")
            view.addSubview(listVC.view)
            self.topView = listVC.view
            addChild(listVC)
            self.title = "My Lists"
            navigationItem.rightBarButtonItem?.isEnabled = true
            menu = MenuType.myList

//            navigationItem.rightBarButtonItems = nil
            
        default:
            print("Default")
            navigationItem.rightBarButtonItem?.isEnabled = true
            menu = MenuType.all
            getData()
            break
        }
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
                DataBaseHelper.shareInstance.saveList(title: title, shared: false, sharedWith: "")
                    NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
//                    listsVC.viewWillAppear(true)
//                }
            }
            navigationController?.pushViewController(addlistVC, animated: true)
            return
        }

        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date, color in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false, list: "all", color: color)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    // Dropdown menu
    private func setupSortMenuItem() {
        self.sortMenu = UIMenu(title: "", children: [
            // Sort by title
            UIAction(title: "By Ascending Title", image: UIImage(systemName: "doc.on.doc")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskAscendingTitle()
                self.taskStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                // Update user's preference local
                // Update user's preference DB
                self.tableView.reloadData()
            },
             UIAction(title: "By Ascending Date", image: UIImage(systemName: "pencil")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskAscendingDate()
                self.taskStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                self.tableView.reloadData()
            },
            UIAction(title: "By Decending Title", image: UIImage(systemName: "doc.on.doc")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskDecendingTitle()
                self.taskStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                self.tableView.reloadData()
            },
             UIAction(title: "By Decending Date", image: UIImage(systemName: "pencil")) { action in
                let tasks = DataBaseHelper.shareInstance.fetchTaskDecendingDate()
                self.taskStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
                self.tableView.reloadData()
            },
             UIAction(title: "By Priorities", image: UIImage(systemName: "plus.square.on.square")) { action in
                // Duplicate Menu Child Selected
            },
             UIAction(title: "By Tags", image: UIImage(systemName: "folder")) { action in
                //Move Menu Child Selected
            },
                ])
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        searchBar.autocapitalizationType = .none
        getData()
        setupSortMenuItem()
        
        let sortButton = UIBarButtonItem(title: "Sort", menu: self.sortMenu)
        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        navigationItem.rightBarButtonItems = [addButton, sortButton]
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
            let previous = taskStore[indexPath.section][indexPath.row].title
            destination?.titleStr = previous
            destination?.dateVal = taskStore[indexPath.section][indexPath.row].date!
            destination?.bodyStr = taskStore[indexPath.section][indexPath.row].body
            destination?.topicStr = taskStore[indexPath.section][indexPath.row].color
            tableView.deselectRow(at: indexPath, animated: true)
            destination?.completion = {title, body, date, color in
                DispatchQueue.main.async {
                    DataBaseHelper.shareInstance.updateData(previous: previous!, title: title, body: body, date: date, color: color)
                    self.navigationController?.popViewController(animated: true)
                    self.getData()
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
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, YYYY"
            cell.textLabel?.text = searchTasks[indexPath.section][indexPath.row].title
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
        }
        else {
            let date = taskStore[indexPath.section][indexPath.row].date!
            let color = taskStore[indexPath.section][indexPath.row].color
            let formatter = DateFormatter()
            formatter.dateFormat = "MMM dd, YYYY"
            cell.textLabel?.text = taskStore[indexPath.section][indexPath.row].title
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
            
            DataBaseHelper.shareInstance.update(title: row.title!, isDone: true)
            
            self.getData()
        }
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = .systemGreen
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.taskStore[indexPath.section][indexPath.row]
            
            DataBaseHelper.shareInstance.deleteData(title: row.title!)
            
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
