//
//  StateController.swift
//  HomeInspection
//  
//  Singleton used to manage the state of an inspection
//
//  Created by Jared Speck on 1/11/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class StateController {
    
    // MARK: - Properties
    
    static let state = StateController();
    private let INSPECTION = 1
    private let DEFAULT_DATA = 2 // sections, subsections, and comments
    private let RESULT = 3
    private let LAST_UPDATE = 4
    
    private var inspectionId: Int? = nil
    private var nextResultId: Int = 0
    
    // List of inspection results with unique resultId
    private(set) var results = [Result?]()
    
    // List of all section names with unique sectionId
    private(set) var sections = Dictionary<Int, Section>()
    
    // List of all subsection names with unique subSectionId
    private(set) var subsections = Dictionary<Int, SubSection>()
    
    // List of all comments with unique commentId
    private(set) var comments = Dictionary<Int, Comment>()

    private var reusableResultIds = [Int]()
    
    // End of Properties
    
    
    
    // MARK: - Initialization
    
    // MARK: Flags
    private var needCacheRefresh: Bool = false
    private var dataIsInitialized: Bool = false
    
    // MARK: Initializer
    // Default initializer - Hidden to prevent reinitializing state.
    private init() {
        print("Starting state init\n")
        
        // Check for updates and refresh cache if necessary
        print("\tChecking for updates...")
        self.pullFromUrl(option: LAST_UPDATE)
        
        if (self.needCacheRefresh) {
            print("\tUpdating...")
            self.refreshCache()
        }
        else {
            print("\tCache up to date.")
        }
        
        print("\nState init complete")
        self.dataIsInitialized = true
    }
    
    // Refreshes the local cache of default data if out of sync with online database
    // TODO: Completely wipes default data cache for now, maybe do changes only later
    private func refreshCache() {
        self.dataIsInitialized = false
        
        // Get and parse data from database
        pullFromUrl(option: DEFAULT_DATA)
    }
    
    // End of Initialization
    
    
    
    /**
     * Function Implementations for transmitting data to/from UI
     *
     * Takes in the result id and the item to change, updates the results,
     * then returns the value stored in the results for testing/updating the
     * calling controller's view
     */
    // MARK: - UI Data Transfer
    
    //Appends the results array with a new entry with the given comment id. Returns the result id of the new entry
    func userAddedResult(commentId: Int) -> Int {
        var returnId: Int
        
        if (reusableResultIds.count > 0) {
            // Place result in one of the holes in the list
            returnId = reusableResultIds.popLast()!
            results[returnId] = Result(id: returnId, inspectionId: getNextInspId(), commentId: commentId, variantId: nil)
        }
        else {
            // Add result to the end of the list
            results.append(Result(id: nextResultId, inspectionId: getNextInspId(), commentId: commentId, variantId: nil))
            returnId = nextResultId
            nextResultId += 1
        }
        
        comments[commentId]!.resultId = returnId
        
        return returnId
        
    }
    
    
    func userRemovedResult(resultId: Int) -> Void {
        
        let removedResult = results[resultId]
        let removedCommentId = removedResult!.commentId
        
        comments[removedCommentId!]!.resultId = nil
        
        // Add index of hole to reuasable id list
        reusableResultIds.append(resultId)
        
        // Make a hole in the results list
        results[resultId] = nil
    }
    
    // Adds one to the severity and modulo's the result by 3. Returns the new severity value
    func userChangedSeverity(resultId: Int) -> Int {
        self.results[resultId]!.severity = (self.results[resultId]!.severity % 2) + 1
        return self.results[resultId]!.severity
    }
    
    func userChangedNote(resultId: Int, note: String) -> String {
        print("Note for \(resultId)")
        return note
    }
    
    func userChangedPhoto(resultId: Int, photoPath: String) -> String {
        print("Photo for \(resultId)")
        return photoPath
    }
    
    func userChangedFlags(resultId: Int, flagNums: [Int8]) -> [Int8] {
        print("Flags for \(resultId)")
        return flagNums
    }
    

    
    
    // Get subsection cell information
    
    func getSubSectionText(sectionId: Int, subSectionIndex: Int) -> String {
        let currentSection = self.sections[sectionId]!
        let subSectionId = currentSection.subSectionIds[subSectionIndex]
        
        return subsections[subSectionId]!.subSectionName!
    }
    
    
    // Get comment cell information
    
    // Translates the cells location into a comment id
    func getCommentId(sectionId: Int, subSectionIndex: Int, rowNum: Int) -> Int? {
        let currentSection = sections[sectionId]!
        let currentSubSection = subsections[currentSection.subSectionIds[subSectionIndex]]!
        
        let commentIndex = rowNum - currentSubSection.variantIds.count - 1
        let commentId = currentSubSection.commentIds[commentIndex]
        
        print("Getting comment ID for cell in Section: \(sectionId), Subsection \(subSectionIndex + 1), with Rank: \(commentIndex + 1)")
        print("\(commentId)/\(comments.count)")
    
        return commentId
    }
    
    func getCommentText(commentId: Int) -> String {
        //print("Accessing comment \(commentId)/\(comments.count)")
        if (commentId >= comments.count) {
            return "Error getting text for comment: Id \(commentId) out of range (\(comments.count))"
        }
        return comments[commentId]!.commentText
    }
    
    func getSection(subSectionId: Int) -> Int {
        print("getting section for subsection \(subSectionId)")
        
        return subsections[subSectionId]!.sectionId
    }
    
    // End of UI data transfer functions
    
    
    
    
    // Other Functions
    
    /**
     * Checks local cache if offline, or makes query to online database to find the next
     * unused inspection id.
     * Returns a negative id if offline, storing the inspection locally. This id is
     * overwritten once the report is uploaded to the database
     * Returns a positive id if successfully assigned a permanent id in the database
     */
    
    func getNextInspId() -> Int {
        // FIXME: Implement later, for now always assigns the first slot in the local inspection cache
        return -1;
    }
    
    
    
    // MARK: - Database Integration
    
    // Pulls data from database and calls helper function to handle data
    func pullFromUrl(option: Int) {
        var isPullFinished: Bool = false
        var wasPullError: Bool = false
        var endPointURL: String = ""
        
        switch option {
        case self.INSPECTION:
            break
        case self.DEFAULT_DATA:
            endPointURL = "http://crm.professionalhomeinspection.net/sections.json"
            break
        case self.RESULT:
            break
        case self.LAST_UPDATE:
            break
        default:
            break
        }
        
        guard let url = URL(string: endPointURL) else {
            print("Error: Cannot create URL")
            wasPullError = true
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("Error: Calling GET on option \(option) failed")
                print(error!)
                wasPullError = true
                return
            }
            guard let responseData = data else {
                print ("Error: Received no date")
                wasPullError = true
                return
            }
            do {
                let json = JSON(data: responseData)
                switch option {
                case self.INSPECTION:
                    // FIXME: Parse inspection?
                    break
                case self.DEFAULT_DATA:
                    self.parseDefaultData(json: json)
                    self.dataIsInitialized = true
                    isPullFinished = true
                    break
                case self.RESULT:
                    // FIXME: Parse results?
                    break
                case self.LAST_UPDATE:
                    self.needCacheRefresh = self.compareTimes(lastUpdateJson: json)
                    isPullFinished = true
                    break
                default:
                    print("Cannot parse JSON of type \(option)")
                }
            }
        }
        task.resume()
        
        // Wait for pull to complete before returning
        while (!wasPullError && !isPullFinished) {
            print("Waiting on pull for option \(option) to finish")
            sleep(1)
        }
    }
    
    // MARK: Data Handling Functions
    
    // Parses default data from database and uses data to refresh the local cache (delete old and insert new values)
    func parseDefaultData(json: JSON) {
        let currentContext = StateController.getContext()
        
        // Flush out old data from cache
        self.deleteAllInstances(entityName: "Section")
        self.deleteAllInstances(entityName: "SubSection")
        self.deleteAllInstances(entityName: "Comment")
        
        // Load in new data to the cache
        for (_, sectionJson) in json["sections"] {
            let newSection = Section(context: currentContext)
            
            // Set section attributes
            newSection.id = Int32(sectionJson["id"].intValue)
            newSection.name = sectionJson["name"].string
            
            for (_, subSectionJson) in sectionJson["subsections"] {
                let newSubSection = SubSection(context: currentContext)
                
                // Set subsection attributes
                newSubSection.id = Int32(subSectionJson["id"].intValue)
                newSubSection.name = subSectionJson["name"].string
                
                // Set subsection relationships FIXME: does this add inverse reference as well?
                newSubSection.section = newSection
                
                // FIXME: add variant parsing here
                
                for (_, commentJson) in subSectionJson["comments"] {
                    //let commentId = commentJson["id"].intValue
                    let newComment = Comment(context: currentContext)
                    
                    // Set comment attributes
                    newComment.id = Int32(commentJson["id"].intValue)
                    newComment.rank = Int16(commentJson["rank"].intValue)
                    newComment.text = commentJson["comment"].string
                    newComment.active = (commentJson["active"] == 1 ? true : false)
                    
                    // Set comment relationships
                    newComment.subSection = newSubSection
                    
                    // FIXME: add default flag parsing here

                }
            }
        }
        
        // Save cache changes to disk
        StateController.saveContext()
    }
    
    // Compares last updated times for the default data tables for continuity with database
    private func compareTimes(lastUpdateJson: JSON) -> Bool {
        var doTimesDiffer: Bool = true
        
        // Parse times from database
        let lastCommentUpdate: String = lastUpdateJson["commentTime"].string!
        let lastSubSectionUpdate: String = lastUpdateJson["subSectionTime"].string!
        let lastSectionUpdate: String = lastUpdateJson["sectionTime"].string!
        
        // Get times from cache (if there is one)
        let fetchRequest: NSFetchRequest<LastChange> = LastChange.fetchRequest()
        do {
            let lastChangeResults = try StateController.getContext().fetch(fetchRequest)
            print("\tFound \(lastChangeResults.count > 0 ? "saved " : "no saved") data.")
            
            // Check for correct number of update time in local cache
            if (lastChangeResults.count == 1) {
                let lastChange: LastChange = lastChangeResults[0]
                
                if (lastCommentUpdate == lastChange.commentTime &&
                    lastSubSectionUpdate == lastChange.subSectionTime &&
                    lastSectionUpdate == lastChange.sectionTime) {
                    
                    // Local cache and database times match, no refresh required
                    doTimesDiffer = false
                }
            }
            else if (lastChangeResults.count > 1 || lastChangeResults.count < 0) {
                print("Incorrect number of local update times found. Deleting and refreshing cache")
            }
            else {
                print("No local update times found. Refreshing cache")
            }
            
            
        } catch {
            print("\nError getting last updated time from core data:\n\(error)")
        }
        
        return doTimesDiffer
    }
    

    
    // End of Database Integration Functions
    
    
    
    // MARK: - Core Data Stack
    
    static var persistentContainer: NSPersistentContainer = {
        /*
         The persistent container for the application. This implementation
         creates and returns a container, having loaded the store for the
         application to it. This property is optional since there are legitimate
         error conditions that could cause the creation of the store to fail.
         */
        let container = NSPersistentContainer(name: "Databases")
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
    
    // MARK: Core Data Support
    
    class func getContext() -> NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    class func saveContext () {
        let context = getContext()
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
    
    private func deleteAllInstances(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try StateController.getContext().execute(deleteRequest)
        } catch {
            print("Error flushing \(entityName) instances from cache")
        }
    }
    
    private func getCachedSection() {
    
    }
    
    private func getCachedSubSection() {
        
    }
    
    private func getCachedComment() {
        
    }
    
    private func getCachedResult() {
        
    }
    
    // End of Core Data Stack/Support
    
}
