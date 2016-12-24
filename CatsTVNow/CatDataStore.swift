//
//  CatsDataStore.swift
//  CatsTVNow
//
//  Created by Johann Kerr on 12/23/16.
//  Copyright © 2016 Johann Kerr. All rights reserved.
//

import Foundation
import CoreData


class CatDataStore {
    static let sharedInstance = CatDataStore()
    private init() {}
    
    var catVideos = [CatVideo]()
    var savedCatVideos = [Cat]()
    var nextKey = ""
    
    
    func getVideos(completion:@escaping ()->()) {
        CatsApiClient.getCats(type: .video, next:nextKey) { (catArray, next) in
            self.nextKey = next
            for cat in catArray {
                let cat = CatVideo(cat)
                //self.save(cat)
                self.catVideos.append(cat)
                
            }
            
            self.saveContext()
            completion()
        }
    }
    
    func getImageData(forCat cat: CatVideo, completion:@escaping (Data)->()) {
        CatsApiClient.getCatThumbail(cat: cat) { (data) in
            completion(data)
        }
    }
    
    func getMoreVideos(completion:@escaping ([CatVideo])->()){
        var videos = [CatVideo]()
       
        CatsApiClient.getCats(type: .video, next:nextKey) { (catArray, next) in
            self.nextKey = next
            for cat in catArray {
                let cat = CatVideo(cat)
                videos.append(cat)
            }
            self.catVideos += videos
            completion(videos)
        }
    }
   
    func fetchVideos() {
        let context = self.persistentContainer.viewContext
        let fetchRequest: NSFetchRequest = Cat.fetchRequest()
        do {
            self.savedCatVideos = try context.fetch(fetchRequest)
        } catch {
            
        }
        
    }
    
    
    func save(_ cat:CatVideo) {
        
        let context = persistentContainer.viewContext
        context.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        let savedCat = Cat(context: context)
        savedCat.title = cat.title
        savedCat.thumbnail = cat.thumbnail
        savedCat.url = cat.url

    }
    

    
    
    
    lazy var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "CatsTV")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                
                /*
                 Typical reasons for an error here include:
                 * The parent directory does not exist, cannot be created, or disallows writing.
                 * The persistent store is not accessible, due to permissions or data protection when the device is locked.
                 * The device is out of space.
                 * The store could not be migrated to the current model version.
                 Check the error message to determine what the actual problem was.
                 */
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
    
    // MARK: - Core Data Saving support
    
    func saveContext () {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // fatalError() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                fatalError("Unresolved error \(nserror), \(nserror.userInfo)")
            }
        }
    }
    
    

}
