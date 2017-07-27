//
//  ViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 12/7/16.
//  Copyright © 2016 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class DashboardViewController: UIViewController {

    
    
    // MARK: Properties
    
    private var cacheInitialized: Bool = false
    private var nextTempId: Int32 = -1
    var managedObjectContext: NSManagedObjectContext!
    var inspectionTableVC: DashboardTableViewController!
    
    
    
    // MARK: Initialization
    
    // One-time initialization
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get reference to CoreData context
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        initNavBar()
    }
    
    // Initialization every time view will come into focus
    override func viewWillAppear(_ animated: Bool) {
        // Get next temp id from disk
        let fetchRequest: NSFetchRequest<AppValues> = AppValues.fetchRequest()
        do {
            let fetchResult: [AppValues] = try managedObjectContext.fetch(fetchRequest)
            if let savedTempId = fetchResult.first?.tempInspectionId {
                nextTempId = savedTempId
            }
        } catch {
            print("Error fetching next temp inspection id from disk: \(error.localizedDescription)")
        }
        inspectionTableVC.tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        if (!cacheInitialized) {
            // Check online for updates to local cache
            initCache()
            cacheInitialized = true
        }
    }
    
    // Set up the navigation bar
    func initNavBar() {
        self.title = "Dashboard"
        
        let addNavButtton = UIBarButtonItem(
            barButtonSystemItem: .add,
            target: self,
            action: #selector(addNewInspection(sender:)))
        
        let lookupNavButton = UIBarButtonItem(
            barButtonSystemItem: .search,
            target: self,
            action: #selector(lookupInspection(sender:)))
        
        self.navigationItem.rightBarButtonItems = [addNavButtton, lookupNavButton]
    }
    
    func initCache() {
        var localInspectionData: InspectionData
        
        // Fetch localInspectionData from cache
        let fetchRequest: NSFetchRequest<InspectionData> = InspectionData.fetchRequest()
        do {
            let fetchRequestResults: [InspectionData] = try managedObjectContext.fetch(fetchRequest)
            if let tempInspectionData: InspectionData = fetchRequestResults.first {
                localInspectionData = tempInspectionData
                print("Loaded inspection data entity from disk")
            } else {
                localInspectionData = InspectionData(context: managedObjectContext)
                try managedObjectContext.save()
                print("Created new inspection data entity")
            }
        } catch {
            print("Error initializing cache (on dashboard)")
        }
        
        // Check for internet connection
        if (NetworkController.isConnectedToNetwork) {
            let statusPopup = UIAlertController(title: "Internet Status", message: "Connected. Updating Cache...", preferredStyle: .alert)
            self.present(statusPopup, animated: true, completion: {
                // Check online for cache update
                //if let (commentModTime, subSectionModTime, sectionModTime) = NetworkController.getModTimes() {
                    // FIXME: Always updates, implement when API call is implemented
                    //if (!validateCache(commentModTime, subSectionModTime, sectionModTime)) {
                        // Times differ, need update
                        //CacheController.cache.refresh()
                    //}
            })
            
            statusPopup.dismiss(animated: true, completion: {
                let completePopup = UIAlertController(title: "Cache Update", message: "Update completed successfully.", preferredStyle: .alert)
                completePopup.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
                self.present(completePopup, animated: true, completion: nil)
            })
            
        } else {
            let statusPopup = UIAlertController(title: "Internet Status", message: "Disconnected", preferredStyle: .alert)
            statusPopup.addAction(UIAlertAction(title: "Dismiss", style: UIAlertActionStyle.cancel, handler: nil))
            self.present(statusPopup, animated: true, completion: nil)
        }
    }
    
    
    // MARK: Helper Functions
    
    // Returns the next temporary inspection id to hold the place until contact is made with the inspection database for a permanent one
    func getNextInspectionId() -> Int32 {
        /* Either query db at creation for id, or assign temp and set id at upload time */
        if (false /*&& Connected to internet */) {
            /* Query database for newinspection Id?*/
        }
        else {
            let returnId = nextTempId
            nextTempId -= 1
            
            // Get next temp id from disk
            let fetchRequest: NSFetchRequest<AppValues> = AppValues.fetchRequest()
            do {
                let fetchResult: [AppValues] = try managedObjectContext.fetch(fetchRequest)
                
                // Write next temp insp id to disk
                if (fetchResult.count == 0) {
                    let newAppValues = AppValues(context: managedObjectContext)
                    newAppValues.tempInspectionId = nextTempId
                    newAppValues.tempResultId = -1
                }
                else {
                    fetchResult.first?.tempInspectionId = nextTempId
                }
                try managedObjectContext.save()
            } catch {
                print("Error writing update for next temporary inspection id to disk: \(error.localizedDescription)")
            }
            return returnId
        }
    }
    
    // Called when '+' nav button is pressed
    func addNewInspection(sender: UIBarButtonItem) {
        let newInspection = Inspection(context: managedObjectContext)
        newInspection.id = getNextInspectionId()
        print("Adding new inspection with id \(newInspection.id)")
        
        // Set date/timestamp for inspection
        let date = Date()
        let formatter = DateFormatter()
        formatter.dateFormat = "hh:mma   MM/dd/yyyy"
        newInspection.date = formatter.string(from: date)
        
        if let navController = self.navigationController as? InspectionNavigationController {
            
            // Save context
            safeSaveContext()
            
            navController.inspDetailsVC.loadedInspection = newInspection
            navController.inspectionVC.loadedInspection = newInspection
            
            // Show next screen
            navController.pushViewController(navController.inspDetailsVC, animated: true)
            
            // Load updated inspections into table
            inspectionTableVC.loadInspections()
        }
    }
    
    // Called when 'search' nav button is pressed
    func lookupInspection(sender: UIBarButtonItem) {
        
    }

    // Called when 'Edit' nav button is pressed
    func editInspectionList(sender: UIBarButtonItem) {
        safeSaveContext()
        self.navigationItem.leftBarButtonItem?.title = inspectionTableVC.tableView.isEditing ? "Edit" : "Done"
        inspectionTableVC.tableView.setEditing(!inspectionTableVC.tableView.isEditing, animated: true)
    }
    
    // Saves the managed object context safely
    func safeSaveContext() {
        // Save context
        do {
            try self.managedObjectContext.save()
        } catch {
            print("Error trying to save context: \(error.localizedDescription)")
        }
    }

    
    
        
    
    
    // MARK: Misc functions
    
    // Called when there is a memory warning
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Get reference to embedded table view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableVC = segue.destination as? DashboardTableViewController,
            segue.identifier == "embedDashboardTableVC" {
            self.inspectionTableVC = tableVC
        }
    }
    
}

