//
//  InspectionViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/30/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class InspectionViewController: UIViewController {

    
    
    // Properties
    weak var previousController: UIViewController!
    
    var sectionId: Int! = 1
    @IBOutlet weak var sectionLabel: UILabel!
    
    
    
    func loadSection(sectionId: Int) {
        let newSection = StateController.state.sections[sectionId]
        sectionLabel.text = newSection.name
        
        // ADD CODE TO LOAD SECTION/SUBSECTION/COMMENTS
        NotificationCenter.default.post(name: Notification.Name(rawValue: "refreshSection"), object: sectionId)
    }
    
    // Other Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        if (StateController.state.sections.count > sectionId) {
            sectionLabel.text = StateController.state.sections[sectionId].name
        }
        else {
            sectionLabel.text = "Error Loading data"
        }
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "embedInspectionTableViewController") {
                let inspTableVC = segue.destination as! InspectionTableViewController
                inspTableVC.sectionId = self.sectionId
                print("Passing sectionId: \(self.sectionId!) to Inspection Table")
        }
        else if (segue.identifier == "embedPaneViewControllerInInspectionView") {
                let paneVC = segue.destination as! PaneViewController
                paneVC.parentInpectionViewController = self
                print("Passing InspectionVC reference to embedded PaneVC")
        }
        else if (segue.identifier == "inspToDashboard") {
            // FIXME: Call an unwind segue for this
                self.dismiss(animated: false, completion: {})
                previousController.dismiss(animated: true, completion: {})
        }
    }
}
