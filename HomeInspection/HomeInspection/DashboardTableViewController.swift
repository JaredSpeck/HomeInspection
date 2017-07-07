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
            print("inspctions loaded")
        } catch {
            print("Could not fetch inspections from device cache: \(error.localizedDescription)")
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
        
        return dashboardCell
    }
    
    // Set row height
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 112
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
    
    private func deleteInspection(id: Int32) {
        let fetch: NSFetchRequest<Inspection> = Inspection.fetchRequest()
        fetch.predicate = NSPredicate.init(format: "id==\(id)")
        
        // Get inspection(s?) that match id
        let result = try? managedObjectContext.fetch(fetch)
        let resultData: [Inspection] = result!
        
        for object in resultData {
            managedObjectContext.delete(object)
        }
        
        do {
            try managedObjectContext.save()
            print("Saved deletion")
        } catch let error as NSError {
            print("Could not save \(error), \(error.userInfo)")
        } catch {
            
        }
    }

}
