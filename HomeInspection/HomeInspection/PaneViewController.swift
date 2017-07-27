//
//  PaneViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 12/7/16.
//  Copyright © 2016 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class PaneViewController: UIViewController {

    // MARK: Properties
    //var parentInpectionViewController: InspectionViewController!
    var showSections: Bool = true
    var managedObjectContext: NSManagedObjectContext!
    var loadedInspectionData: InspectionData!
    var paneTableVC: PaneTableViewController!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext

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

    override func viewWillAppear(_ animated: Bool) {
        paneTableVC.numSections = showSections ? loadedInspectionData.sections!.count : 0
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    @IBAction func inspDetailsButtonTapAction(_ sender: Any) {
        if let navController = navigationController as? InspectionNavigationController {
            if (navController.topViewController != navController.inspDetailsVC) {
                navController.popViewController(animated: false)
                navController.pushViewController(navController.inspDetailsVC, animated: false)
            }
        }
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedTableInPaneView") {
            paneTableVC = segue.destination as! PaneTableViewController
        }
    }
    
}
