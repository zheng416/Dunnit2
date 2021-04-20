//
//  SharedViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/12/21.
//

import UIKit

class SharedViewController: UIViewController {

    
    @IBOutlet var sharedTableView: UITableView!
    var sharelist = [SharedEntity]()
    var shareStore = [ListEntity]()
    var shareListNameStore = [ListEntity]()
    
    func getUser() -> [String: Any] {
        var user = DataBaseHelper.shareInstance.fetchLocalUser()
        if user.isEmpty{
            DataBaseHelper.shareInstance.createNewUser(name: "test", email:"test@email.com")
            user = DataBaseHelper.shareInstance.fetchLocalUser()
        }
        
        // Unpack user entity to dictionary
        var endUser = [String:Any]()
        for x in user as [UserEntity] {
            endUser["name"] = x.name
            endUser["email"] = x.email
            endUser["darkMode"] = x.darkMode
            endUser["notification"] = x.notification
            endUser["sound"] = x.sound
        }
        
        print("user is \(endUser)")
        
        return endUser
    }
    
    func getLists() {
        DataBaseHelper.shareInstance.fetchSharedDB(completion: {success in
            if success {
                print("SUCCESSSSSS")
                print("fetched sharedLists from database!")
                  DataBaseHelper.shareInstance.fetchSharedLists(completion: {
                    list in
                    if list != nil {
                        self.shareListNameStore = list
                        print("SHARESHARE")
                        print(self.shareListNameStore)
                        self.shareStore = self.shareListNameStore
                        self.sharedTableView.reloadData()
                        print("LIST")
                        print(self.shareStore)
                    }
                })
//                print(self.shareListNameStore[0].title)
//                print(self.shareListNameStore[0].shared)
            }
        })
        
        
//        shareStore = DataBaseHelper.shareInstance.fetchLists()
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        getLists()
        print("HEELELELEMFLKENN")
        // Do any additional setup after loading the view.
        let userInfo = getUser()
        let darkModeOn = userInfo["darkMode"] as! Bool
        if darkModeOn {
            overrideUserInterfaceStyle = .dark
            navigationController?.navigationBar.barTintColor = UIColor.black
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.white]
        } else {
            overrideUserInterfaceStyle = .light
            navigationController?.navigationBar.barTintColor = UIColor.white
            navigationController?.navigationBar.titleTextAttributes = [NSAttributedString.Key.foregroundColor:UIColor.black]
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
       getLists()
    }
   

}

extension SharedViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "showSharedTask", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let destination = segue.destination as? SharedTaskViewController {
            destination.titleList = shareStore[(sharedTableView.indexPathForSelectedRow?.row)!].title
            destination.owner = shareStore[(sharedTableView.indexPathForSelectedRow?.row)!].owner
            destination.id = shareStore[(sharedTableView.indexPathForSelectedRow?.row)!].id
            print("AMONG US")
            print(destination.titleList)
            print(destination.owner)
            sharedTableView.deselectRow(at: sharedTableView.indexPathForSelectedRow!, animated: true)
        }
    }
}

extension SharedViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return shareStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        print("BOOOOOOOOO")
            let cell = tableView.dequeueReusableCell(withIdentifier: "sharecell", for: indexPath)
            cell.textLabel!.text = shareStore[indexPath.row].title
            print("HELLLOOOOO")
            
            return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
}

//extension ListsViewController {
//    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
//        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
//            let row = self.listStore[indexPath.row]
//
//            DataBaseHelper.shareInstance.deleteList(title: row.title!)
//
//            self.getLists()
//        }
//        deleteAction.image = UIImage(systemName: "trash")
//        deleteAction.backgroundColor = .systemRed
//        return UISwipeActionsConfiguration(actions: [deleteAction])
//    }
//}
