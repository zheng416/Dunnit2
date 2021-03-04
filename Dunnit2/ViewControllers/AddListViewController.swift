//
//  AddListViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/2/21.
//

import UIKit

class AddListViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet var titlefield: UITextField!
    
    public var completion: ((String) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        titlefield.delegate = self // rid of keyboard
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))
        

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titlefield.text, !titleText.isEmpty {
            completion?(titleText)
        }
    }
    

   
    
    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }

}
