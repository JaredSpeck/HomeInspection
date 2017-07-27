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
    private let LAST_CHANGE = 4
    
    private var inspectionId: Int? = nil
    private var nextResultId: Int = 0
    
    var managedObjectContext: NSManagedObjectContext!
    
    // List of all inspections cached in device
    private(set) var inspections = [Inspection]()
    
    // List of inspection results with unique resultId
    private(set) var results = [Result]()
    
    // List of all section names with unique sectionId
    private(set) var sections = [Section]()
    
    // List of all subsection names with unique subSectionId
    private(set) var subsections = [SubSection]()
    
    // List of all comments with unique commentId
    private(set) var comments = [Comment]()

    private var reusableResultIds = [Int]()
    
    // Holds timestamp of last time default data was modified
    private var localModTimes: AppValues!
    
    // End of Properties
    
    
    
    // MARK: - Initialization
    
    // MARK: Flags
    private var needCacheRefresh: Bool = true
    private var dataIsInitialized: Bool = false
    
    // MARK: Initializer
    // Default initializer - Hidden to prevent reinitializing state.
    private init() {
        self.dataIsInitialized = false
        print("Starting state init\n")
        
        //loadData();
        
        print("\nState init complete")
        self.dataIsInitialized = true
    }
    
    private func loadData(tries: Int = 0) {
        // Initialize the managed object context (Core Data stack)
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Ensures cache is up to date with most recent default data
        validateCache()
        
        // Load default data from device
        let sectionRequest: NSFetchRequest<Section> = Section.fetchRequest()
        let subSectionRequest: NSFetchRequest<SubSection> = SubSection.fetchRequest()
        let commentRequest: NSFetchRequest<Comment> = Comment.fetchRequest()
        
        // Load cached data from device
        let inspectionRequest: NSFetchRequest<Inspection> = Inspection.fetchRequest()
        let resutRequest:NSFetchRequest<Result> = Result.fetchRequest()
        
        do {
            sections = try managedObjectContext.fetch(sectionRequest)
            subsections = try managedObjectContext.fetch(subSectionRequest)
            comments = try managedObjectContext.fetch(commentRequest)
            inspections = try managedObjectContext.fetch(inspectionRequest)
            results = try managedObjectContext.fetch(resutRequest)
        } catch {
            // Attempt to try again. (up to 3 attempts)
            print("Error loading data from device memory: \(error.localizedDescription)")
            if (tries < 2) {
                loadData(tries: tries + 1)
            } else {
                print("Failed too many times. Quitting")
            }
        }
    }
    
    // Refreshes the local cache of default data if out of sync with online database
    // TODO: Completely wipes default data cache for now, maybe do changes only later
    private func validateCache() {
        // Get last change timestamp from device
        let appValuesRequest: NSFetchRequest<AppValues> = AppValues.fetchRequest()
        do {
            let fetchResult = try managedObjectContext.fetch(appValuesRequest)
            if (fetchResult.first != nil) {
                localModTimes = fetchResult.first!
            }
        } catch {
            print("Could not fetch last data update timestamp from device: \(error.localizedDescription)")
        }
        
        // Check online for last change timestamp
        print("\tChecking for updates...")
        self.pullFromUrl(option: LAST_CHANGE)
        
        // FIXME: Remove once working correctly
        
        if (self.needCacheRefresh) {
            print("\tUpdating...")
            // Get and parse data from database
            pullFromUrl(option: DEFAULT_DATA)
        }
        else {
            print("\tCache up to date.")
        }
        
        print("Local cache validated")
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
        
        var addedResult: Result
        
        if (reusableResultIds.count > 0) {
            // Place result in one of the holes in the list
            returnId = reusableResultIds.popLast()!
            addedResult = results[returnId]
            //results[returnId] = Result(id: returnId, inspectionId: getNextInspId(), commentId: commentId, variantId: nil)
            addedResult.id = Int32(returnId)
            //resultItem.inspection = getNextInspId()
            addedResult.comment!.id = Int32(commentId)
            addedResult.variant = nil
            addedResult.isActive = true
            
        }
        else {
            // Add result to the end of the list
            addedResult = Result(context: managedObjectContext)
            addedResult.id = Int32(nextResultId)
            //addedResult.inspection = ?
            addedResult.comment!.id = Int32(commentId)
            addedResult.variant = nil
            addedResult.isActive = true
            
            results.append(addedResult)
            returnId = nextResultId
            nextResultId += 1
        }
        
        //comments[commentId].resultId = returnId
        
        return returnId
        
    }
    
    
    func userRemovedResult(resultId: Int) -> Void {
        
        //let removedResult = results[resultId]
        
        //TODO: if let to test between comment and variant
        //let removedCommentId = Int((removedResult.comment?.id)!)
        
        //comments[removedCommentId].resultId = nil
        
        // Add index of hole to reuasable id list
        reusableResultIds.append(resultId)
        
        // Make a hole in the results list
        results[resultId].isActive = false
    }
    
    // Adds one to the severity and modulo's the result by 3. Returns the new severity value

    
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
        /*let currentSection = self.sections[sectionId]!
        let subSectionId = currentSection.subSectionIds[subSectionIndex]
        */
        return "Under Construction"//subsections[subSectionId]!.subSectionName!
    }
    
    
    // Get comment cell information
    
    // Translates the cells location into a comment id
    func getCommentId(sectionId: Int, subSectionIndex: Int, rowNum: Int) -> Int? {
        /*let currentSection = sections[sectionId]!
        let currentSubSection = subsections[currentSection.subSectionIds[subSectionIndex]]!
        
        let commentIndex = rowNum - currentSubSection.variantIds.count - 1
        let commentId = currentSubSection.commentIds[commentIndex]
        
        print("Getting comment ID for cell in Section: \(sectionId), Subsection \(subSectionIndex + 1), with Rank: \(commentIndex + 1)")
        print("\(commentId)/\(comments.count)")

        */
        
        return 0//commentId
    }
    
    func getCommentText(commentId: Int) -> String {
        //print("Accessing comment \(commentId)/\(comments.count)")
        if (commentId >= comments.count) {
            return "Error getting text for comment: Id \(commentId) out of range (\(comments.count))"
        }
        return "Under Construction"//comments[commentId]!.commentText
    }
    
    func getSection(subSectionId: Int) -> Int {
        print("getting section for subsection \(subSectionId)")
        
        return 0//subsections[subSectionId]!.sectionId
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
        case self.LAST_CHANGE:
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
                case self.LAST_CHANGE:
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
        
        // Flush out old data from cache
        self.deleteAllInstances(entityName: "Section")
        self.deleteAllInstances(entityName: "SubSection")
        self.deleteAllInstances(entityName: "Comment")
        
        // Load in new data to the cache
        for (_, sectionJson) in json["sections"] {
            let newSection = Section(context: managedObjectContext)
            
            // Set section attributes
            newSection.id = Int32(sectionJson["id"].intValue)
            newSection.name = sectionJson["name"].string
            
            for (_, subSectionJson) in sectionJson["subsections"] {
                let newSubSection = SubSection(context: managedObjectContext)
                
                // Set subsection attributes
                newSubSection.id = Int32(subSectionJson["id"].intValue)
                newSubSection.name = subSectionJson["name"].string
                
                // Set subsection relationships FIXME: does this add inverse reference as well?
                newSubSection.section = newSection
                
                // FIXME: add variant parsing here
                
                for (_, commentJson) in subSectionJson["comments"] {
                    //let commentId = commentJson["id"].intValue
                    let newComment = Comment(context: managedObjectContext)
                    
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
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Could not save data \(error.localizedDescription)")
        }
    }
    
    // Compares last updated times for the default data tables for continuity with database
    private func compareTimes(lastUpdateJson: JSON) -> Bool {
        var doTimesDiffer: Bool = true
        
        // Parse times from database
        let lastCommentUpdate: String = lastUpdateJson["commentTime"].string!
        let lastSubSectionUpdate: String = lastUpdateJson["subSectionTime"].string!
        let lastSectionUpdate: String = lastUpdateJson["sectionTime"].string!
        
        // Get times from cache (if there is one)
        let fetchRequest: NSFetchRequest<AppValues> = AppValues.fetchRequest()
        do {
            let fetchRequestResults = try self.managedObjectContext.fetch(fetchRequest)
            print("\tFound \(fetchRequestResults.count > 0 ? "saved " : "no saved") data.")
            
            // Check for correct number of update time in local cache
            if (fetchRequestResults.count == 1) {
                let appValues: AppValues = fetchRequestResults.first!
                
                if (lastCommentUpdate == appValues.commentModTime &&
                    lastSubSectionUpdate == appValues.subSectionModTime &&
                    lastSectionUpdate == appValues.sectionModTime) {
                    
                    // Local cache and database times match, no refresh required
                    doTimesDiffer = false
                }
            }
            else if (fetchRequestResults.count > 1 || fetchRequestResults.count < 0) {
                print("Incorrect number of local update times found. Deleting and refreshing cache")
            }
            else {
                print("No local update times found. Refreshing cache")
            }
            
            
        } catch {
            print("\nError getting last updated time from core data:\n\(error)")
        }
        // FIXME: Need to get a url for update time
        return true//doTimesDiffer
    }
    

    
    // End of Database Integration Functions
    
    
    
        
    private func deleteAllInstances(entityName: String) {
        let fetch = NSFetchRequest<NSFetchRequestResult>(entityName: entityName)
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetch)
        
        do {
            try self.managedObjectContext.execute(deleteRequest)
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
