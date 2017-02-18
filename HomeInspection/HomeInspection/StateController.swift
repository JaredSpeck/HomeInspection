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

class StateController {
    
    /**
     * State Variable
     *
     * Holds the State controller singleton, managing the current state of a single inspection.
     */
    static let state = StateController();
    private let INSPECTION = 1
    private let DEFAULT_DATA = 2
    private let RESULT = 3
    
    
    
    /* Properties */
    
    
    
    // TODO: Need a way to get the next available inspection id from the server. Maybe use a temp id for offline cache, then assign a permanent id right before integrating into database.
    private var inspectionId: Int? = nil
    private var nextResultId: Int = 0
    
    // Arrays are indexed by their respective unique id's
    
    // List of inspection results with unique resultId
    private var results = [Result?]()
    
    // List of all section names with unique sectionId
    private(set) var sections = [Section]()
    
    // List of all subsection names with unique subSectionId
    private(set) var subsections = [SubSection]()
    
    // List of all comments with unique commentId
    private(set) var comments = [Comment]()
    
    // Mapping for section num, subsection num, and comment num in a subsection to a single commentId. NEED TO FIX MAPPING FUNCTION THAT FILLS THESE IN CORRECTLY
    private var commentIds = [[[Int]]]()
    
    private var dataIsInitialized: Bool = false
    private var reusableResultIds = [Int]()
    
    /* End of Properties */
    
    
    // Default initializer - Hidden to prevent reinitializing state. If one needs to load new values, use the loadState function (not implemented yet).
    private init() {
        print("init state")
        
        self.dataIsInitialized = false
        
        // Get and parse data from database
        pullFromUrl(option: DEFAULT_DATA)
        
        // Polling for completion of database pull and parsing. Simple, but semaphores may be more efficient design (save extra fraction of a second and no wake then sleep again)
        while (!self.dataIsInitialized) {
            sleep(1)
        }
    }
    
    
    /**
     * Function Implementations for transmitting data to/from UI
     *
     * Takes in the result id and the item to change, updates the results,
     * then returns the value stored in the results for testing/updating the
     * calling controller's view
     */
    // Appends the results array with a new entry with the given comment id. Returns the result id of the new entry
    func userAddedResult(commentId: Int) -> Int {
        results.append(Result(id: nextResultId, inspectionId: getNextInspId(), commentId: commentId))
        var returnId: Int
        
        if (reusableResultIds.count > 0) {
            returnId = reusableResultIds.popLast()!
        }
        else {
            returnId = nextResultId
            nextResultId += 1
        }
        
        return returnId
        
    }
    func userRemovedResult(resultId: Int) -> Void {
        // Not sure what to return here for error checking yet. Removing might totally break array indexing as the array collapses down, but the ids dont update to match
        reusableResultIds.append((Int(resultId)))
        results[resultId] = nil
    }
    // Adds one to the severity and modulo's the result by 3. Returns the new severity value
    func userChangedSeverity(resultId: Int) -> Int8 {
        self.results[Int(resultId)]!.severity = ((self.results[Int(resultId)]!.severity + 1) % 2) + 1
        return self.results[resultId]!.severity
    }
    
    func userChangedNote(resultId: Int, note: String) -> String {
        return note
    }
    
    func userChangedPhoto(resultId: Int, photoPath: String) -> String {
        return photoPath
    }
    
    func userChangedFlags(resultId: Int, flagNums: [Int8]) -> [Int8] {
        return flagNums
    }
    
    // Translates the cells location into a comment id
    func getCommentId(sectionNum: Int, subSectionNum: Int, rowNum: Int) -> Int? {
        print("Getting comment ID for cell in Section: \(sectionNum), Subsection \(subSectionNum), with Rank: \(rowNum)")
        var section: Section
        var subSection: SubSection
        var comment: Comment
        var commentId = -1
        
        if (sections.count > sectionNum) {
            section = sections[sectionNum]
            print("Found section \(section.sectionId!)")
            if (section.subSectionIds.count > subSectionNum &&
                subsections.count > section.subSectionIds[subSectionNum]) {
                
                subSection = subsections[section.subSectionIds[subSectionNum]]
                print("Found subsection \(subSection.sectionId!)")
                if (subSection.commentIds.count > rowNum &&
                    comments.count > subSection.commentIds[rowNum]) {
                    
                    comment = comments[subSection.commentIds[rowNum]]
                    commentId = comment.commentId!
                    print("Found comment \(comment.commentId!)")
                }
            }
        }

        return commentId
    }
    
