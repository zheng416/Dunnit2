//
//  ViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import GoogleSignIn
import FBSDKLoginKit

class ViewController: UIViewController, LoginButtonDelegate {
    
    

    @IBOutlet weak var signUpButton: UIButton!
    
    @IBOutlet weak var loginButton: UIButton!
    
    
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
            
            request.start(completionHandler: {connection, result, error in
                print("\(result)")
            })
        } else {
            let loginButton = FBLoginButton()
            // Obtain all constraints for the button:
            if let facebookButtonHeightConstraint = loginButton.constraints.first(where: { $0.firstAttribute == .height }) {
                loginButton.removeConstraint(facebookButtonHeightConstraint)
            }
            loginButton.widthAnchor.constraint(equalToConstant: 500).isActive = true
            // Iterate over array and test constraints until we find the correct one:
//            for lc in layoutConstraintsArr { // or attribute is NSLayoutAttributeHeight etc.
//               if ( lc.constant == 28 ){
//                 // Then disable it...
//                 lc.isActive = false
//                 break
//               }
//            }
            let newCenter = CGPoint(x: self.view.frame.width / 2, y: self.view.frame.height - 350)
            loginButton.center = newCenter
            loginButton.delegate = self
            loginButton.permissions = ["public_profile", "email"]
            view.addSubview(loginButton)
        }
        
       
        
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


}

