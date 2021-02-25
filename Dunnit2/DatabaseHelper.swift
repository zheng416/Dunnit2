//
//  DatabaseHelper.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 2/24/21.
//

import Foundation
import CoreData
import UIKit

class DataBaseHelper {
    
    static let shareInstance = DataBaseHelper()
    
    func save(title: String, body: String, date: Date, isDone: Bool) {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let managedContext = appDelegate.persistentContainer.viewContext
        
        let instance = TaskEntity(context: managedContext)
        instance.title = title
        instance.body = body
        instance.date = date
        instance.isDone = isDone
        
        do {
            print("Saved.")
            try managedContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
        
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
