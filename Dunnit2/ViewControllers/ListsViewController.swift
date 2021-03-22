//
//  ListsViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/1/21.
//

import UIKit
import CoreData

class ListsViewController: UIViewController {
    var sortMenu: UIMenu?
    @IBOutlet var listTableView: UITableView!
    var listStore = [ListEntity]()
    
    func getLists() {
        let templists = DataBaseHelper.shareInstance.fetchLists()
        let user = DataBaseHelper.shareInstance.fetchUser()
        // print(templists.filter{$0.owner == user[0].email})
        listStore = templists.filter{$0.owner == user[0].email}
        listTableView.reloadData()
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        getLists()
    }
    
//    // Dropdown menu
//    private func setupSortMenuItem() {
//        print("sort menu in task list")
//        self.sortMenu = UIMenu(title: "", children: [
//            //TODO: Sort by task list function
//            // Sort by title
//            UIAction(title: "By Ascending Title", image: UIImage(systemName: "doc.on.doc")) { action in
//                print("sort lists by title")
//                let user = DataBaseHelper.shareInstance.fetchUser()
//                let templists = DataBaseHelper.shareInstance.fetchLists()
//                self.listStore = templists.filter{$0.owner == user[0].email}
//                // Update user's preference local
//                // Update user's preference DB
//                self.listTableView.reloadData()
//            },
//            UIAction(title: "By Decending Title", image: UIImage(systemName: "doc.on.doc")) { action in
//
//            }
//        ])
//    }
    
//    @objc func didTapAddButton() {
//        // Show add vc
//        let storyboard = UIStoryboard(name: "Home", bundle: nil)
//        guard let vc = storyboard.instantiateViewController(identifier: "add") as? AddViewController else {
//            return
//        }
//
//        guard let addlistVC = storyboard.instantiateViewController(identifier: "addListVC") as? AddListViewController else {
//            return
//        }
//
//        addlistVC.title = "New List"
////            addlistVC.navigationItem.largeTitleDisplayMode = .never
//        addlistVC.completion = {title in
////                DispatchQueue.main.async {
//                self.navigationController?.popToRootViewController(animated: true)
//            DataBaseHelper.shareInstance.saveList(title: title, shared: false, sharedWith: "")
//                NotificationCenter.default.post(name: NSNotification.Name(rawValue: "load"), object: nil)
////                    listsVC.viewWillAppear(true)
////                }
//        }
//        navigationController?.pushViewController(addlistVC, animated: true)
//        return
//
//    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        
        getLists()
        
        // Question,
        // I need to access the list store here to sort
        // Could not update navigation button here in this file
        // could not access list store in homeVC
        
//        print("loadlded listview controller")
//        setupSortMenuItem()
//        // Do any additional setup after loading the view.
//        let sortButton = UIBarButtonItem(title: "Sort", menu: self.sortMenu)
//        let addButton = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
//        let rightNavItems = [addButton, sortButton]
//        navigationItem.setRightBarButtonItems(rightNavItems, animated: true)

    }
    


}

extension ListsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showTask", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? ListTaskViewController {
            destination.titleList = listStore[(listTableView.indexPathForSelectedRow?.row)!].title
            listTableView.deselectRow(at: listTableView.indexPathForSelectedRow!, animated: true)
        }
    }
}

extension ListsViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("HEREEEEEPOOP")
            let cell = tableView.dequeueReusableCell(withIdentifier: "listcell", for: indexPath)
            cell.textLabel!.text = listStore[indexPath.row].title
//            print("HELLLOOOOO")
            
            return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

extension ListsViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.listStore[indexPath.row]
            
            DataBaseHelper.shareInstance.deleteList(title: row.title!)
            
            self.getLists()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
