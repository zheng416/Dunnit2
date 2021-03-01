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
    var db = Firestore.firestore()
    static let shareInstance = DataBaseHelper()
    
    func save(title: String, body: String, date: Date, isDone: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        //print(result.title!,result.body!,result.date!,result.isDone)
        let docData: [String: Any] = [
            "user" : "test",
            "body" : body,
            "title": title,
            "date":date,
            "isDone" : isDone
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
    
    func fetch() -> [TaskEntity] {
        var fetchingImage = [TaskEntity]()
        var newImage = [TaskEntity]()
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return fetchingImage }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "TaskEntity")
        var titlelist = [String]()
        do {
            fetchingImage = try managedContext.fetch(fetchRequest) as! [TaskEntity]
            for result in fetchingImage as [TaskEntity] {
                print(result.title!,result.body!,result.date!,result.isDone)
                titlelist.append(result.title!)
                /*let docData: [String: Any] = [
                    "body" : result.body!,
                    "title":result.title!,
                    "date":result.date!,
                    "isDone" : result.isDone
                ]
                db.collection("task").document("test"+result.title!).setData(docData) { err in
                    if let err = err {
                        print("Error writing document: \(err)")
                    } else {
                        print("Document successfully written!")
                    }
                }*/
            }
            print("Ckecking for duplicate Data.")
            db.collection("task").getDocuments() { (querySnapshot, err) in
                if let err = err {
                    print("Error getting documents: \(err)")
                } else {
                    for document in querySnapshot!.documents {
                        let title = document.get("title")!
                        if titlelist.contains(title as! String){
                            continue
                        }
                        let body = document.get("body")!
                        let date = document.get("date")!
                        let isDone = document.get("isDone")!
                        let instance = TaskEntity(context: managedContext)
                        let timestamp: Timestamp = date as! Timestamp
                        let RequestedDate = timestamp.dateValue()
                        instance.title = title as? String
                        instance.body = body as? String
                        instance.date = RequestedDate as? Date
                        instance.isDone = getBoolFromAny(paramAny: isDone)
                        print(title)
                        //print(document.data())
                        let formatter = DateFormatter()
                        //print(formatter.string(from: instance.date as! Date))
                        
                        do{
                            try managedContext.save()
                            print("save to local.")
                            newImage = try managedContext.fetch(fetchRequest) as! [TaskEntity]
                        }
                        catch{
                            print("loading error")
                        }
                    }
                    
                }
            }
            
        } catch {
            print(error)
        }
        do{
            newImage = try managedContext.fetch(fetchRequest) as! [TaskEntity]
        }
        catch{
            print("error reloading data")
        }
        print("Getting new image")
        for result in newImage as [TaskEntity] {
            print(result.title!,result.body!,result.date!,result.isDone)
        }
        return newImage
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
}
