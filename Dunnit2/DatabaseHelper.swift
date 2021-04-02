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
import FirebaseDatabase
import FirebaseCore
import FirebaseFirestore
//**************************************
//
// function name and use
//
//**************************************


/**
 FBfetchuname fetch the username given email
 comForSaveUser helper for saveuser with compeletion
 saveuser save all email, uid, email in the database
 saveTask save the task both local and database
 delete a task with title both local and database
 fetchLocalTask fetch tasks from coredata
 fetchDBTask fetch Task from database
 updateDBUser
 updateLocalUser
 
 */

extension Date {
    var startOfDay: Date {
        return Calendar.current.startOfDay(for: self)
    }

    var startOfMonth: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year, .month], from: self)

        return  calendar.date(from: components)!
    }
    
    var startOfYear: Date {

        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.year], from: self)

        return  calendar.date(from: components)!
    }

    var endOfDay: Date {
        var components = DateComponents()
        components.day = 1
        components.second = -1
        return Calendar.current.date(byAdding: components, to: startOfDay)!
    }

    var endOfMonth: Date {
        var components = DateComponents()
        components.month = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }
    
    var endOfYear: Date {
        var components = DateComponents()
        components.year = 1
        components.second = -1
        return Calendar(identifier: .gregorian).date(byAdding: components, to: startOfMonth)!
    }

    func isMonday() -> Bool {
        let calendar = Calendar(identifier: .gregorian)
        let components = calendar.dateComponents([.weekday], from: self)
        return components.weekday == 2
    }
}

func getBoolFromAny(paramAny: Any)->Bool {
    let result = "\(paramAny)"
    return result == "1"
}
class DataBaseHelper {
    static let shareInstance = DataBaseHelper()
    let db = Firestore.firestore()
    func loadFromDB(array:[String]) -> [String] {
        return ["a","b"]
    }
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

