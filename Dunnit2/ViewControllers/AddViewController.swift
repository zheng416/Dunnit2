//
//  AddViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/23/21.
//

import UIKit


class AddViewController: UIViewController, UITextFieldDelegate {
    
    var colorWell: UIColorWell!
    
    @IBOutlet var titlefield: UITextField!
    @IBOutlet var bodyField: UITextField!
    @IBOutlet var datePicker: UIDatePicker!
    
    public var completion: ((String, String, Date, CGColor) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        titlefield.delegate = self // rid of keyboard
        bodyField.delegate = self
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .done, target: self, action: #selector(didTapSaveButton))

        // Do any additional setup after loading the view.
        
        
        // RANDOM BULLSHIT THAT WILL BE DELETED LATER. IT'S JUST A PLACEHOLDER FOR SPRINT 1 LOL
        addColorWell()
    }
    
    func addColorWell() {
        colorWell = UIColorWell(frame: CGRect(x: 0, y: 0, width: 50, height: 50))
        self.view.addSubview(colorWell)
        colorWell.center = view.center
        colorWell.title = "Tag Color"
        colorWell.addTarget(self, action: #selector(colorWellValueChanged(_ :)), for: .valueChanged)
    }
    
    @objc func colorWellValueChanged(_ sender: Any) {
        self.view.backgroundColor = colorWell.selectedColor
    }
    
    @objc func didTapSaveButton() {
        if let titleText = titlefield.text, !titleText.isEmpty,
           let bodyText = bodyField.text, !bodyText.isEmpty {
            let targetDate = datePicker.date
            print("HERE IS THE FUCKING COLOR")
            print(UIColor(cgColor: self.view.backgroundColor!.cgColor).htmlRGBA)
            completion?(titleText, bodyText, targetDate, self.view.backgroundColor!.cgColor)
        }
    }

    // dismiss keyboard
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
