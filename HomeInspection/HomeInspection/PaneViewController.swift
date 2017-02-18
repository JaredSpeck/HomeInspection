//
//  PaneViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 12/7/16.
//  Copyright © 2016 Jared Speck. All rights reserved.
//

import UIKit

class PaneViewController: UIViewController {

    var parentInpectionViewController: InspectionViewController!
    var isInspectionLoaded: Bool = true
        
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation0

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if (segue.identifier == "embedTableInPaneView") {
            let paneTableVC = segue.destination as! PaneTableViewController
            paneTableVC.inspectionVC = self.parentInpectionViewController
            paneTableVC.numSections = isInspectionLoaded ? StateController.state.sections.count : 0
            print("Passing InspectionVC reference to embedded PaneTableVC")
        }
    }
    
}
