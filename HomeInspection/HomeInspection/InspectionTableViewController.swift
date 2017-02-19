//
//  SubSectionTableViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit



protocol ResultDataDelegate {
    func userAddedResult(commentId: Int) -> Int
    func userRemovedResult(resultId: Int) -> Int
    func userChangedSeverity(resultId: Int) -> Int8
    func userChangedNote(resultId: Int, note: String) -> String
    func userChangedPhoto(resultId: Int, photoPath: String) -> String
    func userChangedFlags(resultId: Int, flagNums: [Int8]) -> [Int8]
}



class InspectionTableViewController: UITableViewController {

    
    /* Properties */
    
    let BASE_NUM_COMMENTS = 4
    
    var sectionId: Int!
    var subSections = [SubSection]()
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
        
        let ccell = UINib(nibName: "CommentViewCell", bundle: nil)
        tableView.register(ccell, forCellReuseIdentifier: "CommentViewCell")
    }

    // Function called when too much memory has been used
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // REQUIRED: Set the number of sections in the table (= number of subsections for the chosen section)
    override func numberOfSections(in tableView: UITableView) -> Int {
        // Return the number of sections (subsections in a given section)
        return StateController.state.sections[sectionId!].subSectionIds.count
    }

    // REQUIRED: Set the number of rows per section (Comments in a subsection + 1 for the subsection header)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of cells = number of comments + 1 (for the subsection header)
        var numCommentsShown = 1 + BASE_NUM_COMMENTS
        
        let state = StateController.state
        let currentSection = state.sections[sectionId!]
        let currentSubSection = state.subsections[currentSection.subSectionIds[section]]
        let expandedNumCells = 1 + currentSubSection.commentIds.count
        
        if (state.subsections[section].isExpanded ||
            expandedNumCells < numCommentsShown) {
            
            numCommentsShown = expandedNumCells
        }
        
        return numCommentsShown
    }

    // REQUIRED: Initialize/Reuse table cells based on identifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        var identifier: String
        
        // Set identifier based off row (0 is subsection header, all others are comments)
        if (indexPath.row == 0) {
            identifier = "SubSectionHeaderViewCell"
        }
        else {
            identifier = "CommentViewCell"
        }
        
        // Dequeue a reusable cell based off of identifier
        let cell = self.tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as UITableViewCell
        
        // Remove selection highlighting
        cell.selectionStyle = UITableViewCellSelectionStyle.none
        
        // Reuse old cell
        numReuses += 1
        //debugPrint("Reused \(numReuses) Cells")
        
        // Initialize the cell based off of identifier
        if (identifier == "SubSectionHeaderViewCell") {
            // Downcast cell as subsection header cell
            let subSectionCell = cell as! SubSectionHeaderViewCell
            
            // Initialize subsection cell values
            initSubSectionCell(cell: subSectionCell, subSection: indexPath.section)
            
            return subSectionCell
        }
        else {
            // Downcast cell as comment cell
            let commentCell = cell as! CommentViewCell
            
            // Initialize comment cell values
            initCommentCell(cell: commentCell, section: indexPath.section, row: indexPath.row)
            
            return commentCell
        }
    }
    
    // Sets the heights for the cells based off row (0 is subsection header, all others are comments)
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        if (indexPath.row == 0) {
            return 64
        }
        else {
            // Min comment row size = 48. Any lower and the switches start to align weirdly and get hard to hit.
            return 48
        }
    }
    
    /* End of Table Initialization Functions */
    
    
    
    /* Cell Initialization Functions */
    
    // Initializes subsection cells with values loaded from the state controller
    func initSubSectionCell(cell: SubSectionHeaderViewCell, subSection: Int) {
        let state = StateController.state
        
        // Set cell text
        let subSectionText = state.getSubSectionText(sectionIndex: sectionId, subSectionNum: subSection)
        cell.subSectionLabel.text = subSectionText
        cell.subSectionStatusLabel.text = "All clear for \(subSectionText)"
        cell.expandButtonLabel.text = (state.subsections[subSection].isExpanded ? "-" : "+")
        
        // Set expand button function
        cell.expandButtonTapAction = { (cell) in
            let isExpanded = state.subsections[subSection].isExpanded
            //print("Setting subsection \(subSection) expansion to \(!isExpanded)")
            state.subsections[subSection].isExpanded = !isExpanded
            NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSubSection"), object: subSection)
        }
        
    }
    
    // Initializes comment cells with values loaded from the state controller
    func initCommentCell(cell: CommentViewCell, section: Int, row: Int) {
        let state = StateController.state
        var commentText: String
        
        // Translates the cells location into a comment id
        cell.commentId = state.getCommentId(sectionNum: sectionId!, subSectionNum: section, rowNum: row)!

        // Gets the status of the comment with id commentId from the comment table
        //cell.commentStatus.setOn(state.getCommentState(commentId: Int(cell.commentId!)), animated: false)
        
        // Sets the comment addon button states based on the comment's status
        cell.buttonHiddenWidths.priority = cell.commentStatus.isOn ? 250 : 900
        cell.commentTextButton.isEnabled = cell.commentStatus.isOn
        
        // Sets the cell to display text on more than one line
        cell.commentTextButton.titleLabel?.lineBreakMode = NSLineBreakMode.byWordWrapping
        
        // NOT ALL COMMENTS ARE IMPLEMENTED YET, IF NOT IMPLEMENTED, USING 'ERROR' FOR NOW
        // Gets the plain comment text from the state controller
        if (cell.commentId == -1) {
            commentText = "ERROR"
        }
        else {
            commentText = state.getCommentText(commentId: cell.commentId!)
        }
        
        // Sets the comment text
        cell.commentTextButton.setAttributedTitle(NSMutableAttributedString(string: commentText, attributes: cell.commentTextAttributes), for: .normal)
        
        // Called when the comment status is toggled (or checked once we switch to checkboxes)
        cell.statusToggleAction = { (cell) in
            let isOn = cell.commentStatus.isOn
            
            // Adding a newly checked comment to the result array
            if (cell.resultId == nil && isOn) {
                // Need to assign a comment id to the cell first...
                cell.resultId = StateController.state.userAddedResult(commentId: cell.commentId!)
                cell.updateSeverity(severity: 2)
                print("New comment found. Added an entry at index \(cell.resultId!) in the Results Array")
            }
            else if (!isOn) {
                cell.updateSeverity(severity: 0)
                StateController.state.userRemovedResult(resultId: cell.resultId!)
                cell.resultId = nil
            }
            
            // Show/hide comment addon buttons
            cell.buttonHiddenWidths.priority = isOn ? 250 : 900
            cell.commentTextButton.isEnabled = isOn
        }
        
        // Called when the comment text is tapped (to increase severity)
        cell.commentTextButtonTapAction = { (commentCell) in
            let newSeverity = (StateController.state.userChangedSeverity(resultId: commentCell.resultId!))
            print("Comment Tapped, updating severity for result \(commentCell.resultId!) to \(newSeverity)")
            commentCell.updateSeverity(severity: newSeverity)
        }
    }
    
    /* End of Cell Initialization Functions */
    
    
    
    /* Helper Functions */
    
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
        
        self.tableView.reloadSections(IndexSet(integer: changedSubSectionId), with: .automatic)
   
    }
    
    /* End of Helper Functions */
    

}
