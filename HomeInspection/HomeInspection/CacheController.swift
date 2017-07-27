//
//  CacheController.swift
//  HomeInspection
//
//  Created by Jared Speck on 7/17/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class CacheController {
    
    static let cache = CacheController()
    var managedObjectContext: NSManagedObjectContext!
    
    private init() {
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    
    
    // MARK: Public functions
    
    // Checks if inspection data cache needs update (true = valid cache, no update required)
    func validate(commentModTime remoteComModTime: String, subSectionModTime remoteSubSecModTime: String, sectionModTime remoteSecModTime: String) -> Bool {
        // Get last change timestamp from device
        let appValuesRequest: NSFetchRequest<AppValues> = AppValues.fetchRequest()
        var localModTimes: AppValues
        
        do {
            let fetchResult = try managedObjectContext.fetch(appValuesRequest)
            if (fetchResult.first != nil) {
                localModTimes = fetchResult.first! as AppValues
            }
        } catch {
            print("Could not fetch last data update timestamp from device: \(error.localizedDescription)")
        }
        
        // TODO: Compare times here
        
        return false
    }
    
    // Refreshes cache with remote inspection data
    func refresh() {
        if let inspectionDataJSON: JSON = NetworkController.getInspectionData() {
            loadInspectionData(from: inspectionDataJSON)
        }
    }
    
    
    
    // MARK: Private functions
    
    // Parses default data from database and uses data to refresh the local cache (delete old and insert new values)
    private func loadInspectionData(from dataJson: JSON) {
        // Fetch reference to inspection data in cache
        var loadedInspectionData: InspectionData?
        let fetchRequest: NSFetchRequest<InspectionData> = InspectionData.fetchRequest()
        do {
            let fetchRequestResults = try managedObjectContext.fetch(fetchRequest)
            if let tempInspectionData: InspectionData = fetchRequestResults.first {
                loadedInspectionData = tempInspectionData
            }
            else {
                print("Inspection data not loaded correctly in parseInspection")
                loadedInspectionData = nil
            }
        } catch {
            print("Error loading inspection data from disk on cache referesh: \(error.localizedDescription)")
        }
        
        // Flush out old data from cache
        self.deleteAllInstances(entityName: "Section")
        self.deleteAllInstances(entityName: "SubSection")
        self.deleteAllInstances(entityName: "Comment")
        
        // Load in new data to the cache
        for (_, sectionJson) in dataJson["sections"] {
            let newSection = Section(context: managedObjectContext)
            
            // Set section attributes
            newSection.id = Int32(sectionJson["id"].intValue)
            newSection.name = sectionJson["name"].string
            
            // Set section relationships
            newSection.inspectionData = loadedInspectionData
            
            for (_, subSectionJson) in sectionJson["subsections"] {
                let newSubSection = SubSection(context: managedObjectContext)
                
                // Set subsection attributes
                newSubSection.id = Int32(subSectionJson["id"].intValue)
                newSubSection.name = subSectionJson["name"].string
                
                // Set subsection relationships
                newSubSection.inspectionData = loadedInspectionData
                newSubSection.section = newSection
                
                for (_, commentJson) in subSectionJson["comments"] {
                    //let commentId = commentJson["id"].intValue
                    let newComment = Comment(context: managedObjectContext)
                    
                    // Set comment attributes
                    newComment.id = Int32(commentJson["id"].intValue)
                    newComment.rank = Int16(commentJson["rank"].intValue)
                    newComment.text = commentJson["comment"].string
                    newComment.active = (commentJson["active"] == 1 ? true : false)
                    
                    // Set comment relationships
                    newComment.inspectionData = loadedInspectionData
                    newComment.subSection = newSubSection
                    
                    
                    
                    
                    print("Section: \(newSection.name!)(\(loadedInspectionData?.sections?.count ?? 0)) SubSection: \(newSubSection.id) Comment: \(newComment.id)")
                }
            }
        }
        
        // Save cache changes to disk
        do {
            try managedObjectContext.save()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
    }
    
    // Delete all instances of athe given entity from the cache
    private func deleteAllInstances(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try self.managedObjectContext.execute(deleteRequest)
        } catch {
            print("Error flushing \(entityName) instances from cache")
        }
    }

}
