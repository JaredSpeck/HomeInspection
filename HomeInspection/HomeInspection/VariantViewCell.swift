//
//  TableViewCell.swift
//  variant cell
//
//  Created by Christian Coelho on 2/25/17.
//  Copyright © 2017 Christian Coelho. All rights reserved.
//

import UIKit

class VariantViewCell: UITableViewCell {
    
    
    var numFlag = 0
    var type = 0
    
    var _dbText: String?
    var _flag1: String?
    var _flag2: String?
    var _flag3: String?
    var _flag4: String?
    var _flag5: String?
    var _flag6: String?
    var _flag7: String?
    var _flag8: String?
    var _flagV1 = 0
    var _flagV2 = 0
    var _flagV3 = 0
    var _flagV4 = 0
    var _flagV5 = 0
    var _flagV6 = 0
    var _flagV7 = 0
    var _flagV8 = 0
    var _userText: String?
    var _dbText2: String?
    
    
    var radioConstraints = [NSLayoutConstraint]()
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var flag1TextField: UITextField!
    @IBOutlet weak var flag1Switch: UISwitch!
    @IBOutlet weak var flag2TextField: UITextField!
    @IBOutlet weak var flag2Switch: UISwitch!
    @IBOutlet weak var flag3TextField: UITextField!
    @IBOutlet weak var flag3Switch: UISwitch!
    @IBOutlet weak var flag4TextField: UITextField!
    @IBOutlet weak var flag4Switch: UISwitch!
    @IBOutlet weak var flag5TextField: UITextField!
    @IBOutlet weak var flag5Switch: UISwitch!
    @IBOutlet weak var flag6TextField: UITextField!
    @IBOutlet weak var flag6Switch: UISwitch!
    @IBOutlet weak var flag7TextField: UITextField!
    @IBOutlet weak var flag7Switch: UISwitch!
    @IBOutlet weak var flag8TextField: UITextField!
    @IBOutlet weak var flag8Switch: UISwitch!
    
    @IBOutlet weak var labelTextField: UITextField!
    @IBOutlet weak var valueTextField: UITextField!
    @IBOutlet weak var extraTextField: UITextField!
    
    // FIXME: Add second variable priority equal widths field for the switches that are showing
    
    // Constraint outlets
    @IBOutlet weak var showTextField: NSLayoutConstraint!
    @IBOutlet weak var showBtnA: NSLayoutConstraint!
    @IBOutlet weak var showBtnB: NSLayoutConstraint!
    @IBOutlet weak var showBtnC: NSLayoutConstraint!
    @IBOutlet weak var showBtnD: NSLayoutConstraint!
    @IBOutlet weak var showBtnE: NSLayoutConstraint!
    @IBOutlet weak var showBtnF: NSLayoutConstraint!
    @IBOutlet weak var showBtnG: NSLayoutConstraint!
    @IBOutlet weak var showBtnH: NSLayoutConstraint!
    @IBOutlet weak var showRadioField: NSLayoutConstraint!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        radioConstraints.append(showBtnA)
        radioConstraints.append(showBtnB)
        radioConstraints.append(showBtnC)
        radioConstraints.append(showBtnD)
        radioConstraints.append(showBtnE)
        radioConstraints.append(showBtnF)
        radioConstraints.append(showBtnG)
        radioConstraints.append(showBtnH)
        
        
        //text
    }

    func updateRadioPriorities(numButtons: Int) {
        for i in 0..<numButtons {
            print("Showing flag \(i)")
            radioConstraints[i].priority = 900
        }
        for j in numButtons..<radioConstraints.count {
            print("Hiding flag \(j)")
            radioConstraints[j].priority = 250
        }
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}


