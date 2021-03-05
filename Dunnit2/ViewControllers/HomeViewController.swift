//
//  HomeViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import CoreData
import Firebase
class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    var topView: UIView?
    
    var menu: MenuType?

    
    @IBOutlet var tableView: UITableView!
    
    var taskStore = [[TaskEntity](), [TaskEntity]()]
    
    func getData() {
        let tasks = DataBaseHelper.shareInstance.fetch(completion: { message in
            // WHEN you get a callback from the completion handler,
            self.taskStore = [message.filter{$0.isDone == false}, message.filter{$0.isDone == true}]
            self.tableView.reloadData()
        })
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
            let view = UIView()
            view.backgroundColor = .yellow
            view.frame = self.view.bounds
            self.view.addSubview(view)
            self.topView = view
            menu = MenuType.shared
            navigationItem.rightBarButtonItem?.isEnabled = true
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
            
        default:
            print("Default")
            navigationItem.rightBarButtonItem?.isEnabled = true
            menu = MenuType.all
            break
        }
    }
    
    @IBAction func didTapAdd() {
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
                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    DataBaseHelper.shareInstance.saveList(title: title)
                }
            }
            navigationController?.pushViewController(addlistVC, animated: true)
            return
        }

        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popToRootViewController(animated: true)
                DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        getData()
//        tableView.delegate = self
//        tableView.dataSource = self
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
            destination?.titleStr = taskStore[indexPath.section][indexPath.row].title
            destination?.dateVal = taskStore[indexPath.section][indexPath.row].date!
            destination?.bodyStr = taskStore[indexPath.section][indexPath.row].body
            tableView.deselectRow(at: indexPath, animated: true)
            destination?.completion = {title, body, date in
                DispatchQueue.main.async {
                    /*DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false)*/
                    self.taskStore[indexPath.section][indexPath.row].title = title
                    self.taskStore[indexPath.section][indexPath.row].date = date
                    self.taskStore[indexPath.section][indexPath.row].body = body
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
        return taskStore[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        let date = taskStore[indexPath.section][indexPath.row].date!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        cell.textLabel?.text = taskStore[indexPath.section][indexPath.row].title
        cell.detailTextLabel?.text = formatter.string(from: date)
        print(cell)
        return cell
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

//struct myTask {
//    var title: String
//    var date: Date
//    var identifier: String
//    var isDone: Int
//}
