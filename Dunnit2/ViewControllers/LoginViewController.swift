//
//  LoginViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import Firebase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        setupGoogleButton()
        setUpElements()
    }
    
    func setupGoogleButton() {
        let googleIcon = UIImage(named: "google.png")
        let customButton = UIButton(type: .system)
        customButton.setImage(googleIcon, for: UIControl.State.normal)
        customButton.imageView?.contentMode = .scaleAspectFit
        customButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: -200, bottom: 10, right: 0)
        customButton.frame = CGRect(x: 40, y: 630, width: view.frame.width - 72, height: 50)
        customButton.backgroundColor = UIColor(red: 45/255, green: 89/255, blue: 134/255, alpha: 0.8)
        customButton.setTitle("Sign in with Google", for: .normal)
        customButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: -475, bottom: 10, right: 0)
        customButton.setTitleColor(.white, for: .normal)
        customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        customButton.layer.cornerRadius = 25
        customButton.addTarget(self, action: #selector (handleGoogleSignIn), for: .touchUpInside)
        view.addSubview(customButton)
        GIDSignIn.sharedInstance()?.presentingViewController = self
    }
    
    @objc func handleGoogleSignIn() {
        GIDSignIn.sharedInstance().signIn()
    }
    
    func setUpElements() {
        
        // Hide the error label
        errorLabel.alpha = 0
        
        // Style the elements
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(loginButton)
    }

    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }

    @IBAction func loginTapped(_ sender: Any) {
        
        // TODO: Validate Text Fields
        
        // Create cleaned versions of the text field
        let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        // Signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            
            if error != nil {
                // Couldn't sign in
                self.errorLabel.text = error!.localizedDescription
                self.errorLabel.alpha = 1
            }
            else {
                
                let storyboard = UIStoryboard(name: "Home", bundle: nil)
                let vc = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
                self.view.window?.rootViewController = vc
                self.view.window?.makeKeyAndVisible()
                
            }
        }
        
    }
}
