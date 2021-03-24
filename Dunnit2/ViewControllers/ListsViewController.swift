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
        
        listStore = templists.filter{$0.owner == user[0].email}
        listTableView.reloadData()
    }
    
    @objc func loadList(notification: NSNotification){
        //load data here
        getLists()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(loadList), name: NSNotification.Name(rawValue: "load"), object: nil)
        getLists()
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
            
            DataBaseHelper.shareInstance.deleteList(id: row.id!)
            
            self.getLists()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
