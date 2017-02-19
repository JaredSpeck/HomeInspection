//
//  SubSectionHeaderViewCell.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/27/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class SubSectionHeaderViewCell: UITableViewCell {

    // MARK - Properties
    @IBOutlet weak var subSectionLabel: UILabel!
    @IBOutlet weak var subSectionStatus: UISwitch!
    @IBOutlet weak var subSectionStatusLabel: UILabel!
    @IBOutlet weak var expandButtonLabel: UILabel!
    @IBAction func expandButtonTap(_ sender: Any) {
        self.expandButtonTapAction?(self)
    }

    var expandButtonTapAction: ((SubSectionHeaderViewCell) -> Void)?
    
    // MARK - Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // Init the cell
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
