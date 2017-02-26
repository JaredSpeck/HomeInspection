//
//  InspInfoViewController.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/11/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class InspDetailsViewController: UIViewController {
    
    @IBOutlet weak var outerInfoStackView: UIStackView!
    @IBOutlet weak var innerInfoFirstStackView: UIStackView!
    
    
    // Other Functions
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Adjust layout for different orientation
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        coordinator.animate(alongsideTransition: { (context) -> Void in
            print("Chnaged rotation")
            let orientation = UIApplication.shared.statusBarOrientation
            
            if orientation.isPortrait {
                self.outerInfoStackView.axis = .vertical
                self.innerInfoFirstStackView.axis = .horizontal
                //self.stackView.axis = .Horizontal
            } else {
                self.outerInfoStackView.axis = .horizontal
                self.innerInfoFirstStackView.axis = .vertical
                //self.stackView.axis = .Vertical
            }
            
        }, completion: nil)    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "embedPaneInInspDetailsView") {
            let paneVC = segue.destination as! PaneViewController
            
            paneVC.isInspectionLoaded = false;
            
        }
    }
    
}

