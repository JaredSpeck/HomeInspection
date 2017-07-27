//
//  DashboardTableViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 5/26/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit
import CoreData

class DashboardTableViewController: UITableViewController {
    
    var managedObjectContext: NSManagedObjectContext!
    
    var inspections = [Inspection]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view, typically from a nib.
        managedObjectContext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        loadInspections()
        
        let pcell = UINib(nibName: "DashboardViewCell", bundle: nil)
        tableView.register(pcell, forCellReuseIdentifier: "DashboardViewCell")
    }
    
    // Load locally cached inspections into memory
    func loadInspections() {
        let inspectionFetchRequest: NSFetchRequest<Inspection> = Inspection.fetchRequest()
        
        do {
            inspections = try managedObjectContext.fetch(inspectionFetchRequest)
            print("Inspections loaded from disk")
        } catch {
            print("Could not fetch inspections from disk: \(error.localizedDescription)")
        }
        
        tableView.reloadData()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Set the number of sections in the table (1 section)
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    // Sets number of rows per section (how many cells to make per section)
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int{
        return inspections.count
    }
    
    // Initializes cells with data
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell{
        
        let dashboardCell = tableView.dequeueReusableCell(withIdentifier: "DashboardViewCell", for: indexPath) as! DashboardViewCell
        
        // Dashboard cell properties
        dashboardCell.selectionStyle = .none
        
        // Dashboard cell values
        if let imageData = inspections[indexPath.row].homeImage, let loadedHomeImage = UIImage(data: imageData as Data) {
            // Set thumbnail to saved home image
            dashboardCell.houseImageView.image = loadedHomeImage
        }
        else {
            // Clear thumbnail
            dashboardCell.houseImageView.image = UIImage()
        }
        dashboardCell.dateUILabel.text = "Created:\n\t\(inspections[indexPath.row].date!)"
        dashboardCell.inspectorUILabel.text = "Inspected by:\n\t\(inspections[indexPath.row].id)"
        
        var addressLabel: String = "Address:\n\t"
        if let cellAddress = inspections[indexPath.row].address, let cellStreet: String = cellAddress.street {
            addressLabel.append(cellStreet)
            if let cellCity = cellAddress.city {
                addressLabel.append("\n\t\(cellCity)")
            }
        }
        dashboardCell.addressUILabel.text = addressLabel
        
        return dashboardCell
    }
    
    // Set row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 128
    }
    
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // Delete from CoreData
            deleteInspection(id: inspections[indexPath.row].id)
            // Delete the row from the data source
            inspections.remove(at: indexPath.row)
            // Delete the row from the UI
            tableView.deleteRows(at: [indexPath], with: .fade)
            
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let navController = self.navigationController as? InspectionNavigationController {
            
            // Save context
            safeSaveContext()
            
            navController.inspDetailsVC.loadedInspection = inspections[indexPath.row]
            navController.inspectionVC.loadedInspection = inspections[indexPath.row]
            
            // Show next screen
            navController.pushViewController(navController.inspDetailsVC, animated: true)
            
            // Load updated inspections into table
            loadInspections()
        }
        
    }
    
    private func deleteInspection(id: Int32) {
        let fetch: NSFetchRequest<Inspection> = Inspection.fetchRequest()
        fetch.predicate = NSPredicate.init(format: "id==\(id)")
        
        // Get inspection(s?) that match id
        let result = try? managedObjectContext.fetch(fetch)
        let resultData: [Inspection] = result!
        
        for object in resultData {
            managedObjectContext.delete(object)
        }
        
        print("Writing deletion to disk:")
        safeSaveContext()
    }
    
    // Saves CoreData context (write changes to disk)
    func safeSaveContext() {
        do {
            try self.managedObjectContext.save()
        } catch {
            print("\tError writing to disk: \(error.localizedDescription)")
        }
    }

}