    // Get subsection cell information
    
    func getSubSectionText(sectionIndex: Int, subSectionNum: Int) -> String {
        let section = self.sections[sectionIndex]
        let subSectionId = section.subSectionIds[subSectionNum]
        
        for index in 0..<subsections.count {
            if (subsections[index].subSectionId == subSectionId) {
                return subsections[index].subSectionName!
            }
        }
        
        return "Not Found"
    }
    
    
    // Get comment cell information
    func getCommentState(commentId: Int) -> Bool {
        return false//comments[commentId].active;
    }
    
    func getCommentText(commentId: Int) -> String {
        return comments[commentId].commentText
    }
    
    func getSection(subSectionId: Int) -> Int {
        print("getting section for subsection \(subSectionId)")
        
        return subsections[subSectionId].sectionId
    }
    
    
    
    
    
    // Add sections/subsections/comments during inspection
    func addComment(newComment: Comment) {
        self.comments.append(newComment)
    }
    
    func addSubSection(newSubSection: SubSection) {
        self.subsections.append(newSubSection)
    }
    
    func addSection(newSection: Section) {
        self.sections.append(newSection)
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
    func mapCommentId(commentId: Int!, sectionNum: Int!, subSectionNum: Int!, rowNum: Int!) {
        print("Mapping commentId: \(commentId!) to [\(sectionNum)][\(subSectionNum)][\(rowNum)]")
        commentIds[sectionNum][subSectionNum][rowNum] = commentId;
    }
    
    func getNextInspId() -> Int {
        // TODO: Implement later, for now always assigns the first slot in the local inspection cache
        return -1;
    }
    
    
    
    /* Database Integration Functions */
    
    
    func pullFromUrl(option: Int) {
        var endPointURL: String = ""
        
        switch option {
        case self.INSPECTION:
            break
        case self.DEFAULT_DATA:
            endPointURL = "http://crm.professionalhomeinspection.net/sections.json"
            break
        case self.RESULT:
            break
        default:
            break
        }
        
        guard let url = URL(string: endPointURL) else {
            print("Error: cannot create URL")
            return
        }
        let urlRequest = URLRequest(url: url)
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: urlRequest) {
            (data, response, error) in
            guard error == nil else {
                print("error calling GET on option")
                print(error!)
                return
            }
            guard let responseData = data else {
                print ("Error: did not recieve data")
                return
            }
            do {
                let json = JSON(data: responseData)
                switch option {
                case self.INSPECTION:
                    // Parse inspection?
                    break;
                case self.DEFAULT_DATA:
                    self.parseDefaultData(json: json)
                    self.dataIsInitialized = true
                    break;
                case self.RESULT:
                    // Parse results?
                    break;
                default:
                    print("Cannot parse JSON of type \(option)")
                }
            }
        }
        task.resume()
        
    }
    
    // TODO: Decide whether to do database surgery to fix 121 offset in subsection id or not
    func parseDefaultData(json: JSON) {
        for (_, sectionJson) in json["sections"] {
            self.sections.append(
                Section(
                    id: sectionJson["id"].intValue,
                    name: sectionJson["name"].string
                )
            )
            
            for (_, subSectionJson) in sectionJson["subsections"] {
                self.subsections.append(
                    SubSection(
                        subSectionId: subSectionJson["id"].intValue - 121,
                        name: subSectionJson["name"].string,
                        sectionId: subSectionJson["sec_id"].intValue
                    )
                )
                
                // Add subsec id to section's subsec list
                self.sections.last!.subSectionIds.append(subsections.last!.subSectionId)
                
                for (_, commentJson) in subSectionJson["comments"] {
                    self.comments.append(
                        Comment(
                            commentId: commentJson["id"].intValue,
                            subSectionId: commentJson["subsec_id"].intValue - 121,
                            rank: 0,
                            commentText: commentJson["comment"].string,
                            defaultFlags: [], //Fix this
                            active: commentJson["active"] == 1 ? true:false
                        )
                    )
                    
                    // Add comment id to subsection's comment list
                    self.subsections.last!.commentIds.append(comments.last!.commentId)
                }
            }
        }
    }
    
    
    /* End of Database Integration Functions */
    
}