    func comForSaveUser(name:String, email:String, uid:String,completion:@escaping(Bool)->Void) {
        db.collection("users").addDocument(data: ["name" : name, "uid" : uid,
                                                  "email": email,
                                                  "darkMode":false,
                                                  "notification":false,
                                                  "sound":false]) { (error) in
            
            if error != nil {
                // Show error message
                print("Error saving user data\(error)")
                completion(false)
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
                    self.comForSaveUser(name: name, email: email, uid: uid, completion: {result in
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
    func saveTask(title: String, body: String, date: Date, isDone: Bool, list: String, color: String, priority: Int16, made: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let managedContext = appDelegate.persistentContainer.viewContext
        //print(result.title!,result.body!,result.date!,result.isDone)
        var email = ""
        do{
            let users = try managedContext.fetch(fetchUser)
            if users.count > 1 {
                print("multiple user was found ")
                return
            }
            email = (users[0] as! UserEntity).email!
        }
        catch{
            print("cannnot find user")
        }
        var ref: DatabaseReference?
        ref = Database.database().reference()
        guard let key = ref?.child("task").childByAutoId().key else { return }
        let docData: [String: Any] = [
            "id" : key,
            "email" : email,
            "user" : "test",
            "body" : body,
            "title": title,
            "date":date,
            "isDone" : isDone,
            "list": list,
            "color": color,
            "priority": priority,
            "made": made
        ]
        
        db.collection("task").document(key).setData(docData) { err in
            if let err = err {
                print("Error writing document: \(err)")
            } else {
                print("Document successfully written!")
            }
        }
        let instance = TaskEntity(context: managedContext)
        instance.id = key
        instance.title = title
        instance.body = body
        instance.date = date
        instance.isDone = isDone
        instance.list = list
        instance.color = color
        instance.owner = email
        instance.priority = priority
        instance.made = made
        print(instance.date!)
        do {
            print("Saved.")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func deleteTask(id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        
        do {
            
            let test = try managedContext.fetch(fetchRequest)
            let objectToDelete = test[0] as! NSManagedObject
            
            // Get user email
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
            
            // Database access
            db.collection("task").document(id).delete() { err in
                if let err = err {
                    print("Error removing document named \(id): \(err)")
                } else {
                    print("Document \(id) successfully deleted!")
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
    
    func fetchLocalTask(key:String? = nil, ascending:Bool? = nil, filterKey: String? = nil) -> [TaskEntity] {
        var fetchingImage = [TaskEntity]()
            
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return fetchingImage }
            
        let managedContext = appDelegate.persistentContainer.viewContext
            
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        if (key != nil){
            print("Sort by \(key)")
            let sort = NSSortDescriptor(key: key, ascending: ascending ?? true)
            fetchRequest.sortDescriptors = [sort]
        }

        if (filterKey != nil) {
            // Get the current calendar with local time zone
            var calendar = Calendar.current
            calendar.timeZone = NSTimeZone.local

            if (filterKey == "today") {
                // Get today's beginning & end
                let dateFrom = calendar.startOfDay(for: Date()) // eg. 2016-10-10 00:00:00
                let dateTo = calendar.date(byAdding: .day, value: 1, to: dateFrom)
                
                // Set predicate as date being today's date
                let fromPredicate = NSPredicate(format: "date >= %@", dateFrom as NSDate)
                let toPredicate = NSPredicate(format: "date < %@", dateTo! as NSDate)
                
                let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
                fetchRequest.predicate = datePredicate
                
            } else if (filterKey == "month") {
                // Get today's beginning & end
                let startOfMonth = Date().startOfMonth
                let endOfMonth = Date().endOfMonth
                
                // Set predicate as date being today's date
                let fromPredicate = NSPredicate(format: "date >= %@", startOfMonth as NSDate)
                let toPredicate = NSPredicate(format: "date < %@", endOfMonth as NSDate)
                
                let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
                fetchRequest.predicate = datePredicate
            } else if (filterKey == "year") {
                // Get today's beginning & end
   
                let startYear = Date().startOfYear
                let endYear = Date().endOfYear
                
                // Set predicate as date being today's date
                let fromPredicate = NSPredicate(format: "date >= %@", startYear as NSDate)
                let toPredicate = NSPredicate(format: "date < %@", endYear as NSDate)
                
                let datePredicate = NSCompoundPredicate(andPredicateWithSubpredicates: [fromPredicate, toPredicate])
                fetchRequest.predicate = datePredicate
            } else {
                fetchRequest.predicate = nil
            }
        }
        
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
                        instance.id = document.get("id")! as? String
                        instance.title = title as? String
                        instance.body = document.get("body")! as? String
                        instance.date = (document.get("date")! as! Timestamp).dateValue() as? Date
                        instance.isDone = getBoolFromAny(paramAny: document.get("isDone")!)
                        instance.color = document.get("color")! as? String
                        instance.list = document.get("list")! as? String
                        instance.owner = document.get("email")! as? String
                        instance.priority = (document.get("priority")! as? Int16)!
                        instance.made = document.get("made") as? String
                        print("id \(instance.id), title\(instance.title), list \(instance.list)")
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
    
    //change the isDone for a task
    func updateDBTask(id:String, body: String? = nil, color: String? = nil, date:Date? = nil, isDone: Bool? = nil, list:String? = nil, owner:String? = nil, title:String? = nil, priority:Int16? = 0, made: String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        let predicate = NSPredicate(format: "title = %@", id)
        fetchRequest.predicate = predicate
        var email = String()
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
            email = (user[0] as! UserEntity).email!
        } catch {
            print("Error retrieving user")
        }
        
        var docData: [String: Any] = [String:Any]()
        
        if body != nil {docData["body"] = body}
        if color != nil {docData["color"] = color}
        if date != nil {docData["date"] = date}
        if isDone != nil {docData["isDone"] = isDone}
        if list != nil {docData["list"] = list}
        if owner != nil {docData["owner"] = owner}
        if title != nil {docData["title"] = title}
        print("Updated DB task. \(color)")
        
        if priority != 0 {docData["priority"] = priority}
        if made != nil {docData["made"] = made}
        print(docData)
        print("Status Change")
        db.collection("task").document(id).updateData(docData) {
            err in
            if err != nil {
                print("Error updating status")
                return
            }
            print ("Status Updated")
        }
        
        do {
            let foundTasks = try managedContext.fetch(fetchRequest) as! [TaskEntity]
            foundTasks.first?.isDone = isDone!
            try managedContext.save()
            print("Updated.")
        } catch {
            print("Update error.")
        }
    }
    // update local task
    func updateLocalTask(id:String, body: String? = nil, color: String? = nil, date:Date? = nil, isDone: Bool? = nil, list:String? = nil, owner:String? = nil, title:String? = nil, priority:Int16? = 0, made:String? = nil) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        let predicate = NSPredicate(format: "id = %@", id)
        fetchRequest.predicate = predicate
        
        do {
            let foundTasks = try managedContext.fetch(fetchRequest) as! [TaskEntity]
            if title != nil {foundTasks.first?.title = title}
            if body != nil {foundTasks.first?.body = body}
            if date != nil {foundTasks.first?.date = date}
            if color != nil {foundTasks.first?.color = color}
            if isDone != nil {foundTasks.first?.isDone = isDone!}
            if list != nil {foundTasks.first?.list = list}
            if owner != nil {foundTasks.first?.owner = owner}
            if priority != 0 {foundTasks.first?.priority = priority!}
            if made != nil {foundTasks.first?.made = made}
//            foundTasks.first?.color = color
            try managedContext.save()
            print("Updated local task. \(color)")

            updateDBTask(id: id, body: body, color: color, date: date, isDone: isDone, list: list, owner: owner, title: title, priority: priority, made: made)
        } catch {
            print("Update error.")
        }
    }
    
    // User section -- Start
    func fetchLocalUser() -> [UserEntity] {
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
    
    func fetchDBUser(email:String, completion:@escaping (_ message:String)->Void){
        db.collection("users").whereField("email", isEqualTo: email).getDocuments { (docs, err) in
            if let err = err{
                print("cannot fetch user name from firebase: \(err)")
                return
            }
            else {
                if docs == nil {
                    completion("FetchDBUser Error")
                    print("No user found in DB with email: \(email)")
                }
                if (docs!.count > 1){
                    print(String(docs!.count))
                    completion("Error found more than user")
                }
                let user = docs?.documents[0]
                
                self.updateLocalUser(email: email,darkMode: (user?.get("darkmode") as? Bool) ,name: user?.get("name") as? String,notification: user?.get("notification") as? Bool,sound: user?.get("sound") as? Bool)
                print("email for the database", email)
                completion("Success fetchDBUser")
            }
        }
        return
    }
    
    func createNewUser(name: String="", email: String, darkMode: Bool = false, notification: Bool = true, sound: Bool = true ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let instance = UserEntity(context: managedContext)
        instance.name = name
        instance.email = email
        instance.darkMode = darkMode
        instance.notification = notification
        instance.sound = sound
        instance.sortKey = "title"
        instance.sortAscending = true
        
        do {
            print("Created New User.")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not create user!. \(error), \(error.userInfo)")
        }
        
    }
    //should not be used
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
    
    func updateNameDB(name: String, email: String) {
        self.db.collection("users").whereField("email", isEqualTo: email).getDocuments() {
            (querySnapshot, err) in
            for document in querySnapshot!.documents {
                let documentId = document.documentID
                self.db.collection("users").document(documentId).setData(["name": name], merge: true)
            }
        }
    }
    
    func updateSortPreference(key: String, ascending: Bool, email: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            foundUser.first?.sortKey = key
            foundUser.first?.sortAscending = ascending
            try managedContext.save()
            print("Updated.")
        } catch {
            print("Update error.")
        }
    }
    
    func updateSortPreferenceDB(key: String, ascending: Bool, email: String) {
        self.db.collection("users").whereField("email", isEqualTo: email).getDocuments() {
            (querySnapshot, err) in
            for document in querySnapshot!.documents {
                let documentId = document.documentID
                self.db.collection("users").document(documentId).setData(["sortKey": key, "sortAscending": ascending], merge: true)
            }
        }
    }
    
    func updateFilterPreference(email: String, filterKey: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            foundUser.first?.filterKey = filterKey
            try managedContext.save()
            print("Updated filter.")
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
    //TODO : add all
    func updateLocalUser(email: String,darkMode:Bool? = nil,name:String? = nil, notification: Bool? = nil,sound:Bool? = nil ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate = NSPredicate(format: "email = %@", email)
        fetchRequest.predicate = predicate
        
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [UserEntity]
            if darkMode != nil  {foundUser.first?.darkMode = darkMode!}
            if name != nil  {foundUser.first?.name = name!}
            if notification != nil  {foundUser.first?.notification = notification!}
            if sound != nil  {foundUser.first?.sound = sound!}
            try managedContext.save()
            print("Updated Sound.")
        } catch {
            print("Update error.")
        }
    }
    func updateDBUser(email: String,darkMode:Bool? = nil,name:String? = nil, notification: Bool? = nil,sound:Bool? = nil ) {
        var docData: [String: Any] = [:]
        if darkMode != nil  {docData["darkMode"] = darkMode!}
        if name != nil  {docData["name"] = name!}
        if notification != nil  {docData["notification"] = notification!}
        if sound != nil  {docData["sound"] = sound!}
        print(sound)
        print(docData["sound"])
        self.db.collection("users").whereField("email", isEqualTo: email).getDocuments() {
            (docs, err) in
            if err != nil {
                print("Error updating status")
                return
            }
            if docs != nil && docs!.count == 1{
                docs?.documents[0].reference.updateData(docData)
                print ("DB User Updated")
            }
            else{
                print("Error Updating User on DB")
                print(docs?.count)
            }
        }
    }
    
    //Save local list
    func saveLocalList(title: String, shared: Bool, sharedWith: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let instance = ListEntity(context: managedContext)
        instance.title = title
        instance.shared = shared
        instance.sharedWith = sharedWith
        
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
            instance.owner = email
            let docData: [String: Any] = ["title" : title, "email": email!, "shared": shared, "sharedWith": sharedWith, "sharedArr": []]
            var ref: DatabaseReference?
            ref = Database.database().reference()
            guard let id = ref?.child("taskLists").childByAutoId().key else { return }
            instance.id = id
            db.collection("taskLists").document(id).setData(docData) { err in
                if err != nil {
                    // Show error message
                    print("Error saving user data\(err)")
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
                titlelist.append(result.id!)
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
                        let id = document.documentID
                        print("list ID",document.documentID)
                        let title = document.get("title")!
                        let owner = document.get("email")!
                        let shared = document.get("shared")!
                        let sharedWith = document.get("sharedWith")!
                        if titlelist.contains(id as! String){
                            continue
                        }
                        let instance = ListEntity(context: managedContext)
                        instance.id = id as? String
                        print("INSTANCE IIIIIDDDDD")
                        print(instance.id)
                        instance.title = title as? String
                        instance.owner = owner as? String
                        instance.shared = shared as! Bool
                        instance.sharedWith = sharedWith as? String
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
        let sort = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [sort]
        
        do {
            print("Fetching Lists.")
            fetchingImage = try managedContext.fetch(fetchRequest) as! [ListEntity]
        } catch {
            print(error)
        }
        return fetchingImage
    }
    
    func deleteList(id: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        let fetchTaskRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        let fetchUserRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        fetchRequest.predicate = NSPredicate(format: "id = %@", id)
        fetchTaskRequest.predicate = NSPredicate(format: "list = %@", id)
        
        do {
            let list = try managedContext.fetch(fetchRequest)
            let objectToDelete = list[0] as! NSManagedObject
            let id = (list[0] as! ListEntity).id
            managedContext.delete(objectToDelete)
            
            db.collection("taskLists").document(id!).delete() { err in
                if err != nil {
                    print("Error removing document named \(String(describing: id)): \(String(describing: err))")
                } else {
                    print("Document \(String(describing: id)) successfully deleted!")
                }
            }
            
            let taskContext = try managedContext.fetch(fetchTaskRequest)
            
            for task in taskContext {
                print("task \(task)")
                managedContext.delete(task as! NSManagedObject)
            }
            
            db.collection("task").whereField("list", isEqualTo: id! as String).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if (querySnapshot?.count == 0){
                        print("No lists found")
                    }
                    for document in querySnapshot!.documents {
                        self.db.collection("task").document(document.get("id") as! String).delete()
                    }
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
    

    // Save a shared list to Firebase only
    func saveDBSharedList(to: String, taskList: String, lid: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }

        let managedContext = appDelegate.persistentContainer.viewContext

//        let instance = SharedEntity(context: managedContext)
//        instance.email = to
        do {
            var ref: DatabaseReference?
            ref = Database.database().reference()
            guard let id = ref?.child("sharedLists").childByAutoId().key else { return }
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
            
            let docData: [String: Any] = ["owner": email!, "tasklist": taskList, "to": to, "lid": lid, "id": id]
            
            db.collection("sharedLists").document(id).setData(docData) { err in
                if err != nil {
                    // Show error message
                    print("Error saving user data\(err)")
                    return
                }
                print("Saved list \(taskList) to DB")
                //QUESTION why update here??????
                print("THE LID ISSSS")
                print(lid)
                DataBaseHelper.shareInstance.updateListsShared(id: lid, email: email!, shared: true, sharedWith: to, title: taskList)
                print("DONEEEEEE Update")
            }
        } catch {
            print("Could not save")
        }
    }
    
    func updateListsShared(id : String,email: String, shared: Bool, sharedWith: String, title: String ) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
                
                let managedContext = appDelegate.persistentContainer.viewContext
                
                let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        
        let docData: [String: Any] = ["email": email , "shared": shared, "sharedWith": sharedWith, "title": title, "sharedArr": FieldValue.arrayUnion([sharedWith])]
        //let listKey = "\(email ?? "")+\(title ?? "")"
        db.collection("taskLists").document(id).updateData(docData) { err in
                    if err != nil {
                        // Show error message
                        print("Error saving user data\(err)")
                        return
                    }
        }

    }
    
    func fetchSharedDB(completion: @escaping (_ message: Bool) -> Void) {
//        var fetchingImage = [SharedEntity]()

        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
//        var titlelist = [String]()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SharedEntity")
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let fetchList = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        // Delete Shared all

        do {
            let items = try managedContext.fetch(fetchRequest) as! [SharedEntity]
            for item in items {
                managedContext.delete(item)
            }
            
            try managedContext.save()
        } catch {
            print(error)
        }
        
        // Then Fetch, could delete some of this part
        
        do {
//            fetchingImage = try managedContext.fetch(fetchRequest) as! [SharedEntity]
//            print("countttt")
//            print(fetchingImage.count)
//            for result in fetchingImage as [SharedEntity] {
//                print(result.taskList)
//                var temp = "\(result.email!) + \(result.taskList!)"
//                print("TEMPPPEPPEPEP")
//                print(temp)
//                titlelist.append(temp)
//            }
//            print("TITLELISTTTTT")
//            print(titlelist)
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
            print(email)
            print("Ckecking for duplicate Data.")
            self.db.collection("sharedLists").whereField("to", isEqualTo: email).getDocuments() { (querySnapshot, err) in
                
                print("Count from Database")
                print(querySnapshot!.count)
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if (querySnapshot?.count == 0){
                        print("No lists found")
                        completion(true)
                    }
                    for document in querySnapshot!.documents {
                        print("ONCEEEEEEEEE")
                        let taskList = document.get("tasklist")!
                        let owner = document.get("owner")!
                        let lid = document.get("lid")!
                        let id = document.get("id")!
                        print("\(owner) + \(taskList)")
//                        if titlelist.contains("\(owner) + \(taskList)" as! String){
//                            print("SAMMMMMEE")
//                            continue
//                        }
                        let instance = SharedEntity(context: managedContext)
                        instance.email = owner as? String
                        instance.taskList = taskList  as? String
                        instance.lid = lid as? String
                        instance.id = id as? String
                        do{
                            //try managedContext.save()//print("save to local.")
                            print("SAVING TO DB SHARE")
                            print(instance.email)
                            print(instance.taskList)
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
            completion(true)
        } catch {
            print(error)
            completion(false)
        }
        print("LIFE SUCKSSSS")
    }

    func updateTopic(email: String, red: String, orange: String, yellow: String, green: String, blue: String, purple: String, indigo: String, teal: String, pink: String, black: String) {
        print("RED")
        print(red)
        print("DONE")
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TopicEntity")
        // Save to Firebase
        let docData: [String: Any] = ["email": email , "red": red, "orange": orange, "yellow": yellow, "green": green, "blue": blue, "purple": purple, "indigo": indigo, "teal": teal, "pink": pink, "black": black]
        let topicKey = "\(email ?? "")+topic"
        db.collection("topics").document(topicKey).updateData(docData) { err in
            if err != nil {
                // Show error message
                print("Error saving user data\(err)")
                return
            }
        }
        // Save to local database
        do {
            let foundUser = try managedContext.fetch(fetchRequest) as! [TopicEntity]
            print(foundUser)
            foundUser.first?.red = red
            foundUser.first?.orange = orange
            foundUser.first?.yellow = yellow
            foundUser.first?.green = green
            foundUser.first?.blue = blue
            foundUser.first?.purple = purple
            foundUser.first?.indigo = indigo
            foundUser.first?.teal = teal
            foundUser.first?.pink = pink
            foundUser.first?.black = black
            try managedContext.save()
            print("SAVED")
            print(foundUser.first)
            print("DONE")
            print("Updated Topics.")
        } catch {
            print("Update error.")
        }
    }
    
    func saveTopics(red: String, orange: String, yellow: String, green: String, blue: String, purple: String, indigo: String, teal: String, pink: String, black: String) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let instance = TopicEntity(context: managedContext)
        instance.red = red
        instance.orange = orange
        instance.yellow = yellow
        instance.green = green
        instance.blue = blue
        instance.purple = purple
        instance.indigo = indigo
        instance.teal = teal
        instance.pink = pink
        instance.black = black
        
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
            let docData: [String: Any] = ["email": email! , "red": red, "orange": orange, "yellow": yellow, "green": green, "blue": blue, "purple": purple, "indigo": indigo, "teal": teal, "pink": pink, "black": black]
            
            let topicKey = "\(email ?? "")+topic"
            db.collection("topics").document(topicKey).setData(docData) { err in
                if err != nil {
                    // Show error message
                    print("Error saving user data\(err)")
                    return
                }
            }
            try managedContext.save()
        } catch {
            print("Could not save")
        }
    }          
    
    func fetchSharedLists(completion: @escaping (_ list: [ListEntity]) -> Void) {
        var fetchingImage = [SharedEntity]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SharedEntity")
        let fetchList = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        
        var shared = [ListEntity]()
        do {
            var idList = [String]()
            var fetchLists = try managedContext.fetch(fetchList) as! [ListEntity]
            for result in fetchLists as [ListEntity] {
                print(result.title!,result.id!)
                idList.append(result.id!)
            }
            print("Fetching SharedLists.")
            fetchingImage = try managedContext.fetch(fetchRequest) as! [SharedEntity]
            print(fetchingImage.count)
            for result in fetchingImage as [SharedEntity] {
                print("Inside Loopp")
                let owner = result.email!
                print(owner)
                print(result.taskList!)
                self.db.collection("taskLists").whereField("title", isEqualTo: result.taskList!).getDocuments() { (querySnapshot, err) in
                    if let err = err {
                        print("Error getting documents: \(err)")
                    } else {
                        if (querySnapshot?.count == 0){
                            print("No lists found")
                        } else {
                            for document in querySnapshot!.documents {
                                if idList.contains(document.documentID as! String){
                                    let predicate1 = NSPredicate(format: "id == %@", document.documentID)
                                    fetchList.predicate = predicate1
                                    do {
                                    let thisList = try managedContext.fetch(fetchList) as! [ListEntity]
                                    print("THIS LIST   \(thisList)")
                                        shared.append(contentsOf: thisList)
                                    continue
                                    } catch {
                                        print(error)
                                    }
                                }
                                let instance = ListEntity(context: managedContext)
                                //TODO change this to id
                                instance.title = document.get("title")! as! String
                                instance.shared = true
                                instance.sharedWith = document.get("sharedWith")! as! String
                                instance.owner = document.get("email") as! String
                                instance.id = document.documentID
                                shared.append(instance)
                                print("Sleepy")
                                print(document.get("title")!)

                            }
                            
                        }
                        
                    }
                    completion(shared)
                }
                print("lpppp")
            }
        } catch {
            print(error)
        }
        print("THIS IS")
        print(shared)
        
    }
    
    func fetchDBSharedTask(title: String, owner: String,  completion: @escaping (_ list: [TaskEntity]) -> Void) {
        var sharedTasks = [TaskEntity]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        let managedContext = appDelegate.persistentContainer.viewContext
        do {
            let email = owner
            print("Ckecking for duplicate Data.")
            print(email)
            print(title)
            self.db.collection("task").whereField("email", isEqualTo: email).whereField("list", isEqualTo: title).getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    if (querySnapshot?.count == 0){
                        print("No task found")
                        completion([TaskEntity]())
                    }
                    for document in querySnapshot!.documents {
                        let title = document.get("title")!
                        let instance = TaskEntity(context: managedContext)
                        instance.title = title as? String
                        instance.body = document.get("body")! as? String
                        instance.date = (document.get("date")! as! Timestamp).dateValue() as? Date
                        instance.isDone = getBoolFromAny(paramAny: document.get("isDone")!)
                        instance.color = document.get("color")! as? String
                        instance.list = document.get("list")! as? String
                        instance.owner = document.get("email")! as? String
                        print(title)
                        sharedTasks.append(instance)
                    }
                    completion(sharedTasks)
                }
            }
            print("finish")
        } catch {
            print(error)
            completion(sharedTasks)
        }
    }

 
    func fetchTopics() -> [TopicEntity] {
        var fetchingImage = [TopicEntity]()
        
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return fetchingImage }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TopicEntity")
        
        do {
            print("All Topics.")
            fetchingImage = try managedContext.fetch(fetchRequest) as! [TopicEntity]
        } catch {
            print(error)
        }
        return fetchingImage
    }
    
    // Removes shared entity and on firebase
    func removeSharedEntityDB(title: String, sharedBy: String, completion: @escaping (_ message: Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "SharedEntity")
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let predicate1 = NSPredicate(format: "taskList == %@", title)
        let predicate2 = NSPredicate(format: "email == %@", sharedBy)
        let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        
        fetchRequest.predicate = predicateCompound
        
        do {
            let test = try managedContext.fetch(fetchRequest)
            // Gonna need to change this so it deletes using key???
            let sharedid = (test[0] as! SharedEntity).id
            let objectToDelete = test[0] as! NSManagedObject
            managedContext.delete(objectToDelete)
            print ("deleted SharedEntity")
            
            
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
//            let listKey = "\(email! )+\(title)"
            let listKey = sharedid!
            print("BEFORE DB")
            print(listKey)
            
            db.collection("sharedLists").document(listKey).delete() { err in
                if err != nil {
                    print("Error removing document named \(title): \(err)")
                } else {
                    print("Document \(title) successfully deleted!")
                }
            }
            print("AFTER DB")
        } catch {
            print(error)
        }
        completion(true)
    }
    
    // Removes tasks and lists entities of shared tasks
    // Need to do it for local
    // Update values on firebase
    func removedSharedLocal(title: String, owner: String, id: String, completion: @escaping (_ message: Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "ListEntity")
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        let fetchTask = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        
        let predicate1 = NSPredicate(format: "list == %@", title)
        let predicate2 = NSPredicate(format: "owner == %@", owner)
        let predicateCompound = NSCompoundPredicate.init(type: .or, subpredicates: [predicate1,predicate2])
        
        fetchTask.predicate = predicateCompound
        
        let predicate3 = NSPredicate(format: "title == %@", title)
        let predicate4 = NSPredicate(format: "owner == %@", owner)
        let predicateCompound2 = NSCompoundPredicate.init(type: .or, subpredicates: [predicate3,predicate4])
        
        do {
            let taskContext = try managedContext.fetch(fetchTask)
            
            for task in taskContext {
                print("tasking DELLEEEEEETTTEEDD \(task)")
                managedContext.delete(task as! NSManagedObject)
            }
            
            let listContext = try managedContext.fetch(fetchRequest)
            
            for list in listContext {
                print("listing DELLEEEEEETTTEEDD \(list)")
                managedContext.delete(list as! NSManagedObject)
            }
            
            let user = try managedContext.fetch(fetchUser)
            if user.count > 1{
                print("multiple user was found ")
                return
            }
            if (user.isEmpty || user.count == 0){
                print("not local user was found when fetching data")
                return
            }
            
            let docData: [String: Any] = ["shared": false, "sharedWith": "", "sharedArr": FieldValue.arrayRemove([(user[0] as! UserEntity).email])]
//            let listKey = "\(owner ?? "")+\(title ?? "")"
            let listKey = id
            db.collection("taskLists").document(listKey).updateData(docData) { err in
                        if err != nil {
                            // Show error message
                            print("Error saving list data\(err)")
                            return
                        }
                print("Remove Updateddd")
            }
        } catch {
            print(error)
        }
        completion(true)
        
    }
    
    func fetchSharedEmails(lid: String, completion: @escaping (_ list: Array<Any>) -> Void) {
        self.db.collection("taskLists").document(lid).getDocument { (document, err) in
            if let document = document, document.exists {
                print(document)
                let array = document.get("sharedArr")
                print("THIS IS THE ARRAY")
                print(array)
                completion(array as! Array<Any>)
            }
            
        }
    }
    
    func removeSharedEmail(lid: String, email: String) {
        self.db.collection("taskLists").document(lid).updateData(["sharedArr": FieldValue.arrayRemove([email])])
        
        self.db.collection("sharedLists").whereField("lid", isEqualTo: lid).whereField("to", isEqualTo: email).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if (querySnapshot?.count == 0){
                    print("No shared found")
                    return
                }
                for document in querySnapshot!.documents {
                    var id = document.get("id") as! String
                    self.db.collection("sharedLists").document(id).delete()
                }
                
            }
        }
    }
    
    func resetPassword(email: String, onSuccess: @escaping() ->Void, onError: @escaping(_ errorMessage: String)  -> Void) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if error == nil {
                onSuccess()
            } else {
                onError(error!.localizedDescription)
            }
        }
    }
    
    func validEmail(email: String, onSuccess: @escaping(Bool) -> Void) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchUser = NSFetchRequest<NSFetchRequestResult>(entityName: "UserEntity")
        
        do {
        let user = try managedContext.fetch(fetchUser)
        if user.count > 1{
            print("multiple user was found ")
            return
        }
        if (user.isEmpty || user.count == 0){
            print("not local user was found when fetching data")
            return
        }
        
        let current = (user[0] as! UserEntity).email
        
        if (current == email) {
            onSuccess(false)
            return
        }
        } catch {
            print(error)
        }
        
        db.collection("users").whereField("email", isEqualTo: email).getDocuments() { (querySnapshot, err) in
            if let err = err {
                print("Error getting documents: \(err)")
            } else {
                if (querySnapshot?.count == 0){
                    print("No shared found")
                    onSuccess(false)
                } else {
                    onSuccess(true)
                }
            }
            
        }
        
    }
}
