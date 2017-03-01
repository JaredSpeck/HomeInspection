//
//  SubSectionTableViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class InspectionTableViewController: UITableViewController {

    
    
    /* Properties */
    
    let BASE_NUM_COMMENTS = 5
    var sectionId: Int!
    var numReuses = 0
    
    /* End of Properties */
    
    
    
    /* Table Initialization Functions */
    
    // Function called on loading the table view
    override func viewDidLoad() {
        super.viewDidLoad()
        
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

    // Function called when too much memory has been used
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // REQUIRED: Set the number of sections in the table (= number of subsections for the chosen section)
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections (subsections in a given section)
        let currentSection = StateController.state.sections[sectionId!]!
        return currentSection.subSectionIds.count
    }

    // REQUIRED: Set the number of rows per section 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of cells = number of variant cells + number of comments + 1 for subsection header - 1 for blank comment
        let state = StateController.state
        let currentSection = state.sections[sectionId!]!
        let currentSubSection = state.subsections[currentSection.subSectionIds[section]]!
        
        let subSectionVariantCount = currentSubSection.variantIds.count
        let subSectionCommentCount = currentSubSection.commentIds.count
        let expandedNumCells = subSectionVariantCount + subSectionCommentCount
        var numCommentsShown = 1 + BASE_NUM_COMMENTS + subSectionVariantCount - 1
        
        if (currentSubSection.isExpanded || expandedNumCells < numCommentsShown) {
            numCommentsShown = expandedNumCells
        }
        
        return numCommentsShown
    }
    
    // REQUIRED: Initialize/Reuse table cells based on identifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let subSectionIndex = indexPath.section
        let variantCellCount = StateController.state.subsections[subSectionIndex + 1]!.variantIds.count
        
        var identifier: String
        
        // Set identifier based off of row location
        if (indexPath.row == 0) {
            identifier = "SubSectionHeaderViewCell"
        }
        else if (indexPath.row > 0 && indexPath.row <= variantCellCount) {
            identifier = "VariantViewCell"
        }
        else {
            identifier = "CommentViewCell"
        }
        
        // Dequeue a reusable cell based off of identifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
        
        // Remove selection highlighting
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Reuse old cell (used for debugging only)
        numReuses += 1
        
        // Initialize cell based off of identifier
        switch (identifier) {
        case "SubSectionHeaderViewCell":
            let subSectionCell = cell as! SubSectionHeaderViewCell
            initSubSectionCell(cell: subSectionCell, subSectionIndex: subSectionIndex)
            return subSectionCell
            
        case "VariantViewCell":
            let variantCell = cell as! VariantViewCell
            initVariantCell(cell: variantCell, subSectionIndex: subSectionIndex, row: indexPath.row)
            return variantCell
            
        case "CommentViewCell":
            let commentCell = cell as! CommentViewCell
            initCommentCell(cell: commentCell, subSectionIndex: subSectionIndex, row: indexPath.row + 1)
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
        let state = StateController.state
        let currentSubSection = state.subsections[subSectionIndex + 1]!
        
        // Set cell text
        let subSectionText = state.getSubSectionText(sectionId: sectionId, subSectionIndex: subSectionIndex)
        cell.subSectionLabel.text = subSectionText
        cell.subSectionStatusLabel.text = "All clear for \(subSectionText)"
        cell.expandButtonLabel.text = (currentSubSection.isExpanded ? "-" : "+")
        
        // Set expand button function
        cell.expandButtonTapAction = { (cell) in
            let isExpanded = currentSubSection.isExpanded
            //print("Setting subsection \(subSection) expansion to \(!isExpanded)")
            currentSubSection.isExpanded = !isExpanded
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSubSection"), object: subSectionIndex + 1)
        }
        
    }
    
    // Initialize a type cell with values loaded from state controller
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
        let state = StateController.state
        var commentText: String
        var commentStatus: Bool
        var commentSeverity: Int
        
        // Translates the cells location into a comment id
        let commentId = state.getCommentId(sectionId: sectionId!, subSectionIndex: subSectionIndex, rowNum: row)!
        let resultId: Int? = state.comments[commentId]!.resultId
        
        
        if (resultId != nil) {
            // Load data from result entry in State controller
            (commentStatus, commentText, commentSeverity) = loadResultData(resultId: resultId!, type: "comment")
        }
        else {
            // Load default cell data
            commentText = loadDefaultData(commentId: commentId, type: "comment") //TODO
            commentStatus = false
            commentSeverity = 0
        }
        
        // Set cell properties
        cell.commentId = commentId
        cell.commentStatus.setOn(commentStatus, animated: false)
        cell.updateSeverity(severity: commentSeverity)
        
        // Sets the comment addon button states based on the comment's status
        cell.buttonHiddenWidths.priority = commentStatus ? 250 : 900
        cell.commentTextButton.isEnabled = commentStatus
        
        // Sets the cell to display text on more than one line
        cell.commentTextLabel.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // Sets the comment text
        cell.commentTextLabel.attributedText = NSMutableAttributedString(string: commentText, attributes: cell.commentTextAttributes)
        
        // Called when the comment status is toggled (or checked once we switch to checkboxes)
        cell.statusToggleAction = { (cell) in
            let isOn = cell.commentStatus.isOn
            let resultId = StateController.state.comments[cell.commentId!]!.resultId
            let indexPath = self.tableView.indexPath(for: cell)
            
            // Adding a newly checked comment to the result array
            if (resultId == nil && isOn) {
                // Need to assign a comment id to the cell first...
                cell.resultId = StateController.state.userAddedResult(commentId: cell.commentId!)
                let severity = StateController.state.userChangedSeverity(resultId: cell.resultId!)
                cell.updateSeverity(severity: severity)
                print("New comment found. Added an entry at index \(cell.resultId!) in the Results Array")
            }
            else if (!isOn) {
                cell.updateSeverity(severity: 0)
                StateController.state.userRemovedResult(resultId: resultId!)
                cell.resultId = nil
            }
            
            // Show/hide comment addon buttons
            cell.buttonHiddenWidths.priority = isOn ? 250 : 900
            cell.commentTextButton.isEnabled = isOn
            
            // Reload cell to account for text shifting due to presence of buttons
            self.tableView.reloadRows(at: [indexPath!], with: .none)
        }
        
        // Called when the comment text is tapped (to increase severity)
        cell.commentTextButtonTapAction = { (commentCell) in
            let commentId = commentCell.commentId!
            let comment = StateController.state.comments[commentId]!
            let newSeverity = StateController.state.userChangedSeverity(resultId: comment.resultId!)
            print("Comment Tapped, updating severity for result \(comment.resultId!) to \(newSeverity)")
            commentCell.updateSeverity(severity: newSeverity)
        }
    }
    
    // Loads result data from the state controller and returns it
    func loadResultData(resultId: Int, type: String) -> (Bool, String, Int) {
        if (type == "comment") {
            let result = StateController.state.results[resultId]!
            let resultSeverity = result.severity
            let commentText = StateController.state.comments[result.commentId!]!.commentText
            let noteText = result.note
            var fullText = ""
            
            if (commentText == "") {
                fullText = noteText
            }
            else {
                fullText = commentText! + " " + noteText
            }
            
            return (true, fullText, resultSeverity)
        }
        else if (type == "variant") {
            //TODO:
            return (false, "", 0)
        }
        else {
            print("Cannot load cell result data for type '\(type)'")
            
            return (false, "", 0)
        }
    }
    
    // Loads default data from the state controller and returns it
    func loadDefaultData(commentId: Int, type: String) -> String {
        if (type == "comment") {
            return StateController.state.comments[commentId]!.commentText!
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
    
    
    
    /* Notification Center Callback Functions */
    
    func refreshSection(notification: Notification) -> Void {
        print("Refreshing table")
        let newSectionId = notification.object as! Int
        self.sectionId = newSectionId
        self.tableView.reloadData()
    }
    
    func refreshSubSection(notification: Notification) -> Void {
        print("Refreshing Subsection")
        
        let changedSubSectionId = notification.object as! Int
        /* Attempt at only inserting/deleting after the base cells
        let changedSubSectionCell = notification.object as! SubSectionHeaderViewCell
        let indexPath = self.tableView.indexPath(for: changedSubSectionCell)!
        let baseCellOffset = 1 + BASE_NUM_COMMENTS
        let numTotalCells = StateController.state.subsections[indexPath.section].commentIds.count
        
        var expandedCellIndexPaths = [IndexPath]()
        
        for cellIndex in baseCellOffset..<(numTotalCells - 1) {
            expandedCellIndexPaths.append(IndexPath(row: cellIndex, section: indexPath.section))
        }
        
        print("subsection \(indexPath.section) expanded? \(StateController.state.subsections[indexPath.section].isExpanded)")
        
        // isExpanded has already been toggled, refreshing section to show the change
        if (StateController.state.subsections[indexPath.section].isExpanded) {
            self.tableView.insertRows(at: expandedCellIndexPaths, with: .fade)
        }
        else {
            self.tableView.deleteRows(at: expandedCellIndexPaths, with: .fade)
        }
        */
        
        self.tableView.reloadSections(IndexSet(integer: changedSubSectionId - 1), with: .none)
   
    }
    
    /* End of Notification Center Callback Functions */
    

}
