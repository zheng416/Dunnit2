//
//  SharedTaskViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/12/21.
//

import UIKit

class SharedTaskViewController: UIViewController {

    var titleList: String?
    var owner: String?
    var listtasks = [TaskEntity]()
    @IBOutlet var sharedTaskTableView: UITableView!
    
    var taskShareStore = [[TaskEntity](), [TaskEntity]()]
    
    func getData() {
        print("owner??")
        print(owner)
         DataBaseHelper.shareInstance.fetchDBSharedTask(title: self.titleList!, owner: self.owner!, completion: {task in
            if task != nil {
                self.listtasks = task
                print("RETRIEVED")
                
                print(self.listtasks[0].isDone)
                print(self.listtasks[0].isDone)
                
                
                self.taskShareStore = [self.listtasks.filter{$0.isDone == false && $0.list == self.titleList}, self.listtasks.filter{$0.isDone == true && $0.list == self.titleList}]
                print("THis is what is inside tasks")
                //print(listtasks)
                print(self.taskShareStore)

                self.sharedTaskTableView.reloadData()
            }
        })
        // Fix this part
        // let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleList
        getData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(didTapInfoButton))

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapInfoButton() {
        // Redirect to a view controller that:
        // Display who shared it with you
        // Remove Button to remove the list
    }
    
}

extension SharedTaskViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SharedTaskViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return section == 0 ? "To-do" : "Done"
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return taskShareStore.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return taskShareStore[section].count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharedtaskcell", for: indexPath)
        let date = taskShareStore[indexPath.section][indexPath.row].date!
        let colorHex = taskShareStore[indexPath.section][indexPath.row].color
        print("Color HEX stuff")
        print(colorHex)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        cell.textLabel?.text = taskShareStore[indexPath.section][indexPath.row].title
        cell.detailTextLabel?.text = formatter.string(from: date)
        if (colorHex == nil) {
            cell.backgroundColor = .white
        }
        else {
            print("HELLOOOOOOOOOOOOOOO")
            cell.backgroundColor = UIColor(named: colorHex!)
        }
        print(cell)
        return cell
    }
}
