//
//  SceneDelegate.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/15/21.
//

import UIKit
import GoogleSignIn
import FirebaseAuth

class SceneDelegate: UIResponder, UIWindowSceneDelegate, GIDSignInDelegate {

    var window: UIWindow?


    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
        
        let loginStory = UIStoryboard(name: "Main", bundle: nil)
        let homeStory = UIStoryboard(name: "Home", bundle: nil)
        let settingsStory = UIStoryboard(name:"Settings", bundle: nil)
        if let windowScene = scene as? UIWindowScene {
            self.window = UIWindow(windowScene: windowScene)
            if !DataBaseHelper.shareInstance.fetchLocalUser().isEmpty {
                self.window!.rootViewController = homeStory.instantiateViewController(withIdentifier: "main")
            } else {
                self.window!.rootViewController = loginStory.instantiateViewController(withIdentifier: "welcome")
            }
            self.window?.makeKeyAndVisible()
        }
        GIDSignIn.sharedInstance()?.clientID = "617395248965-6mubcp9nhela7iuplf28kglbqh3bu1li.apps.googleusercontent.com"
        GIDSignIn.sharedInstance()?.delegate = self
    }
    
    func sign(_ signIn: GIDSignIn!, didSignInFor user: GIDGoogleUser!, withError error: Error!) {
        if error != nil {
                    return
                }
                
                guard let authentication = user.authentication else { return }
                let credential = GoogleAuthProvider.credential(withIDToken: authentication.idToken, accessToken: authentication.accessToken)
                let uid = GIDSignIn.sharedInstance()?.currentUser.userID
                let name = GIDSignIn.sharedInstance()?.currentUser.profile.name
                let email = GIDSignIn.sharedInstance()?.currentUser.profile.email
                
                Auth.auth().signIn(with: credential) { (authResult, error) in
                    if let error = error {
                        print(error.localizedDescription)
                        return
                    }
                    DataBaseHelper.shareInstance.saveToDB(email: email!)
                    DataBaseHelper.shareInstance.saveuser(email: email!, name: name!, uid: uid!, completion: {result in
                        if result{
                            print("Google INFO \(name) \(email)")
                            DataBaseHelper.shareInstance.createNewUser(name: name as! String, email: email as! String)
                            DataBaseHelper.shareInstance.fetchListsDB(completion: {success in
                                if success {
                                    print("fetched taskslist from database!")
                                }
                            })
                            DataBaseHelper.shareInstance.fetchDBTask (completion: {success in
                                if success{
                                    print("Loaded data from database")
                                    // Transition to the home screen
                                    let storyboard =  UIStoryboard(name: "Home", bundle: nil)
                                    // redirect the user to the home controller
                                    self.window!.rootViewController = storyboard.instantiateViewController(withIdentifier: "main")
                                    self.window!.makeKeyAndVisible()
                                    return
                                }
                                print("cannot load data from database")
                                return
                            })
                        }
                        
                    })
                }
    }
    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

