//
//  ViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit
import FirebaseAuth
import Firebase

class ViewController: UIViewController, LoginButtonDelegate {
    
    

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var errorLabel: UILabel!
    
    
    @IBOutlet weak var GoogleSignIn: GIDSignInButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overrideUserInterfaceStyle = .light
        GIDSignIn.sharedInstance()?.presentingViewController = self

        setUpElements()
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
            let FBloginButton = FBLoginButton()
            FBloginButton.center = view.center
            FBloginButton.delegate = self
            FBloginButton.permissions = ["public_profile", "email"]
            view.addSubview(FBloginButton)
        }
        
       
        
    }
    
    func showError(_ message:String) {
        errorLabel.text = message
        errorLabel.alpha = 1
    }
    
    func transitionToHome() {
        let homeViewController = storyboard?.instantiateViewController(identifier: Constants.Storyboard.homeViewController) as? HomeViewController
        
        view.window?.rootViewController = homeViewController
        view.window?.makeKeyAndVisible()
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(signUpButton)
        
        Utilities.styleHollowButton(loginButton)
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
    
//        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
//
//        request.start(completionHandler: {connection, result, error in
//            print("\(result)")
//        })
    }
}

