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

extension UIColor {
    var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
        var r: CGFloat = 0, g: CGFloat = 0, b: CGFloat = 0, a: CGFloat = 0
        if getRed(&r, green: &g, blue: &b, alpha: &a) {
            return (r,g,b,a)
        }
        return (0, 0, 0, 0)
    }

    // hue, saturation, brightness and alpha components from UIColor**
    var hsba: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue: CGFloat = 0, saturation: CGFloat = 0, brightness: CGFloat = 0, alpha: CGFloat = 0
        if getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha) {
            return (hue, saturation, brightness, alpha)
        }
        return (0,0,0,0)
    }

    var htmlRGB: String {
        return String(format: "#%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255))
    }

    var htmlRGBA: String {
        return String(format: "#%02x%02x%02x%02x", Int(rgba.red * 255), Int(rgba.green * 255), Int(rgba.blue * 255), Int(rgba.alpha * 255) )
    }
}

extension UIColor {
    convenience init(hexString: String) {
        let hex = hexString.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int = UInt64()
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // RGBA (32-bit)
            (r, g, b, a) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        self.init(red: CGFloat(r) / 255, green: CGFloat(g) / 255, blue: CGFloat(b) / 255, alpha: CGFloat(a) / 255)
    }
}

class HomeViewController: UIViewController {
    
    let transition = SlideInTransition()
    var topView: UIView?
    
    var menu: MenuType?

    
    @IBOutlet var tableView: UITableView!
    
    var taskStore = [[TaskEntity](), [TaskEntity]()]
    //local
    func getData() {
        let tasks = DataBaseHelper.shareInstance.fetchLocalTask()
        taskStore = [tasks.filter{$0.isDone == false}, tasks.filter{$0.isDone == true}]
        tableView.reloadData()
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
            getData()
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
//                DispatchQueue.main.async {
                    self.navigationController?.popToRootViewController(animated: true)
                    DataBaseHelper.shareInstance.saveList(title: title)
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
                DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false, list: "all", color: UIColor(cgColor: color).htmlRGBA)
                print("PRINT THE COLOR")
                print(UIColor(cgColor: color).htmlRGBA)
                self.getData()
            }
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
//    @IBAction func didTapSort() {
//        print("Sort button pressed!")
//        // Show add vc
//        let sortingStoryboard = UIStoryboard(name: "Home", bundle: nil)
//        guard let vc = sortingStoryboard.instantiateViewController(identifier: "sortingvc") as? SortingViewController else {
//            return
//        }
//        self.addChild(vc)
//        vc.view.frame = self.view.frame
//        self.view.addSubview(vc.view)
//        vc.didMove(toParent: self)
//    }
    
    
    private func setupSortMenuItem() {
        let saveMenu = UIMenu(title: "", children: [
            UIAction(title: "By Time", image: UIImage(systemName: "doc.on.doc")) { action in
                    //Copy Menu Child Selected
                },
             UIAction(title: "By Title", image: UIImage(systemName: "pencil")) { action in
                    //Rename Menu Child Selected
                },
             UIAction(title: "Duplicate", image: UIImage(systemName: "plus.square.on.square")) { action in
                    //Duplicate Menu Child Selected
                },
             UIAction(title: "Move", image: UIImage(systemName: "folder")) { action in
                    //Move Menu Child Selected
                },
              ])
        
        
        let saveButton = UIBarButtonItem(title: "Sort", menu: saveMenu)
        
        navigationItem.rightBarButtonItem = saveButton

    }
    

    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        getData()
        setupSortMenuItem()
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
        let colorHex = taskStore[indexPath.section][indexPath.row].color
        print("Color HEX stuff")
        print(colorHex)
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        cell.textLabel?.text = taskStore[indexPath.section][indexPath.row].title
        cell.detailTextLabel?.text = formatter.string(from: date)
        if (colorHex == nil) {
            cell.backgroundColor = .white
        }
        else {
            print("HELLOOOOOOOOOOOOOOO")
            cell.backgroundColor = UIColor(hexString: colorHex!)
        }
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
