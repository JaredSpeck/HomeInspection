//
//  PaneTableViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class PaneTableViewController: UITableViewController {
    
    // Reference to Inspection View Controller allowing for connection between this and it
    var inspectionVC: InspectionViewController!
    
    var numSections: Int = 0
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
      
       return numSections
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let paneCell = tableView.dequeueReusableCell(withIdentifier: "PaneViewCell", for: indexPath) as! PaneViewCell
        
        
        // Remove selection highlighting
        paneCell.selectionStyle = UITableViewCellSelectionStyle.none
        paneCell.sectionId = indexPath.row + 1
        
        print("Section cell created for sectionId \(indexPath.row + 1)")
        
        paneCell.sectionLabel.text = StateController.state.sections[paneCell.sectionId - 1].name
        
        paneCell.sectionButtonTapAction = { (cell) in
            self.inspectionVC!.loadSection(sectionId: paneCell.sectionId!)
        }
        
        return paneCell
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let pcell = UINib(nibName: "PaneViewCell", bundle: nil)
        tableView.register(pcell, forCellReuseIdentifier: "PaneViewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }



}
