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

class ViewController: UIViewController /*, LoginButtonDelegate*/ {
    
    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    @IBOutlet weak var guestButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        overrideUserInterfaceStyle = .light
        
        setUpElements()
    }
    
    func transitionToHome() {
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "main") as UIViewController
        self.view.window?.rootViewController = vc
        self.view.window?.makeKeyAndVisible()
    }
    
    func setUpElements() {
        
        Utilities.styleFilledButton(signUpButton)
        
        Utilities.styleHollowButton(loginButton)
    }
    
    @IBAction func guestButtonTapped(_ sender: Any) {
        
        // TODO: Validate Text Fields
        print("guest tapped")
        
        // Create cleaned versions of the text field
        let email = "guest@guest.com"
        
        DataBaseHelper.shareInstance.createNewUser(email: email, guest: true)
        
        
    }
    
}

