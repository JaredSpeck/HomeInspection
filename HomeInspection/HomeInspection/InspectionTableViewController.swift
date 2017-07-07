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
    
    let BASE_NUM_COMMENTS = 3
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
        //let currentSection = StateController.state.sections[sectionId!]
        return 3//currentSection.subSections!.count
    }

    // REQUIRED: Set the number of rows per section 
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // Number of cells = number of variant cells + number of comments + 1 for subsection header - 1 for blank comment
        let state = StateController.state
        let currentSection = state.sections[sectionId!]
        //let currentSubSectionsArray = Array(currentSection.subSections!)
        let currentSubSection = state.subsections[0]//FIXME: state.subsections[currentSubSectionsArray[Int(section)]]!
        
        let subSectionVariantCount = currentSubSection.variants?.count
        let subSectionCommentCount = currentSubSection.comments?.count
        let expandedNumCells = subSectionVariantCount! + subSectionCommentCount!
        var numCommentsShown = 1 + BASE_NUM_COMMENTS + subSectionVariantCount! - 1
        
        if (currentSubSection.isExpanded || expandedNumCells < numCommentsShown) {
            numCommentsShown = expandedNumCells
        }
        
        return numCommentsShown
    }

    // REQUIRED: Initialize/Reuse table cells based on identifier
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let subSectionIndex = indexPath.section
        let variantCellCount = StateController.state.subsections[subSectionIndex + 1].variants?.count
        
        var identifier: String
        
        // Set identifier based off of row location
        if (indexPath.row == 0) {
            identifier = "SubSectionHeaderViewCell"
        }
        else if (indexPath.row > 0 && indexPath.row <= variantCellCount!) {
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
        let currentSubSection = state.subsections[subSectionIndex + 1]
        
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
    
    // Initialize variant cells with values loaded from state controller
    func initVariantCell(cell: VariantViewCell, subSectionIndex: Int, row: Int) {
        //let state = StateController.state
    }
    
    // Initializes comment cells with values loaded from the state controller
    func initCommentCell(cell: CommentViewCell, subSectionIndex: Int, row: Int) {
        let state = StateController.state
        var commentText: String
        var commentStatus: Bool
        var commentSeverity: Int
        
        // Translates the cells location into a comment id
        let commentId = state.getCommentId(sectionId: sectionId!, subSectionIndex: subSectionIndex, rowNum: row)!
        let resultId: Int32? = state.comments[commentId].result?.id
        
        
        if (resultId != nil) {
            // Load data from result entry in State controller
            (commentStatus, commentText, commentSeverity) = loadResultData(resultId: Int(resultId!), type: "comment")
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
        cell.statusToggleAction = { [weak self] (cell) in
            let isOn = cell.commentStatus.isOn
            let resultId = StateController.state.comments[cell.commentId!].result?.id
            if let strongSelf = self {
                let indexPath = strongSelf.tableView.indexPath(for: cell)
            
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
                    StateController.state.userRemovedResult(resultId: Int(resultId!))
                    cell.resultId = nil
                }
            
                // Show/hide comment addon buttons
                cell.buttonHiddenWidths.priority = isOn ? 250 : 900
                cell.commentTextButton.isEnabled = isOn
            
                // Reload cell to account for text shifting due to presence of buttons
                strongSelf.tableView.reloadRows(at: [indexPath!], with: .none)
            }
        }
        
        // Called when the comment text is tapped (to increase severity)
        cell.commentTextButtonTapAction = { (commentCell) in
            let commentId = commentCell.commentId!
            let comment = StateController.state.comments[commentId]
            let newSeverity = StateController.state.userChangedSeverity(resultId: Int(comment.result!.id))
            print("Comment Tapped, updating severity for result \(comment.result!.id) to \(newSeverity)")
            commentCell.updateSeverity(severity: newSeverity)
        }
    }
    
    // Loads result data from the state controller and returns it
    func loadResultData(resultId: Int, type: String) -> (Bool, String, Int) {
        if (type == "comment") {
            let result = StateController.state.results[resultId]
            let resultSeverity = result.severity
            let commentText = "Broken result load"//FIXME: StateController.state.comments[result.comment!.id]!.commentText
            let noteText = result.note
            var fullText = ""
            
            if (commentText == "") {
                fullText = noteText!
            }
            else {
                fullText = commentText + " " + noteText!
            }
            
            return (true, fullText, Int(resultSeverity))
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
            return StateController.state.comments[commentId].text!
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
        self.tableView.reloadSections(IndexSet(integer: changedSubSectionId - 1), with: .none)
   
    }
    
    /* End of Notification Center Callback Functions */
    

}
