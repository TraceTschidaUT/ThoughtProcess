//
//  DbContext.swift
//  ThoughtProcess
//
//  Created by Trace Tschida on 3/20/18.
//  Copyright © 2018 cs329e. All rights reserved.
//

import Foundation
import CoreData
import UIKit

final class DbContext {
    
    static let sharedInstance = DbContext()
    fileprivate var managedContext: NSManagedObjectContext?
    
    private init() {
        
        // Get access to the app delegate
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        // Get access to the persistent Container
        self.managedContext = appDelegate.persistentContainer.viewContext
    }
    
    func fetchAllFilePaths() -> [String] {
        
        var filePaths: [String] = []
        
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        
        do {
            guard let sections: [NSManagedObject] = try managedContext?.fetch(fetchReqeust) else { return filePaths }
            
            // Loop through each section and extract the filePath Location
            for section in sections {
                
                // Convert each managed object into a MindMapSection entity
                let mindMapSection = section as? MindMapSection
                
                // Get the file path arrary and set it to the filePath
                guard let storedFilePath: String = mindMapSection?.filePath else { return filePaths }
                
                // Add the contents to the array and return
                filePaths.append(storedFilePath)
                
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        // Return the filepaths
        return filePaths
    }
    
    func createMindMapSection(title:String, newFilePath: String) {
        
        // Create an entity
        guard let managedContext = self.managedContext else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: "MindMapSection", in: managedContext) else { return }
        
        // Insert the new section into the Db
        let mindMapSection = NSManagedObject(entity: entity, insertInto: managedContext)
        mindMapSection.setValue(newFilePath, forKey: "filePath")
        mindMapSection.setValue(Date(), forKey: "dateCreated")
        mindMapSection.setValue(title, forKey: "title")
        
        // Commit the Changes
        do {
            try self.managedContext?.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func deleteMindMapSection(filePath toDelete: String) {
        
        // Get the managed context
        guard let managedContext = self.managedContext else { return }
        
        // Create a fetch request to the delete the record
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        fetchRequest.predicate = NSPredicate(format: "filePath == %@", toDelete)
        
        // Get the MindMapSections
        do {
            // Get all of the sections
            guard let sections: [MindMapSection] = try managedContext.fetch(fetchRequest) as? [MindMapSection] else { return }
            
            // Loop through and find the section with the correct string
            for section in sections {
                
                // Delete the section
                if section.filePath == toDelete {
                    managedContext.delete(section)
                    try managedContext.save()
                    break
                }
            }
            
        } catch let error as NSError {
            
            print("Could not delete \(error), \(error.userInfo)")
        }
    }
    
    func fetchAllMindMaps() -> [MindMapSection] {
        
        // Create an Array to hold MindMaps
        var mindMaps: [MindMapSection] = []
        
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        
        do {
            
            // Get all of the mind maps
            guard let sections: [MindMapSection] = try managedContext?.fetch(fetchReqeust) as? [MindMapSection] else { return mindMaps }
            
            // Append the mind maps
            mindMaps.append(contentsOf: sections)
                
            } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
                return mindMaps
        }
        
        // Return the mind maps
        return mindMaps
    }
    
    func createUser(date:Date, firstName:String, lastName:String, username:String, password:String, email:String){
        
        // Create an entity
        guard let managedContext = self.managedContext else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext) else { return }
        
        // Insert the new section into the Db
        let newUser = NSManagedObject(entity: entity, insertInto: managedContext)
            newUser.setValue(firstName, forKey: "firstName")
            newUser.setValue(lastName, forKey: "lastName")
            newUser.setValue(password, forKey: "password")
            newUser.setValue(email, forKey: "email")
            newUser.setValue(date, forKey: "dateOfBirth")
        
        // Commit the Changes
        do {
            try self.managedContext?.save()
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetchUser() -> User? {
        
        var usersArray: [User] = []
        
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "User")
        
        do {
            
            // Get all of the users
            guard let users = try managedContext?.fetch(fetchReqeust) as? [User] else { return nil }
            usersArray = users
            
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
        }
        
        // Return the mind maps
        guard let user = usersArray.first else { return nil}
        return user
    }
}
