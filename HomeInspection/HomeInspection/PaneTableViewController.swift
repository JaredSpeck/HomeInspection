//
//  PaneTableViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/12/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class PaneTableViewController: UITableViewController {
    
    
    
    // MARK: Properties
    
    var numSections: Int = 0
    var managedObjectContext: NSManagedObjectContext!
    var loadedInspectionData: InspectionData!
    
    
    
    // MARK: Initialization
    
    // Called once when first loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let pcell = UINib(nibName: "PaneViewCell", bundle: nil)
        tableView.register(pcell, forCellReuseIdentifier: "PaneViewCell")
        
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 64
    }
    
    // Called whenever the view will appear
    override func viewWillAppear(_ animated: Bool) {
        let fetchRequest: NSFetchRequest<InspectionData> = InspectionData.fetchRequest()
        do {
            let fetchRequestResults: [InspectionData] = try managedObjectContext.fetch(fetchRequest)
            if let tempInspectionData: InspectionData = fetchRequestResults.first {
                loadedInspectionData = tempInspectionData
            }
        } catch {
            print("Error fetching inspection data in PaneVC")
        }
    }
    
    // Set number of rows to show per section in table
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
       return numSections
    }

    // Individual table cell setup
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        // Get reference to inspectionVC to reload data if pane cell is tapped
        var inspectionVC: InspectionViewController?
        if let navController: InspectionNavigationController = navigationController as? InspectionNavigationController {
            inspectionVC = navController.inspectionVC
        }
        
        // Get reference to current section
        var currentSection: Section?
        if let tempSection: Section = loadedInspectionData.sections?.first(where: {($0 as! Section).id == Int32(indexPath.row + 1)}) as? Section {
            currentSection = tempSection
        }
        
        // Get reference to pane cell to edit
        let paneCell = tableView.dequeueReusableCell(withIdentifier: "PaneViewCell", for: indexPath) as! PaneViewCell
        
        // Set up pane cell
        paneCell.selectionStyle = UITableViewCellSelectionStyle.none
        paneCell.sectionId = indexPath.row + 1
        paneCell.sectionLabel.text = currentSection?.name
        paneCell.sectionButtonTapAction = { [weak inspectionVC] (cell: PaneViewCell) in
            inspectionVC!.loadSection(sectionId: cell.sectionId)
        }
                
        return paneCell
    }
    

    
    // MARK: Misc Functions

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
