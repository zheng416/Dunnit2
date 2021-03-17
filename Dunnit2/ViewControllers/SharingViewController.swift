//
//  SharingViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/12/21.
//

import UIKit

class SharingViewController: UIViewController, UITextFieldDelegate {

    @IBOutlet var emailField: UITextField!
    
    public var completion: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailField.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Share", style: .done, target: self, action: #selector(didTapShareButton))
        

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
