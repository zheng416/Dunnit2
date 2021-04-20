//
//  BlockListViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 4/19/21.
//

import UIKit

class BlockListViewController: UIViewController {

    @IBOutlet weak var BlockedList: UITableView!
    
    @IBOutlet weak var emailBlockField: UITextField!
    var blockStore = Array<Any>()
    
    func getBlocked() {
        DataBaseHelper.shareInstance.fetchBlocked(completion: { block in
            if block != nil {
                print("GIT TTTTTT")
                self.blockStore = block
                print(self.blockStore)
                self.BlockedList.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getBlocked()

        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add to Blocked", style: .done, target: self, action: #selector(didTapAddBlockButton))
    }
    
    @objc func didTapAddBlockButton() {
        if let emailText = emailBlockField.text, !emailText.isEmpty {
            DataBaseHelper.shareInstance.validEmail(email: emailText, onSuccess: {success in
                if success {
                    DataBaseHelper.shareInstance.addBlockUser(email: emailText)
                    DataBaseHelper.shareInstance.removeInviteBlocked(userEmail: emailText, completion: {complete in
                        if complete {
                            let dialogMessage = UIAlertController(title: "", message: "User is now blocked.", preferredStyle: .alert)
                            self.present(dialogMessage, animated: true, completion: nil)
                            let when = DispatchTime.now() + .seconds(1)
                            DispatchQueue.main.asyncAfter(deadline: when) {
                                dialogMessage.dismiss(animated: true, completion: nil)
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    })
                    
                    
                } else {
                    let dialogMessage = UIAlertController(title: "", message: "Error: user not found", preferredStyle: .alert)
                    self.present(dialogMessage, animated: true, completion: nil)
                    let when = DispatchTime.now() + .seconds(1)
                    DispatchQueue.main.asyncAfter(deadline: when) {
                        dialogMessage.dismiss(animated: true, completion: nil)
                    }
                }
            })
        }
    }
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
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

extension BlockListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension BlockListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blockStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "block", for: indexPath)
        cell.textLabel?.text = blockStore[indexPath.row]  as! String
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension BlockListViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.blockStore[indexPath.row]
            
            // DataBaseHelper.shareInstance.deleteList(id: row.id!)
            
//            DataBaseHelper.shareInstance.removeSharedEmail(lid: self.lid!, email: row as! String)
            print(row)
            DataBaseHelper.shareInstance.removeBlockedEmail(email: row as! String, onSuccess: {success in
                if success {
                    self.getBlocked()
                }
            })
            
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
