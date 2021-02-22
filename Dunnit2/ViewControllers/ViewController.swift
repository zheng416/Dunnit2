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
              // User is signed in
              // ...
                print("Hi you are logged in!")
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
    
        let request = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, name"], tokenString: token, version: nil, httpMethod: .get)
        
        request.start(completionHandler: {connection, result, error in
            print("\(result)")
        })
    }
    
//    func createNewUser(email: String, api_id: UInt, name: String) {
//        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
//
//            // Check for errors
//            if err != nil {
//
//                // There was an error creating the user
//                self.showError("Error creating user")
//            }
//            else {
//                // User was created successfully, now store name
//                let db = Firestore.firestore()
//
//                db.collection("users").addDocument(data: ["name" : name, "uid" : result!.user.uid]) { (error) in
//
//                    if error != nil {
//                        // Show error message
//                        self.showError("Error saving user data")
//                    }
//                }
//
//                // Transition to the home screen
//                self.transitionToHome()
//
//            }
//        }
//    }
    


}

