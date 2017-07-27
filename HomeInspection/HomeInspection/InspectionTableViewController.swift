//
//  SubSectionTableViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class InspectionTableViewController: UITableViewController {

    
    
    // MARK: Properties
    
    // Parent managed
    var currentSectionId: Int32!
    weak var loadedInspection: Inspection!
    weak var loadedInspectionData: InspectionData!
    
    private let BASE_NUM_COMMENTS = 4
    private var managedObjectContext: NSManagedObjectContext!
    private var loadedAppValues: AppValues!
    private var currentSection: Section!
    private var currentSubSections: [SubSection]!
    
    
    
    // MARK: Table Initialization Functions
    
    // Called one time when loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load CoreData context
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        // Register refresh notifications
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "refreshSection"), object: nil, queue: nil, using: refreshSection)
        NotificationCenter.default.addObserver(forName: NSNotification.Name(rawValue: "refreshSubSection"), object: nil, queue: nil, using: refreshSubSection)
        
        // Register XIB reuse identifiers
        let sscell = UINib(nibName: "SubSectionHeaderViewCell", bundle: nil)
        tableView.register(sscell, forCellReuseIdentifier: "SubSectionHeaderViewCell")
        let vcell = UINib(nibName: "VariantViewCell", bundle: nil)
        tableView.register(vcell, forCellReuseIdentifier: "VariantViewCell")
        let ccell = UINib(nibName: "CommentViewCell", bundle: nil)
        tableView.register(ccell, forCellReuseIdentifier: "CommentViewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
    }

    override func viewWillAppear(_ animated: Bool) {
        // Load app values from disk
        let avFetchRequest: NSFetchRequest<AppValues> = AppValues.fetchRequest()
        do {
            let fetchRequestResults: [AppValues] = try managedObjectContext.fetch(avFetchRequest)
            if let appValues = fetchRequestResults.first {
                loadedAppValues = appValues
            }
        } catch {
            print("Error loading appvalues for inspection table VC: \(error.localizedDescription)")
        }
        
        // Load current section
        if let tempSection: Section = loadedInspectionData.sections?.first(where: {($0 as! Section).id == currentSectionId}) as? Section {
            currentSection = tempSection
        } else {
            print("Cannot find section with id: \(currentSectionId)")
        }
        
        // Load current subsections array
        if let tempSubSections: [SubSection] = currentSection.subSections?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [SubSection] {
            currentSubSections = tempSubSections
        } else {
            print("Could not load subsections for section \(currentSectionId)")
        }
    }
    
    // Called on receipt of memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    // REQUIRED: Set the number of sections in the table (= number of subsections for the chosen section)
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections (subsections in a given section)
        return currentSection.subSections?.count ?? 0
    }

    // REQUIRED: Set the number of rows per section (= number of comments for given subsection)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of cells = number of variant cells + number of comments + 1 for subsection header - 1 for blank comment
        var numComments: Int = 0
        var numVariants: Int = 0
        var expandedNumCells: Int = 0
        var numCommentsShown: Int = 0
        
        let currentSubSection: SubSection = currentSubSections[section]
        
        numComments = (currentSubSection.comments?.count ?? 1) - 1
        numVariants = currentSubSection.variants?.count ?? 0
        expandedNumCells = numComments + numVariants
        numCommentsShown = 1 + BASE_NUM_COMMENTS + numVariants - 1
        
        if (currentSubSection.isExpanded || expandedNumCells < numCommentsShown) {
            numCommentsShown = expandedNumCells
        }
        
        return numCommentsShown
    }
    
    // REQUIRED: Initialize/Reuse table cells based on identifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let subSectionIndex = indexPath.section
        //let variantCellCount = StateController.state.subsections[subSectionIndex + 1].variants?.count
        
        var identifier: String
        
        // Set identifier based off of row location
        if (indexPath.row == 0) {
            identifier = "SubSectionHeaderViewCell"
        }
        //else if (indexPath.row > 0 && indexPath.row <= variantCellCount!) {
            //identifier = "VariantViewCell"
        //}
        else {
            identifier = "CommentViewCell"
        }
        
        // Dequeue a reusable cell based off of identifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
        
        // Remove selection highlighting
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Initialize cell based off of identifier
        switch (identifier) {
        case "SubSectionHeaderViewCell":
            let subSectionCell = cell as! SubSectionHeaderViewCell
            initSubSectionCell(cell: subSectionCell, subSectionIndex: subSectionIndex)
            return subSectionCell
            
        case "VariantViewCell":
            let variantCell = cell as! VariantViewCell
            //initVariantCell(cell: variantCell, subSectionIndex: subSectionIndex, row: indexPath.row)
            return variantCell
            
        case "CommentViewCell":
            let commentCell = cell as! CommentViewCell
            initCommentCell(cell: commentCell, subSectionIndex: subSectionIndex, row: indexPath.row)
            return commentCell
            
        default:
            print("Cannot init unknown cell type '\(identifier)'")
            return cell
        }
    }
    
    /* End of Table Initialization Functions */
    
    
    
    /* Cell Initialization Functions */
    
    // Initializes subsection cells with values loaded from the state controller
    func initSubSectionCell(cell: SubSectionHeaderViewCell, subSectionIndex: Int) {
        let currentSubSection: SubSection = currentSubSections[subSectionIndex]
        
        // Set cell text
        let subSectionText: String = currentSubSection.name!
        cell.subSectionLabel.text = subSectionText
        cell.subSectionStatusLabel.text = "All clear for \(subSectionText)"
        cell.expandButtonLabel.text = (currentSubSection.isExpanded ? "-" : "+")
        cell.tableIndex = subSectionIndex
        
        // Set expand button function
        cell.expandButtonTapAction = { [weak managedObjectContext] (cell) in
            let isExpanded = currentSubSection.isExpanded
            currentSubSection.isExpanded = !isExpanded
            do {
                try managedObjectContext?.save()
            } catch {
                print("Error saving subsection expansion: \(error.localizedDescription)")
            }
            
            // Tell table to refresh subsection (Show the expanded cells)
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSubSection"), object: cell.tableIndex)
        }
        
    }
    
    // Initialize variant cells with values loaded from state controller
    func initVariantCell(cell: VariantViewCell, subSectionIndex: Int, row: Int) {
        let state = StateController.state
        var formatString: String = state.getVariantString()
        
        // Parses format string and initialized cell with
        //parse(string: formatString, cell)
        getType(string: &formatString, varC: cell)
        print("Afer Type: \(formatString)")
        if(cell.type == 0){
            getVariantLabel(string: &formatString, varC: cell)
            print("After removing label: \(formatString)")
            getnumFlags(string: &formatString, varC: cell)
            print("Num flags: \(cell.numFlag)")
            print("After removing numFlags: \(formatString)")
            getFlags(string: &formatString, varC: cell)
            print("After GetFlag: \(formatString)")
            getFlagStates(string: &formatString, varC: cell)
            print("After GetFlagV: \(formatString)")
        }
        else{
            getVariantLabel(string: &formatString, varC: cell)
            getVariantValue(string: &formatString, varC: cell)
            getVariantExtra(string: &formatString, varC: cell)
        }
        
        
    }
    
    
    
    
    
    
    
    
    /* BLEJHRKEHTGENP */
    
    //This function gets the type either radio or fill in and marks the vCell type accordingly.
    //Using the removeSubrange the string is edited to remove the first part of the string
    func getType(string: inout String, varC: VariantViewCell){
        if (string[string.startIndex] == "r")
        {
            varC.type = 0
            varC.showTextField.priority = 250
            varC.showRadioField.priority = 900
        }
        else if (string[string.startIndex] == "f")
        {
            varC.type = 1
            varC.showTextField.priority = 900
            varC.showRadioField.priority = 250
        }
        let range = string.startIndex..<string.index(string.startIndex, offsetBy: 2)
        string.removeSubrange(range)
        
    }
    
    //This function gets the first text field from the database that will go in front. It gets the index of the next semicolon
    // gets the indexes around it, then using that info makes a range to copy the field into Vcell’s dbText field
    //Using the removeSubrange the main string is edited to remove the first part of the string
    func getVariantLabel(string: inout String, varC: VariantViewCell){
        let c = string.characters
        let indexS = c.index(of: ";")!
        let indexAfterS = c.index(after: indexS)
        
        if (varC.type == 0) {
            print("Changed Label for 0 type")
            varC.nameTextField.text = string[string.startIndex..<indexS]
        }
        else {
            print("Changed Label for 1 type")
            varC.labelTextField.text = string[string.startIndex..<indexS]
        }
        
        let range = string.startIndex..<indexAfterS
        string.removeSubrange(range)
    }
    //Function gets the number of flags for a radio format, gets the index of next semicolon
    // gets the indexes around it, then using that info makes a range to copy the field and convert to Int
    // value is then placed in Vcells numFlag value
    //Using the removeSubrange the main string is edited to remove the first part of the string
    func getnumFlags(string: inout String, varC: VariantViewCell){
        let c = string.characters
        let indexS = c.index(of: ";")!
        let indexAfterS = c.index(after: indexS)
        var temp: String?
        temp = string[string.startIndex..<indexS]
        
        
        let number = Int(temp!)!
        varC.numFlag = number
        
        let range = string.startIndex..<indexAfterS
        string.removeSubrange(range)
    }
    //Function gets the flag names for a radio format, gets the index of next semicolon
    // gets the indexes around it, then using that info makes a range to copy the field
    // value is then placed in Vcells flag1-flag8 value
    //Using the removeSubrange the main string is edited to remove the first part of the string
    //This repeats in a for loop using num Flags as a condition goes up from 1 to 8
    func getFlags(string: inout String, varC: VariantViewCell){
        let c = string.characters
        let indexS = c.index(of: ";")!
        let indexAfterS = c.index(after: indexS)
        
        varC.updateRadioPriorities(numButtons: varC.numFlag)
        
        for index in 1...varC.numFlag {
            
            switch index{
            case 1:
                varC.flag1TextField.text = string[string.startIndex..<indexS]
            case 2:
                varC.flag2TextField.text = string[string.startIndex..<indexS]
            case 3:
                varC.flag3TextField.text = string[string.startIndex..<indexS]
            case 4:
                varC.flag4TextField.text = string[string.startIndex..<indexS]
            case 5:
                varC.flag5TextField.text = string[string.startIndex..<indexS]
            case 6:
                varC.flag6TextField.text = string[string.startIndex..<indexS]
            case 7:
                varC.flag7TextField.text = string[string.startIndex..<indexS]
            case 8:
                varC.flag8TextField.text = string[string.startIndex..<indexS]
            default:
                print("NumFlag was not between 1 and 8 was \(varC.numFlag)")
            }
            let range = string.startIndex..<indexAfterS
            string.removeSubrange(range)
        }
    }
    //Function gets the flag starting values for a radio format, gets the index of next semicolon
    // gets the indexes around it, then using that info makes a range to copy the field
    // value is then placed in Vcells flag1-flag8 value
    //Using the removeSubrange the main string is edited to remove the first part of the string
    //This repeats in a for loop using num Flags as a condition goes up from 1 to 8
    
    func getFlagStates(string: inout String, varC: VariantViewCell){
        let c = string.characters
        let indexS = c.index(of: ";")!
        let indexAfterS = c.index(after: indexS)
        for index in 1...varC.numFlag {
                switch index{
                case 1:
                    varC.flag1Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 2:
                    varC.flag2Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 3:
                    varC.flag3Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 4:
                    varC.flag4Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 5:
                    varC.flag5Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 6:
                    varC.flag6Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 7:
                    varC.flag7Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                case 8:
                    varC.flag8Switch.setOn(string[string.startIndex] == "1" ? true : false, animated: false)
                default:
                    print("NumFlag was not between 1 and 8 was \(varC.numFlag)")
                }
            let range = string.startIndex..<indexAfterS
            string.removeSubrange(range)
        }
    }
    
    //Function gets starting text for the fill in, gets the index of the next semicolon
    // gets the indexes around it, then using that info makes a range to copy the field
    // value is then placed in Vcells User Text string
    //Using the removeSubrange the main string is edited to remove the first part of the string
    func getVariantValue(string: inout String, varC: VariantViewCell){
        let c = string.characters
        let indexS = c.index(of: ";")!
        let indexAfterS = c.index(after: indexS)
        
        varC.valueTextField.text = string[string.startIndex..<indexS]
        
        let range = string.startIndex..<indexAfterS
        string.removeSubrange(range)
    }
    
    //Function gets end Text for fill in, gets the index of the next semicolon
    // gets the indexes around it, then using that info makes a range to copy the field
    // value is then placed in Vcells DBText string
    //Using the removeSubrange the main string is edited to remove the first part of the string
    
    func getVariantExtra(string: inout String, varC: VariantViewCell){
        let c = string.characters
        let indexS = c.index(of: ";")!
        let indexAfterS = c.index(after: indexS)
        
        varC.extraTextField.text = string[string.startIndex..<indexS]
        
        let range = string.startIndex..<indexAfterS
        string.removeSubrange(range)
    }
    
    //Function uses the fields in Vcell and creates the radio and fill in string format
    // where each field ends with a semicolon use NumFlag and type in Vcell the
    // function determines which case is appropriate for the data
    /*func compose(string: inout String, varC: VariantViewCell){
        if(varC.type == 1){
            switch varC.numFlag{
            case 1:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flagV1);"
            case 2:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flagV1);\(varC.flagV2);"
            case 3:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flag3!);\(varC.flagV1);\(varC.flagV2);\(varC.flagV3);"
            case 4:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flag3!);\(varC.flag4!);\(varC.flagV1);\(varC.flagV2);\(varC.flagV3);\(varC.flagV4);"
            case 5:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flag3!);\(varC.flag4!);\(varC.flag5!);\(varC.flagV1);\(varC.flagV2);\(varC.flagV3);\(varC.flagV4);\(varC.flagV5);"
            case 6:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flag3!);\(varC.flag4!);\(varC.flag5!);\(varC.flag6!);\(varC.flagV1);\(varC.flagV2);\(varC.flagV3);\(varC.flagV4);\(varC.flagV5);\(varC.flagV6);"
            case 7:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flag3!);\(varC.flag4!);\(varC.flag5!);\(varC.flag6!);\(varC.flag7!);\(varC.flagV1);\(varC.flagV2);\(varC.flagV3);\(varC.flagV4);\(varC.flagV5);\(varC.flagV6);\(varC.flagV7);"
            case 8:
                string = "r;\(varC.dbText!);\(varC.numFlag);\(varC.flag1!);\(varC.flag2!);\(varC.flag3!);\(varC.flag4!);\(varC.flag5!);\(varC.flag6!);\(varC.flag7!);\(varC.flag7!);\(varC.flagV1);\(varC.flagV2);\(varC.flagV3);\(varC.flagV4);\(varC.flagV5);\(varC.flagV6);\(varC.flagV7);\(varC.flagV8);"
            default:
                print("NumFlag was not between 1 and 8 was \(varC.numFlag)")
            }
        }
        else{
            string = "f;\(varC.dbText!);\(varC.userText!);\(varC.dbText2!)"
        }
        
    }*/
    //Combines the above functions to allow for one call to parse the string format
    // function takes in a string creates a Vcell and returns it once complete
    /*
     func parse(string: inout String){
        let data = Vcell()
        getType(string: &string, varC: data)
        print("Afer Type: \(string)")
        if(data.type == 1){
            getDBText(string: &string, varC: data)
            print("After DBText: \(string)")
            getnumFlag(string: &string, varC: data)
            print("Num Flag \(data.numFlag)")
            print("After NumFlag: \(string)")
            getFlags(string: &string, varC: data)
            print("After GetFlag: \(string)")
            getFlagVs(string: &string, varC: data)
            print("After GetFlagV: \(string)")
        }
        else{
            getDBText(string: &string, varC: data)
            getUserText(string: &string, varC: data)
            getDBText2(string: &string, varC: data)
        }
        return data
    }
    */
    
    /* NFIOEGNWINEWKL:G*/
    
    
    
    
    
    
    
    
    // Initializes comment cells with values loaded from the state controller
    func initCommentCell(cell: CommentViewCell, subSectionIndex: Int, row: Int) {
        var currentComment: Comment!
        var commentText: String = ""
        var commentStatus: Bool = false
        var commentSeverity: Int32 = 0
        
        if let currentComments: [Comment] = currentSubSections[subSectionIndex].comments?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [Comment] {
            currentComment = currentComments[row]
            
            // Check for already initialized result data
            if let currentResult: Result = loadedInspection.results?.first(where: {($0 as! Result).tableLocation == "\(loadedInspection.id),\(currentSectionId!),\(subSectionIndex),\(row)"}) as? Result {
                
                (commentStatus, commentText, commentSeverity) = loadResultData(forResult: currentResult, ofType: "comment")
            } else {
                // Load default data for the comment
                commentText = currentComment.text ?? "No text found for comment"
                commentStatus = false
                commentSeverity = 0
            }
        } else {
            print("Error fetching comment data for cell in subsection: \(subSectionIndex), row: \(row) (- 1)")
        }
        
        // Set comment cell properties
        cell.commentTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        cell.commentTextLabel.attributedText = NSMutableAttributedString(string: commentText, attributes: cell.commentTextAttributes)
        cell.commentStatus.setOn(commentStatus, animated: false)
        
        // Sets the comment addon button states based on the comment's status
        cell.buttonHiddenWidths.priority = commentStatus ? 250 : 900
        cell.commentTextButton.isEnabled = commentStatus
        cell.updateSeverity(severity: commentStatus ? commentSeverity : 0)
        
        // Called when the comment status is toggled (or checked once we switch to checkboxes)
        cell.statusToggleAction = { [weak self] (cell) in
            let isOn = cell.commentStatus.isOn
            let strongSelf = self!
            let indexPath: IndexPath = strongSelf.tableView.indexPath(for: cell)!

            // Check for an already initialized result for cell
            if let cellResult: Result = strongSelf.loadedInspection.results?.first(where: {($0 as! Result).tableLocation == "\(strongSelf.loadedInspection.id),\(strongSelf.currentSectionId!),\(indexPath.section),\(indexPath.row)"}) as? Result {
                
                cellResult.isActive = isOn
                cell.updateSeverity(severity: (isOn ? cellResult.severity : 0))
                                
                strongSelf.safeSaveContext()
                
                print("\(isOn ? "Activating" : "Deactivating") result \(cellResult.tableLocation!)")
            } else {
                let newResult: Result = strongSelf.createResult(ofType: "comment", atLocation: indexPath)
                newResult.comment = currentComment
                cell.updateSeverity(severity: newResult.severity)
                
                strongSelf.safeSaveContext()
                print("New result created with id: \(newResult.id)")
            }
            
            // Show/hide comment addon buttons
            cell.buttonHiddenWidths.priority = isOn ? 250 : 900
            cell.commentTextButton.isEnabled = isOn
        
            // Reload cell to account for text shifting due to presence of buttons
            strongSelf.tableView.reloadRows(at: [indexPath], with: .none)
        }
        
        // Called when the comment text is tapped (to increase severity)
        cell.commentTextButtonTapAction = { [weak self] (commentCell) in
            let indexPath: IndexPath = self!.tableView.indexPath(for: commentCell)!
            if let cellResult: Result = self!.loadedInspection.results?.first(where: {($0 as! Result).tableLocation == "\(self!.loadedInspection.id),\(self!.currentSectionId!),\(indexPath.section),\(indexPath.row)"}) as? Result {

                if let newSeverity: Int32 = self?.changeSeverity(forResult: cellResult) {
                    cellResult.severity = newSeverity
                    cell.updateSeverity(severity: cellResult.severity)
                    print("Comment Tapped, updating severity for result  to \(newSeverity)")
                }
            }
        }
    }
    
    // Loads result data from the state controller and returns it
    func loadResultData(forResult result: Result, ofType resultType: String) -> (Bool, String, Int32) {
        if (resultType == "comment") {
            let commentText = result.comment!.text!
            var fullText = ""
            
            // Set text for comment cell
            if (commentText == "") {
                if let noteText: String = result.note {
                    fullText = noteText
                } else {
                    fullText = "Error, no comment or note text found"
                }
            } else {
                if let noteText: String = result.note {
                    fullText = "\(commentText) \(noteText)"
                } else {
                    fullText = commentText
                }
            }
            
            return (result.isActive, fullText, result.severity)
        }
        else if (resultType == "variant") {
            //TODO:
            return (false, "", 0)
        }
        else {
            print("Cannot load cell result data for type '\(resultType)'")
            return (false, "", 0)
        }
    }
    
    // Loads default data from the state controller and returns it
    func loadDefaultData(forEntity entity: Any, type: String) -> String {
        if (type == "comment") {
            //let currentComment: Comment = entity as! Comment
            return ""
        }
        else if (type == "variant") {
            //TODO:
            return ""
        }
        else {
            print("Cannot load cell default data for type '\(type)'")
            
            return ""
        }
    }
    
    /* End of Cell Initialization Functions */
    
    
    
    // MARK: Notification Center callbacks
    
    func refreshSection(notification: Notification) -> Void {
        print("Refreshing table")
        let newSectionId = notification.object as! Int32
        
        currentSectionId = newSectionId
        
        // Load new section
        if let tempSection: Section = loadedInspectionData.sections?.first(where: {($0 as! Section).id == currentSectionId}) as? Section {
            currentSection = tempSection
            if let subsections: [SubSection] = currentSection.subSections?.sortedArray(using: [NSSortDescriptor(key: "id", ascending: true)]) as? [SubSection] {
                currentSubSections = subsections
            }
        } else {
            print("Cannot find section with id: \(currentSectionId)")
        }
        
        // Reload the table with the new subsections
        tableView.reloadData()
    }
    
    func refreshSubSection(notification: Notification) -> Void {
        print("Refreshing Subsection")
        let changedSubSectionId = notification.object as! Int
        tableView.reloadSections(IndexSet(integer: changedSubSectionId), with: .none)
    }
    
    
    
    // MARK: Helper functions
    
    // Creates, initializes, and returns a new Result depending on the given type
    func createResult(ofType resultType: String, atLocation tableLocation: IndexPath) -> Result {
        let newResult: Result = Result(context: managedObjectContext)

        // Add result to inspection
        newResult.inspection = loadedInspection

        switch (resultType) {
            case "comment":
                newResult.variant = nil
                newResult.isActive = true
                newResult.severity = 1
                newResult.note = nil
                newResult.tableLocation = "\(loadedInspection.id),\(currentSectionId!),\(tableLocation.section),\(tableLocation.row)"
                break
            case "variant":
                //newResult.comment = nil
                //newResult.isActive = true
                //newResult.severity = 0
                break
        default:
            print("Tried to create result of unkown type: \(resultType)")
        }
        
        // Assign and decrement temp result id
        newResult.id = loadedAppValues.tempResultId
        loadedAppValues.tempResultId -= 1
        
        return newResult
    }
    
    // Updates the severity of a result
    func changeSeverity(forResult changedResult: Result) -> Int32 {
        let newSeverity: Int32 = (changedResult.severity % 2) + 1
        
        changedResult.severity = newSeverity
        
        safeSaveContext()
        
        return newSeverity
    }
    
    // Safely save the managed object context
    func safeSaveContext() {
        do {
            try managedObjectContext.save()
        } catch {
            print("Error saving to disk in inspection table VC")
        }
    }
}
