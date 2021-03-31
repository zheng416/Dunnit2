//
//  ForgetPasswordViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 3/30/21.
//

import UIKit

class ForgetPasswordViewController: UIViewController {
    
    
    @IBOutlet weak var emailField: UITextField!
    @IBOutlet weak var resetPasswordButton: UIButton!
    
    @IBOutlet weak var resetPasswordLabel: UILabel!
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpElements()
    }
    
    func setUpElements() {
        
        errorLabel.alpha = 0
        // Style the elements
        Utilities.styleTextField(emailField)
    }
    
    @IBAction func resetPasswordAction(_ sender: Any){
        guard let email = emailField.text , email != "" else {
            // Error
            self.showError("Email field is required!")
            return
        }
        
        DataBaseHelper.shareInstance.resetPassword(email: email, onSuccess: {
            self.view.endEditing(true)
            self.navigationController?.popViewController(animated: true)
            self.showError("Reset password email sent!")
        }, onError: { (errorMessage) in
            self.showError(errorMessage)
        })
        
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
}
