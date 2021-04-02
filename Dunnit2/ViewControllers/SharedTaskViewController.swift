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
    var id: String?
    var listtasks = [TaskEntity]()
    @IBOutlet var sharedTaskTableView: UITableView!
    
    var taskShareStore = [[TaskEntity](), [TaskEntity]()]
    
    func getData() {
        print("owner??")
        print(owner)
         DataBaseHelper.shareInstance.fetchDBSharedTask(title: self.id!, owner: self.owner!, completion: {task in
            if task != nil {
                self.listtasks = task
                print("RETRIEVED \(task)")
                
//                print(self.listtasks[0].isDone)
//                print(self.listtasks[0].isDone)
                
                
                self.taskShareStore = [self.listtasks.filter{$0.isDone == false && $0.list == self.id}, self.listtasks.filter{$0.isDone == true && $0.list == self.id}]
                print("THis is what is inside tasks")
                //print(listtasks)
                print(self.taskShareStore)

                self.sharedTaskTableView.reloadData()
            }
        })
        // Fix this part
        // let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        
        
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleList
        getData()
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Info", style: .plain, target: self, action: #selector(didTapInfoButton))

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapInfoButton() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "info") as? InfoViewController else {
            return
        }
        vc.title = "Info"
        vc.owner = owner
        vc.titleList = titleList
        vc.id = id
        print("INFOOOOOOOOOOOOOOOOO")
        print(id)
        vc.navigationItem.largeTitleDisplayMode = .never
//        vc.completion = {title, shared, color in
//            DispatchQueue.main.async {
//                self.navigationController?.popViewController(animated: true)
//                DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false, list: self.titleList!, color: color)
//                self.getData()
//            }
//        }
        navigationController?.pushViewController(vc, animated: true)
        
        
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
        let topics = getTopics()
        let cell = tableView.dequeueReusableCell(withIdentifier: "sharedtaskcell", for: indexPath)
        let viewWithTag = cell.viewWithTag(100)
        viewWithTag?.removeFromSuperview()
        let date = taskShareStore[indexPath.section][indexPath.row].date!
        let color = taskShareStore[indexPath.section][indexPath.row].color
        let priority = taskShareStore[indexPath.section][indexPath.row].priority
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY HH:mm"
        cell.textLabel?.attributedText = NSMutableAttributedString()
            .normal(taskShareStore[indexPath.section][indexPath.row].title!)
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
                .normal(taskShareStore[indexPath.section][indexPath.row].title! + "  ( ")
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

//            // Add a rectangle view
//            let rectangle = UIView(frame: CGRect(x: (cell.textLabel?.frame.size.width)! + 50, y: (cell.textLabel?.frame.size.height)! - 10, width: label.frame.size.width, height: 20))
//
//            var background = UIColor.white
//            if (topics["red"] as? String) == color {
//                background = UIColor.systemRed
//            }
//            else if (topics["orange"] as? String) == color {
//                background = UIColor.systemOrange
//            }
//            else if (topics["yellow"] as? String) == color {
//                background = UIColor.systemYellow
//            }
//            else if (topics["green"] as? String) == color {
//                background = UIColor.systemGreen
//            }
//            else if (topics["blue"] as? String) == color {
//                background = UIColor.systemBlue
//            }
//            else if (topics["purple"] as? String) == color {
//                background = UIColor.systemPurple
//            }
//            else if (topics["indigo"] as? String) == color {
//                background = UIColor.systemIndigo
//            }
//            else if (topics["teal"] as? String) == color {
//                background = UIColor.systemTeal
//            }
//            else if (topics["pink"] as? String) == color {
//                background = UIColor.systemPink
//            }
//            else if (topics["black"] as? String) == color {
//                background = UIColor.black
//            }
//
//            rectangle.backgroundColor = background
//
//            rectangle.layer.cornerRadius = 5
//
//            rectangle.tag = 100
//
//            // Add the label to your rectangle
//            rectangle.addSubview(label)
//
//            // Add the rectangle to your cell
//            cell.addSubview(rectangle)
        }
        return cell
    }
}
