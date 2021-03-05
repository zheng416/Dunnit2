//
//  ListTaskViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/4/21.
//

import UIKit

class ListTaskViewController: UIViewController {

    var titleList: String?
    @IBOutlet var tableTaskView: UITableView!
    
    var taskListStore = [[TaskEntity](), [TaskEntity]()]
    
    func getData() {
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        taskListStore = [tasks.filter{$0.isDone == false && $0.list == self.titleList}, tasks.filter{$0.isDone == true && $0.list == self.titleList}]

        tableTaskView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleList
        getData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(didTapAddButton))
        // Do any additional setup after loading the view.
    }
    
    @objc func didTapAddButton() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "add") as? AddViewController else {
            return
        }
        vc.title = "New Task"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date in
            DispatchQueue.main.async {
                self.navigationController?.popViewController(animated: true)
                DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false, list: self.titleList!)
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "taskCell", for: indexPath)
        let date = taskListStore[indexPath.section][indexPath.row].date!
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        cell.textLabel?.text = taskListStore[indexPath.section][indexPath.row].title
        cell.detailTextLabel?.text = formatter.string(from: date)
        print(cell)
        return cell
    }
}

extension ListTaskViewController {
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let doneAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.taskListStore[0][indexPath.row]
            
            DataBaseHelper.shareInstance.update(title: row.title!, isDone: true)
            
            self.getData()
        }
        doneAction.image = UIImage(systemName: "checkmark.circle")
        doneAction.backgroundColor = .systemGreen
        return indexPath.section == 0 ? UISwipeActionsConfiguration(actions: [doneAction]) : nil
    }
    
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.taskListStore[indexPath.section][indexPath.row]
            
            DataBaseHelper.shareInstance.deleteData(title: row.title!)
            
            self.getData()
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
