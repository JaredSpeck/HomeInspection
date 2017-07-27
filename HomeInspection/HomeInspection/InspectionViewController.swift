//
//  InspectionViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/30/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class InspectionViewController: UIViewController {

    
    
    // MARK: Properties    
    
    var managedObjectContext: NSManagedObjectContext!
    var loadedInspectionData: InspectionData!
    var loadedInspection: Inspection!
    var currentSectionId: Int32!
    
    private var inspTableVC: InspectionTableViewController!
    
    @IBOutlet weak var sectionLabel: UILabel!

    
    
    // MARK: Initialization
    
    // Called once when VC is loaded into memory
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Load CoreData context
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // Called every time VC will appear
    override func viewWillAppear(_ animated: Bool) {
        loadInspection()
    }
    
    
    
    // MARK: Helper functions
    
    func loadSection(sectionId newId: Int) {
        if let newSection: Section = loadedInspectionData.sections?.first(where: { ($0 as! Section).id == Int32(newId) }) as? Section {
            print("Loading new section: \(newId)")
            sectionLabel.text = newSection.name
        }
        
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSection"), object: Int32(newId))
    }
    
    func loadInspection() {
        print("Loading inspection: \(loadedInspection.id)")

        // Load inspection data from disk
        let fetchRequest: NSFetchRequest<InspectionData> = InspectionData.fetchRequest()
        do {
            let fetchRequestResults: [InspectionData] = try managedObjectContext.fetch(fetchRequest)
            
            if let tempInspectionData: InspectionData = fetchRequestResults.first {
                loadedInspectionData = tempInspectionData
                inspTableVC.loadedInspectionData = loadedInspectionData
            }
        } catch {
            print("Error fetching inspection data from disk: \(error.localizedDescription)")
        }
        
        // Set references for this and table controller
        inspTableVC.loadedInspection = loadedInspection
        inspTableVC.currentSectionId = currentSectionId
        
        loadSection(sectionId: 1)
    }
    
    // MARK: Misc functions
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedInspectionTableViewController") {
            let tempInspTableVC = segue.destination as! InspectionTableViewController
            self.inspTableVC = tempInspTableVC
        }
        else if (segue.identifier == "embedPaneInInspection") {
            if let paneVC: PaneViewController = segue.destination as? PaneViewController {
                paneVC.showSections = true
            }
        }
    }
}
