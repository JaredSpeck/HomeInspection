//
//  InspectionNavigationController.swift
//  HomeInspection
//
//  Created by Jared Speck on 6/29/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class InspectionNavigationController: UINavigationController {

    var sb: UIStoryboard!
    var dashboardVC: DashboardViewController!
    var inspDetailsVC: InspDetailsViewController!
    var inspectionVC: InspectionViewController!
    
    /*
    override init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }*/
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        sb = UIStoryboard(name: "Main", bundle: nil)
        dashboardVC = sb.instantiateViewController(withIdentifier: "DashboardVC") as! DashboardViewController
        inspDetailsVC = sb.instantiateViewController(withIdentifier: "InspDetailsVC") as! InspDetailsViewController
        inspectionVC = sb.instantiateViewController(withIdentifier: "InspectionVC") as! InspectionViewController
        
        self.pushViewController(dashboardVC, animated: false)
        
    
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    
    
    // MARK: - Navigation
    
    /*
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
