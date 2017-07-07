//
//  InspInfoViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/11/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class InspDetailsViewController: UIViewController {
    
    // Properties
    var resultsDelegate: StateController? = nil
    

    
    // Called when the view loads
    override func viewDidLoad() {
        super.viewDidLoad()

        initNavBar()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Called before running a segue
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedPaneInInspDetailsView") {
            let paneVC = segue.destination as! PaneViewController
            
            paneVC.isInspectionLoaded = false;
            
        }
     }
    
    // Initializes the navigation bar with buttons and text
    func initNavBar() {
        self.title = "Inspection Setup"
        
        let startNavButton = UIBarButtonItem(
            title: "Start",
            style: .plain,
            target: self,
            action: #selector(showInspection(sender:)))
        
        self.navigationItem.rightBarButtonItem = startNavButton
    }
    
    // Called when the 'Start' nav button is pressed
    func showInspection(sender: UIBarButtonItem) {
        print("Starting Inspection")
        
        if let navController = self.navigationController as? InspectionNavigationController {
            
            /* Save managed object context
             do {
                try
            } catch {
 
            }
            */
            
            navController.popViewController(animated: false)
            navController.pushViewController(navController.inspectionVC, animated: false)
        }
    }
}

