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
    
    func createMindMapSection(title: String, view: Data, mindMapID: UUID) {
        
        // Create an entity
        guard let managedContext = self.managedContext else { return }
        guard let entity = NSEntityDescription.entity(forEntityName: "MindMapSection", in: managedContext) else { return }
        
        let mindMapSection = MindMapSection(entity: entity, insertInto: managedContext)
        mindMapSection.setValue(view, forKey: "view")
        mindMapSection.setValue(Date(), forKey: "dateCreated")
        mindMapSection.setValue(title, forKey: "title")
        mindMapSection.setValue(mindMapID, forKey: "id")
        
        // Get the User
        let defaults = UserDefaults.standard
        guard let stringID = defaults.string(forKey: "id") else { return }
        guard let id = UUID(uuidString: stringID) else { return }
        guard let user = self.fetchUser(id: id) else { return }
        mindMapSection.user = user
        
        
        // Commit the Changes
        do {
            try self.managedContext?.save()
        }
        catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func deleteMindMapSection(id: UUID) {
        // Get the managed context
        guard let managedContext = self.managedContext else { return }
        
        // Create a fetch request to the delete the record
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        
        // Get the MindMapSections
        do {
            // Get all of the sections
            guard let sections: [MindMapSection] = try managedContext.fetch(fetchRequest) as? [MindMapSection] else { return }
            
            // Loop through and find the section with the correct string
            for section in sections {
                
                // Delete the section
                if section.id == id {
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
        
        // Get the logged-in user's id
        let defaults = UserDefaults.standard
        guard let stringID = defaults.string(forKey: "id") else { return [] }
        let id = UUID(uuidString: stringID)
        
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        
        do {
            
            // Get all of the mind maps
            guard let sections: [MindMapSection] = try managedContext?.fetch(fetchReqeust) as? [MindMapSection] else { return mindMaps }
            
            for map in sections {
                if map.user?.id == id {
                    mindMaps.append(map)
                }
            }
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
                return mindMaps
        }
        
        // Return the mind maps
        return mindMaps
    }
    
    func createUser(date:Date, firstName:String, lastName:String, username:String, password:String, email:String){
        
        // Get the managed context
        guard let managedContext = self.managedContext else { return }
        
        // Create an entity
        guard let entity = NSEntityDescription.entity(forEntityName: "User", in: managedContext) else { return }
        
        // Insert the new section into the Db
        let id = UUID()
        let newUser = NSManagedObject(entity: entity, insertInto: managedContext)
            newUser.setValue(firstName, forKey: "firstName")
            newUser.setValue(lastName, forKey: "lastName")
            newUser.setValue(password, forKey: "password")
            newUser.setValue(email, forKey: "email")
            newUser.setValue(date, forKey: "dateOfBirth")
            newUser.setValue(username, forKey: "username")
            newUser.setValue(id, forKey: "id")
        
        // Set the defaults
        UserDefaults.standard.set(id.uuidString, forKey: "id")
        UserDefaults.standard.set(true, forKey: "loggedIn")
        
        // Commit the Changes
        do {
            try self.managedContext?.save()
            print("\(Date()): User created")
        } catch {
            let nserror = error as NSError
            print("Unresolved error \(nserror), \(nserror.userInfo)")
        }
    }
    
    func fetchUser(userName: String, password: String) -> User? {
        
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
        
        // Find the correct user
        var authUser: User?
        for user in usersArray {
            
            if (user.password == password && user.username == userName) {
                authUser = user
                
                // Set the user defaults
                let defaults = UserDefaults.standard
                defaults.set(true, forKey: "loggedIn")
                defaults.set(user.id?.uuidString, forKey: "id")
                print(defaults.string(forKey: "id"))
                
                break
            }
        }
        return authUser
    }
    
    func fetchUser(id: UUID) -> User? {
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
        
        // Find the correct user
        var authUser: User?
        for user in usersArray {
            
            if (user.id == id) {
                authUser = user
                break
            }
        }
        return authUser
    }
    
    func updateMindMapSection(id: UUID, data: Data) {
        
        var mindMaps: [MindMapSection] = []
        
        // Get the managed context
        guard let managedContext = self.managedContext else { return }
     
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        
        do {
            guard let mindMapsSections = try managedContext.fetch(fetchReqeust) as? [MindMapSection] else { return }
            mindMaps.append(contentsOf: mindMapsSections)
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for map in mindMaps {
            
            if (map.id == id) {
                
                map.setValue(data, forKey: "view")
                break
            }
        }
        
        // Update the mangaged context
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save in updateMindMapSection", "\(error)")
        }
    }
    
    func fetchMindMap(id: UUID) -> MindMapSection? {
        
        // Get the mind map that matches the UUID
        var mindMaps: [MindMapSection] = []
        var selectedMindMap: MindMapSection?
        
        // Get the managed context
        guard let managedContext = self.managedContext else { return nil }
        
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
       
        do {
            guard let mindMapsSections = try managedContext.fetch(fetchReqeust) as? [MindMapSection] else { return nil}
            mindMaps.append(contentsOf: mindMapsSections)
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for map in mindMaps {
            
            if (map.id == id) {
                selectedMindMap = map
                break
            }
        }
        
        return selectedMindMap
    }
    
    func addImageToMindMap(image: UIImage, id: UUID) {
        
        var mindMaps: [MindMapSection] = []
        
        // Get the managed context
        guard let managedContext = self.managedContext else { return }
        
        // Fetch the Core Data for the MindMapSection info
        let fetchReqeust = NSFetchRequest<NSManagedObject>(entityName: "MindMapSection")
        
        do {
            guard let mindMapsSections = try managedContext.fetch(fetchReqeust) as? [MindMapSection] else { return }
            mindMaps.append(contentsOf: mindMapsSections)
            
        }
        catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
        }
        
        for map in mindMaps {
            
            if (map.id == id) {
                
                map.setValue(image, forKey: "image")
                break
            }
        }
        
        // Update the mangaged context
        do {
            try managedContext.save()
        }
        catch let error as NSError {
            print("Could not save in updateMindMapSection", "\(error)")
        }
        
    }
}
