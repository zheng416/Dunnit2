//
//  DatabaseHelper.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/24/21.
//

import Foundation
import CoreData
import UIKit
import Firebase
import FirebaseCore
import FirebaseFirestore

func getBoolFromAny(paramAny: Any)->Bool {
    let result = "\(paramAny)"
    return result == "1"
}
class DataBaseHelper {
    static let shareInstance = DataBaseHelper()
    let db = Firestore.firestore()
    func FBfetchuname(email:String,completion: @escaping (String)->Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (docs, err) in
            if let err = err{
                print("cannot fetch user name from firebase: \(err)")
                return
            }
            else {
                print("email for the database", email)
                print(docs?.documents)
                let name = docs?.documents[0].get("name")
                print("name fethced from database",name)
                completion(name as! String)
            }
        }
        return
    }

    func saveUserInFB(name:String, email:String, uid:String,completion:@escaping(Bool)->Void) {
        db.collection("users").addDocument(data: ["name" : name, "uid" : uid, "email": email]) { (error) in
            
            if error != nil {
                // Show error message
                print("Error saving user data\(error)")
                return
            }
            completion(true)
        }
    }
    func saveuser(email: String, name: String, uid:String,completion: @escaping(Bool)->Void) {
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (users,err) in
            if err != nil{
                print("cannot fetch user name from firebase: \(err)")
                completion(false)
            }
            else {
                print("number of users found: \(users?.count)")
                if users!.count > 1{
                    print("multiple users found")
                    completion(false)
                }
                else if users!.count == 0{
                    print("no user was found in the database, create new user: \(name)")
                    self.saveUserInFB(name: name, email: email, uid: uid, completion: {result in
                        if result{
                           completion(true)
                        }
                    })
                }
                else if users!.count == 1{
                    print("user already exists, no need to create new user")
                    completion(true)
                }
            }
        }
    }
    func save(title: String, body: String, date: Date, isDone: Bool, list: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let managedContext = appDelegate.persistentContainer.viewContext
        //print(result.title!,result.body!,result.date!,result.isDone)
        var email = ""
        do{
            let users = try managedContext.fetch(fetchUser)
            if users.count > 1{
                print("multiple user was found ")
                return
            }
            email = (users[0] as! UserEntity).email!
        }
        catch{
            print("cannnot find user")
        }
        let docData: [String: Any] = [
            "email" : email,
            "user" : "test",
            "body" : body,
            "title": title,
            "date":date,
            "isDone" : isDone,
            "list": list
        ]
        db.collection("task").document("test"+title).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        let instance = TaskEntity(context: managedContext)
        instance.title = title
        instance.body = body
        instance.date = date
        instance.isDone = isDone
        instance.list = list
        print(instance.date!)
        do {
            print("Saved.")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        /*db.collection("task").getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                for document in querySnapshot!.documents {
                    print("\(document.documentID) => \(document.data())")
                }
            }
        }*/
        
    }
    
    func deleteData(title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        do {
            
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            // Database access
            // TODO: Change the document title in both write and delete
            db.collection("task").document("test"+title).delete() { err in
                if let err = err {
                    print("Error removing document named \("test"+title): \(err)")
                } else {
                    print("Document \("test"+title) successfully deleted!")
                }
            }
            managedContext.delete(objectToDelete)


            do {
                print("Deleted.")
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    func fetchLocalTask() -> [TaskEntity] {
            var fetchingImage = [TaskEntity]()
            
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return fetchingImage }
            
            let managedContext = appDelegate.persistentContainer.viewContext
            
            let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
            
            do {
                print("All Data.")
                fetchingImage = try managedContext.fetch(fetchRequest) as! [TaskEntity]
            } catch {
                print(error)
            }
            return fetchingImage
    }
    func fetchDBTask(completion: @escaping (_ message: Bool) -> Void) {
        var fetchingImage = [TaskEntity]()
        var newImage = [TaskEntity]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        var titlelist = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        do {
            fetchingImage = try managedContext.fetch(fetchRequest) as! [TaskEntity]
            for result in fetchingImage as [TaskEntity] {
                print(result.title!,result.body!,result.date!,result.isDone)
                titlelist.append(result.title!)
            }
            let user = try managedContext.fetch(fetchUser)
            if user.count > 1{
                print("multiple user was found ")
                completion(false)
                return
            }
            if (user.isEmpty || user.count == 0){
                print("not local user was found when fetching data")
                return
            }
            let email = (user[0] as! UserEntity).email
            print("Ckecking for duplicate Data.")
            self.db.collection("task").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if (querySnapshot?.count == 0){
                        print("No task found")
                        completion(true)
                    }
                    for document in querySnapshot!.documents {
                        let title = document.get("title")!
                        if titlelist.contains(title as! String){
                            continue
                        }
                        let instance = TaskEntity(context: managedContext)
                        instance.title = title as? String
                        instance.body = document.get("body")! as? String
                        instance.date = (document.get("date")! as! Timestamp).dateValue() as? Date
                        instance.isDone = getBoolFromAny(paramAny: document.get("isDone")!)
                        print(title)
                        do{
                            try managedContext.save()//print("save to local.")
                        }
                        catch{
                            print("loading error")
                            completion(false)
                        }
                    }
            }
            do{
                completion(true)
            }
            catch{
                print("error fetching after save data")
                completion(false)
            }
            }
            print("finish")
        } catch {
            print(error)
            completion(false)
        }
    }
    
    func update(title:String, isDone: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        let predicate = NSPredicate(format: "title = %@", title)
        fetchRequest.predicate = predicate
        
        do {
            let foundTasks = try managedContext.fetch(fetchRequest) as! [TaskEntity]
            foundTasks.first?.isDone = isDone
            try managedContext.save()
            print("Updated.")
        } catch {
            print("Update error.")
        }
    }
    
    // User section -- Start
    func fetchUser() -> [UserEntity] {
        var fetchingImage = [UserEntity]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return fetchingImage }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        
        do {
            print("All User Data.")
            fetchingImage = try managedContext.fetch(fetchRequest) as! [UserEntity]
        } catch {
            print(error)
        }
        return fetchingImage
    }
    
    func createNewUser(name: String="", email: String, darkMode: Bool = false, notifications: Bool = true, sound: Bool = true ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let instance = UserEntity(context: managedContext)
        instance.name = name
        instance.email = email
        instance.darkMode = darkMode
        instance.notifications = notifications
        instance.sound = sound
        
        do {
            print("Created New User.")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not create user!. \(error), \(error.userInfo)")
        }
        
    }
    
    func updateName(name:String, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            foundUser.first?.name = name
            try managedContext.save()
            print("Updated.")
        } catch {
            print("Update error.")
        }
    }
    func deleteUser(email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        fetchRequest.predicate = NSPredicate(format: "email = %@", email)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            
            do {
                print("Deleted user.")
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func checkIfUserExists() -> Bool{
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return false}
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        
        do {
            let users = try managedContext.fetch(fetchRequest)
            print("length = \(users.count)")
            if (users.count != 1) {
                print("Too many users, contact Andrew to solve this!")
                return false
            } else {
                return true
            }
            
        } catch {
            print(error)
            return false
        }
        
        return false
    }
    
    func logout(email: String) {
        // Delete user instance
        deleteUser(email: email)
        
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchTaskRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        let fetchListRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        
        // Remove all tasks
        do {
            let tasks = try managedContext.fetch(fetchTaskRequest)
            
            for task in tasks {
                print(task)
                managedContext.delete(task as! NSManagedObject)
            }
            
            do {
                print("Cleared local tasks too.")
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
        

        // Remove all taskLists
        do {
            let lists = try managedContext.fetch(fetchListRequest)
            
            for list in lists {
                managedContext.delete(list as! NSManagedObject)
            }
            
            do {
                print("Cleared local lists too.")
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    func updateSound(soundOn:Bool, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            foundUser.first?.sound = soundOn
            try managedContext.save()
            print("Updated Sound.")
        } catch {
            print("Update error.")
        }
    }
    
    func updateNotifications(notificationsOn:Bool, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            foundUser.first?.notifications = notificationsOn
            try managedContext.save()
            print("Updated notifications.")
        } catch {
            print("Update error.")
        }
    }
    
    func updateDark(darkMode:Bool, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            foundUser.first?.darkMode = darkMode
            try managedContext.save()
            print("Updated darkMode.")
        } catch {
            print("Update error.")
        }
    }
    
    func saveList(title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let instance = ListEntity(context: managedContext)
        instance.title = title
        
        // Get user's email
        do {
            let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
            let user = try managedContext.fetch(fetchUser)
            if user.count > 1{
                print("multiple user was found ")
                return
            }
            if (user.isEmpty || user.count == 0){
                print("not local user was found when fetching data")
                return
            }
            let email = (user[0] as! UserEntity).email
        
            db.collection("taskLists").addDocument(data: ["title" : title, "email": email! as! String]) { (error) in
                if error != nil {
                    // Show error message
                    print("Error saving user data\(error)")
                    return
                }
                print("Saved list \(title) to DB")
            }
            print("Saving List \(title) local.")
            try managedContext.save()
        } catch {
            print("Could not save")
        }
        
    }
    
    func fetchListsDB(completion: @escaping (_ message: Bool) -> Void) {
        var fetchingImage = [ListEntity]()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        var titlelist = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        do {
            fetchingImage = try managedContext.fetch(fetchRequest) as! [ListEntity]
            for result in fetchingImage as [ListEntity] {
                titlelist.append(result.title!)
            }
            let user = try managedContext.fetch(fetchUser)
            if user.count > 1{
                print("multiple user was found ")
                completion(false)
                return
            }
            if (user.isEmpty || user.count == 0){
                print("not local user was found when fetching data")
                return
            }
            let email = (user[0] as! UserEntity).email
            print("Ckecking for duplicate Data.")
            self.db.collection("taskLists").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if (querySnapshot?.count == 0){
                        print("No lists found")
                        completion(true)
                    }
                    for document in querySnapshot!.documents {
                        let title = document.get("title")!
                        if titlelist.contains(title as! String){
                            continue
                        }
                        let instance = ListEntity(context: managedContext)
                        instance.title = title as? String
                        do{
                            try managedContext.save()//print("save to local.")
                        }
                        catch{
                            print("loading error")
                            completion(false)
                        }
                    }
                }
                do {
                    completion(true)
                }
                catch {
                    print("error fetching after save data")
                    completion(false)
                }
            }
        } catch {
            print(error)
            completion(false)
        }
    }
    
    func fetchLists() -> [ListEntity] {
        var fetchingImage = [ListEntity]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return fetchingImage }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        
        do {
            print("Fetching Lists.")
            fetchingImage = try managedContext.fetch(fetchRequest) as! [ListEntity]
        } catch {
            print(error)
        }
        return fetchingImage
    }
    
    func deleteList(title: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        fetchRequest.predicate = NSPredicate(format: "title = %@", title)
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            print("------ \(test), \(title)")
            db.collection("taskLists").document("\(title)").delete() { err in
                if err != nil {
                    print("Error removing document named \(title): \(err)")
                } else {
                    print("Document \(title) successfully deleted!")
                }
            }
            do {
                print("Deleted.")
                try managedContext.save()
            } catch {
                print(error)
            }
        } catch {
            print(error)
        }
    }
    
    
    
}
