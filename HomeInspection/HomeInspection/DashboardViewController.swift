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
    var managedObjectContext: NSManagedObjectContext!
    var inspectionTableVC: DashboardTableViewController!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Get reference to CoreData context
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        initNavBar()
        
    }

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
        
        let editNavButton = UIBarButtonItem(
            title: "Edit",
            style: .plain,
            target: self,
            action: #selector(editInspectionList(sender:)))
        
        //self.navigationItem.leftBarButtonItem = editButtonItem//editNavButton
        self.navigationItem.rightBarButtonItems = [addNavButtton, lookupNavButton]
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // Called when '+' nav button is pressed
    func addNewInspection(sender: UIBarButtonItem) {
        let newInspection = Inspection(context: managedObjectContext)
        newInspection.id = Int32(inspectionTableVC.tableView.numberOfRows(inSection: 0) + Int(1));
        
        if let navController = self.navigationController as? InspectionNavigationController {
            
            // Save context
            safeSaveContext()
            
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
    
    // Get reference to embedded table view controller
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let tableVC =    segue.destination as? DashboardTableViewController,
            segue.identifier == "embedDashboardTableVC" {
            self.inspectionTableVC = tableVC
        }
    }
    
    func safeSaveContext() {
        // Save context
        do {
            try self.managedObjectContext.save()
            print("Saved context successfully")
        } catch {
            print("Error trying to save context: \(error.localizedDescription)")
        }
    }
    
}

