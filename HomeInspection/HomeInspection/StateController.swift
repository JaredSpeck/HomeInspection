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
    private let SECTION = 2
    private let SUBSECTION = 3
    private let COMMENT = 4
    private let RESULT = 5
    
    // Default initializer - Hidden to prevent reinitializing state. If one needs to load new values, use the loadState function (not implemented yet).
    private init() {
        print("init state")
        //getSections();
        pullFromUrl(option: SECTION)
        pullFromUrl(option: SUBSECTION)
        pullFromUrl(option: COMMENT)
        
        // Need to join pull threads before continuing. Sleep is temporyary to account for delay in receiving required data
        sleep(10)
        /*
        loadInitialSections();
        loadInitialSubSections();
        loadInitialComments();
 */
    }
    
    
    
    /* Properties */
    
    // TODO: Need a way to get the next available inspection id from the server. Maybe use a temp id for offline cache, then assign a permanent id right before integrating into database.
    private var inspectionId: Int32? = nil
    private var nextResultId: Int32 = 0
    
    // Arrays are indexed by their respective unique id's
    
    // List of inspection results with unique resultId
    private var results = [Result]()
    
    // List of all section names with unique sectionId
    private(set) var sections = [Section]()
    
    // List of all subsection names with unique subSectionId
    private(set) var subsections = [SubSection]()
    
    // List of all comments with unique commentId
    private(set) var comments = [Comment]()
    
    // Mapping for section num, subsection num, and comment num in a subsection to a single commentId. NEED TO FIX MAPPING FUNCTION THAT FILLS THESE IN CORRECTLY
    private var commentIds = [[[Int]]]()
    
    /* End of Properties */
    
    
    /**
     * Function Implementations for transmitting data to/from UI
     *
     * Takes in the result id and the item to change, updates the results,
     * then returns the value stored in the results for testing/updating the
     * calling controller's view
     */
    // Appends the results array with a new entry with the given comment id. Returns the result id of the new entry
    func userAddedResult(commentId: Int32) -> Int32 {
        results.append(Result(id: nextResultId, inspectionId: getNextInspId(), commentId: commentId))
        let returnId = nextResultId
        
        nextResultId += 1
        
        return returnId
        
    }
    func userRemovedResult(resultId: Int32) -> Int32 {
        // Not sure what to return here for error checking yet. Removing might totally break array indexing as the array collapses down, but the ids dont update to match
        return 1
    }
    // Adds one to the severity and modulo's the result by 3. Returns the new severity value
    func userChangedSeverity(resultId: Int32) -> Int8 {
        self.results[Int(resultId)].severity = (self.results[Int(resultId)].severity + 1) % 2
        return self.results[Int(resultId)].severity
    }
    
    func userChangedNote(resultId: Int32, note: String) -> String {
        return note
    }
    
    func userChangedPhoto(resultId: Int32, photoPath: String) -> String {
        return photoPath
    }
    
    func userChangedFlags(resultId: Int32, flagNums: [Int8]) -> [Int8] {
        return flagNums
    }
    
    // Translates the cells location into a comment id
    func getCommentId(section: Int, subSection: Int, row: Int) -> Int? {
        return row//commentIds[section][subSection][row];
    }
    
    // Gets the status of the comment with id commentId from the comment table
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
    
    func getNextInspId() -> Int32 {
        // TODO: Implement later, for now always assigns the first slot in the local inspection cache
        return -1;
    }
    
    // Loads the initial comments into the comments table (reserved comments for use when adding notes if that is still the plan)
    func loadInitialComments() {
        comments.append(Comment(commentId: 0, subSectionId: 0, rank: 0, commentText: "", defaultFlags: [], active: true))
        comments.append(Comment(commentId: 1, subSectionId: 1, rank: 0, commentText: "Sample Comment 1: Bad driveway. Boooo", defaultFlags: [1, 2], active: false))
        comments.append(Comment(commentId: 2, subSectionId: 2, rank: 0, commentText: "Sample Comment 2: Ignore the next comment. It's a liar", defaultFlags: [2, 4], active: false))
        comments.append(Comment(commentId: 3, subSectionId: 2, rank: 1, commentText: "Sample Comment 3: Listen to the previous comment. It's the truth", defaultFlags: [3, 5], active: false))
    }
    
    // Loads Sample subsections in for testing (This will be handled by the database integration code once implemented)
    func loadInitialSubSections() {
        subsections.append(SubSection(subSectionId: 1, name: "Sample Sub: Driveway", sectionId: 2))
        subsections.append(SubSection(subSectionId: 2, name: "Sample Sub: Paradox", sectionId: 2))
    }
    
    // Loads Sample sections in for testing (This will also be handled by the database integration code once implemented)
    func loadInitialSections() {
        sections.append(Section(id: 0, name: ""))
        sections.append(Section(id: 1, name: "Bad Sample Section: Kitchen"))
        sections.append(Section(id: 2, name: "Good Sample Section: Grounds"))
        sections.append(Section(id: 3, name: "Sample Section 3"))
        sections.append(Section(id: 4, name: "Sample Section 4"))
        sections.append(Section(id: 5, name: "Sample Section 5"))
        sections.append(Section(id: 6, name: "Sample Section 6"))
        sections.append(Section(id: 7, name: "Sample Section 7"))
        sections.append(Section(id: 8, name: "Sample Section 8"))
    }
    
    
    /* Database Integration Functions */
    
    
    func pullFromUrl(option: Int) {
        var endPointURL: String = ""
        
        switch option {
        case self.INSPECTION:
            break
        case self.SECTION:
            endPointURL = "http://crm.professionalhomeinspection.net/sections.json"
            break
        case self.SUBSECTION:
            endPointURL = "http://crm.professionalhomeinspection.net/subsections.json"
            break
        case self.COMMENT:
            endPointURL = "http://crm.professionalhomeinspection.net/comments.json"
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
                    break
                case self.SECTION:
                    self.parseSections(json: json)
                    break
                case self.SUBSECTION:
                    self.parseSubSections(json: json)
                    break
                case self.COMMENT:
                    self.parseComments(json: json)
                    break
                case self.RESULT:
                    break
                default:
                    break
                }
            }
        }
        task.resume()
        
    }
    
    func parseSections(json: JSON) {
        for (index, subJson) in json["sections"] {
            self.sections.append(Section(id: subJson["id"].intValue,
                                         name: subJson["name"].string))
        }
    }
    func parseSubSections(json: JSON) {
        for (index, subJson) in json["subsections"] { //iterate through and store into comments
            self.subsections.append(SubSection(subSectionId: subJson["id"].intValue - 121,
                                               name: subJson["name"].string,
                                               sectionId: subJson["sec_id"].intValue))
        }
    }
    func parseComments(json: JSON) {
        for (index, subJson) in json["comments"] { //iterate through and store into comments
            self.comments.append(Comment(commentId: subJson["id"].intValue,
                                         subSectionId: subJson["subsec_id"].intValue - 121,
                                         rank: 0,
                                         commentText: subJson["comment"].string,
                                         defaultFlags: [], //Fix this
                active: subJson["active"] == 1 ? true:false))
            print(subJson["default_flags"])
        }
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
