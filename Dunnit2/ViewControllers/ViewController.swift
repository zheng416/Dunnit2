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
        
        let backgroundImage = UIImage.init(named: "background_2")
        let backgroundImageView = UIImageView.init(frame: self.view.frame)
        backgroundImageView.image = backgroundImage
        backgroundImageView.contentMode = .scaleAspectFill
        backgroundImageView.alpha = 0.69
        
        self.view.insertSubview(backgroundImageView, at: 0)
        
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
        // Hardcode guest email
        let email = "Guest"
        let user  = DataBaseHelper.shareInstance.fetchLocalUser()
        if (user.isEmpty){
            DataBaseHelper.shareInstance.createNewUser(email: email)
        }
        self.transitionToHome()
        
    }
}

