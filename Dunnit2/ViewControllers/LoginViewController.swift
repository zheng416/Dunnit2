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
import UserNotifications

class LoginViewController: UIViewController, LoginButtonDelegate {

    @IBOutlet weak var emailTextField: UITextField!
    
    
    @IBOutlet weak var passwordTextField: UITextField!
    
    @IBOutlet weak var loginButton: UIButton!
    
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
        customButton.frame = CGRect(x: 40, y: 580, width: view.frame.width - 72, height: 50)
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
            customButton.frame = CGRect(x: 40, y: 650, width: view.frame.width - 72, height: 50)
            customButton.backgroundColor = UIColor(red: 45/255, green: 89/255, blue: 134/255, alpha: 0.8)
            customButton.setTitle("Sign in with Facebook", for: .normal)
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
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
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
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
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
                let dialogMessage = UIAlertController(title: "", message: "Successfully Logged In", preferredStyle: .alert)
                self.present(dialogMessage, animated: true, completion: nil)
                let when = DispatchTime.now() + .seconds(3)
                DispatchQueue.main.asyncAfter(deadline: when) {
                    dialogMessage.dismiss(animated: true, completion: nil)
                }
                //TODO update using the 
                DataBaseHelper.shareInstance.createNewUser(email: email)
                DataBaseHelper.shareInstance.saveToDB(email:email)
                DataBaseHelper.shareInstance.fetchDBUser(email: email, completion:{message in
                    if message.contains("Success"){
                        DataBaseHelper.shareInstance.fetchListsDB(completion: {success in
                            if success {
                                print("fetched taskslist from database!")
                            }
                        })
                        DataBaseHelper.shareInstance.fetchDBTask (completion: {success in
                            if success{
                                print("Loaded data from database")
                                // Transition to the home screen
                                self.transitionToHome()

                            }
                            print("cannot load data from database")
                            return
                        })
                        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { success, error in
                            if success {
                                print("success for notifications")
                            } else if let error = error {
                                print("error occurred")
                            }
                        })
                    }
                    else if message.contains("Error"){
                        return
                    }
                    else{
                        print("Unknown return from compelition")
                        return
                    }
                }  )
            }
        }
        
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
                request.start(completionHandler: {connection, result, error in
                    if (error == nil) {
                        guard let userDict = result as? [String:Any] else {
                                            return
                        }
                        DataBaseHelper.shareInstance.saveToDB(email: userDict["email"] as! String)
                        DataBaseHelper.shareInstance.createNewUser(email: userDict["email"] as! String)
                        DataBaseHelper.shareInstance.FBfetchuname(email: userDict["email"] as! String, completion: {name in
                            print("name",name)
                            DataBaseHelper.shareInstance.updateName(name: name, email: userDict["email"] as! String)
                        } )
                        DataBaseHelper.shareInstance.fetchListsDB(completion: {success in
                            if success {
                                print("fetched taskslist from database!")
                            }
                        })
                        DataBaseHelper.shareInstance.fetchDBTask (completion: {success in
                            if success{
                                print("Loaded data from database")
                                // Transition to the home screen
                                self.transitionToHome()

                            }
                            print("cannot load data from database")
                            return
                        })
                    } else {
                        print("ERROR IN FB LOGIN \(error)")
                    }
                })
            }
        }
    }
}
