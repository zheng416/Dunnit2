//
//  SignUpViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import Firebase

class SignUpViewController: UIViewController, LoginButtonDelegate {
    @IBOutlet weak var nameTextField: UITextField!
    
    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        overrideUserInterfaceStyle = .light
        // Do any additional setup after loading the view.
        setupGoogleButton()
        setupFacebookButton()
        setUpElements()
    }
    
    func setupGoogleButton() {
        let googleIcon = UIImage(named: "google.png")
        let googleTinted = googleIcon?.withRenderingMode(.alwaysOriginal)
        let customButton = UIButton(type: .system)
        customButton.setImage(googleTinted, for: UIControl.State.normal)
        customButton.imageView?.contentMode = .scaleAspectFit
        customButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: -200, bottom: 10, right: 0)
        customButton.frame = CGRect(x: 40, y: 630, width: view.frame.width - 72, height: 50)
        customButton.backgroundColor = UIColor(red: 45/255, green: 89/255, blue: 134/255, alpha: 0.8)
        customButton.setTitle("Sign up with Google", for: .normal)
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
        Utilities.styleTextField(nameTextField)
        Utilities.styleTextField(emailTextField)
        Utilities.styleTextField(passwordTextField)
        Utilities.styleFilledButton(signUpButton)

    }
    
    func setupFacebookButton() {
        if let token = AccessToken.current,
                !token.isExpired {
            let token = token.tokenString
            
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
        
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
              if let error = error {
                let authError = error as NSError
                // There was an error creating the user
                self.showError("Error creating user \(authError)")
            
                return
              }
                // Transition to the home screen
                self.transitionToHome()
            }
            
        } else {
            let facebookIcon = UIImage(named: "facebook-logo.png")
            let facebookTinted = facebookIcon?.withRenderingMode(.alwaysOriginal)
            let customButton = UIButton(type: .system)
            customButton.setImage(facebookTinted, for: UIControl.State.normal)
            customButton.imageView?.contentMode = .scaleAspectFit
            customButton.imageEdgeInsets = UIEdgeInsets(top: 10, left: -150, bottom: 10, right: 0)
            customButton.frame = CGRect(x: 40, y: 700, width: view.frame.width - 72, height: 50)
            customButton.backgroundColor = UIColor(red: 45/255, green: 89/255, blue: 134/255, alpha: 0.8)
            customButton.setTitle("Sign up with Facebook", for: .normal)
            customButton.titleEdgeInsets = UIEdgeInsets(top: 10, left: -375, bottom: 10, right: 0)
            customButton.setTitleColor(.white, for: .normal)
            customButton.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
            customButton.layer.cornerRadius = 25
            customButton.addTarget(self, action: #selector (handleFacebookSignIn), for: .touchUpInside)
            view.addSubview(customButton)
        }
    }
    
    @objc func handleFacebookSignIn() {
        let FBloginButton = FBLoginButton()
        FBloginButton.delegate = self
        FBloginButton.permissions = ["public_profile", "email"]
        FBloginButton.isHidden = true
        view.addSubview(FBloginButton)
        FBloginButton.sendActions(for: .touchUpInside)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // Check the fields and validate that the data is correct . If everthing is correct, this method returns nil. Otherwise, it returns the error message.
    
    func validateFields() -> String? {
        
        // Check that all fields are filled in
        if nameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            emailTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" ||
            passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        
        // Check if password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // Password isn't secure enough
            return "Please make sure your password is at least 8 characters, contains a special character and a number."
        }
        return nil
    }
    
    @IBAction func signUpTapped(_ sender: Any) {
        
        // Validate the fields
        let error = validateFields()
        
        if error != nil {
            // There's something wrong with the fields, show error message
            showError(error!)
        }
        else {
            
            // Create cleaned versions of the data
            let name = nameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let email = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
            // Create the user
            Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            
                // Check for errors
                if err != nil {
                    
                    // There was an error creating the user
                    self.showError("Error creating user")
                }
                else {
                    // User was created successfully, now store name
                    let db = Firestore.firestore()
                    
                    db.collection("users").addDocument(data: ["name" : name, "uid" : result!.user.uid]) { (error) in
                        
                        if error != nil {
                            // Show error message
                            self.showError("Error saving user data")
                        }
                    }
                    
                    // Transition to the home screen
                    self.transitionToHome()
                    
                }
            }
            
        }
        
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        let token = result?.token?.tokenString
        print("token \(token)")
        if (token != nil) {
            let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
            
            let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current!.tokenString)
            print(credential)
            
            Auth.auth().signIn(with: credential) { (authResult, error) in
              if let error = error {
                let authError = error as NSError
                // There was an error creating the user
                self.showError("Error creating user \(authError)")
                // ...
                return
              }
                
                // Save to firestore
                let db = Firestore.firestore()
                request.start(completionHandler: {connection, result, error in
                    if (error == nil) {
                        guard let userDict = result as? [String:Any] else {
                                            return
                        }
                        let db = Firestore.firestore()
                        db.collection("users").addDocument(data: ["name" : userDict["name"], "uid" : userDict["id"], "email": userDict["email"]]) { (error) in
                            
                            if error != nil {
                                // Show error message
                                self.showError("Error saving user data")
                            }
                        }
                    }
                })
                
                // Transition to the home screen
                self.transitionToHome()
            }
        }
    }
    
}
