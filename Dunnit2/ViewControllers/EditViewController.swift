//
//  EditViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/4/21.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {

    var titleStr: String?
    
    var dateVal: Date?
    
    var bodyStr: String?
    
    @IBOutlet var titleField: UITextField!
    
    @IBOutlet var dateField: UIDatePicker!
    
    @IBOutlet var bodyField: UITextField!
    
    public var completion: ((String, String, Date) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.text = titleStr
        dateField.date = dateVal!
        bodyField.text = bodyStr
        titleField.delegate = self
        bodyField.delegate = self
        
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self.description, action: #selector(didTapSaveButton))

        // Do any additional setup after loading the view.
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titleField.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = dateField.date
            
            completion?(titleText, bodyText, targetDate)
            print("Saved")
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
