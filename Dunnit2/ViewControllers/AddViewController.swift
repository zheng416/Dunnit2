//
//  AddViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/23/21.
//

import UIKit

class AddViewController: UIViewController, UITextFieldDelegate {

    
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    public var completion: ((String, String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlefield.delegate = self // rid of keyboard
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titlefield.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            
            completion?(titleText, bodyText, targetDate)
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
