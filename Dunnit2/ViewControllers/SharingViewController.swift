//
//  SharingViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/12/21.
//

import UIKit

class SharingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField: UITextField!
    
    @IBOutlet weak var sharedEmails: UITableView!
    
    var emailStore = Array<Any>()
    
    var lid: String?
    
    public var completion: ((String) -> Void)?
    
    func getData() {
        DataBaseHelper.shareInstance.fetchSharedEmails(lid: lid!, completion: { share in
            if share != nil {
                print("GIT TTTTTT")
                self.emailStore = share
                self.sharedEmails.reloadData()
            }
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapShareButton))
        
        getData()

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapShareButton() {
        if let emailText = emailField.text, !emailText.isEmpty {
            completion?(emailText)
        }
    }
    

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}

extension SharingViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

extension SharingViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return emailStore.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "shareEmail", for: indexPath)
        cell.textLabel?.text = emailStore[indexPath.row] as! String
        
        return cell
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
}

extension SharingViewController {
    func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let deleteAction = UIContextualAction(style: .normal, title: nil) { (action, sourceView, completionHandler) in
            let row = self.emailStore[indexPath.row]
            
            // DataBaseHelper.shareInstance.deleteList(id: row.id!)
            
            DataBaseHelper.shareInstance.removeSharedEmail(lid: self.lid!, email: row as! String)
            
            self.getData()
            
        }
        deleteAction.image = UIImage(systemName: "trash")
        deleteAction.backgroundColor = .systemRed
        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
}
