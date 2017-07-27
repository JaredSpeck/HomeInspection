//
//  DashboardViewCell.swift
//  HomeInspection
//
//  Created by Jared Speck on 5/26/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class DashboardViewCell: UITableViewCell {

    @IBOutlet weak var houseImageView: UIImageView!
    @IBOutlet weak var addressUILabel: UILabel!
    @IBOutlet weak var dateUILabel: UILabel!
    @IBOutlet weak var inspectorUILabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
