//
//  CommentViewCell.swift
//  HomeInspection
//
//  Created by Jared Speck on 1/27/17.
//  Copyright © 2017 Jared Speck. All rights reserved.
//

import UIKit

class CommentViewCell: UITableViewCell {

    
    // Properties
    var commentId: Int? = nil
    var resultId: Int? = nil
    var commentTextAttributes: [String : Any] = [
        NSFontAttributeName : UIFont.systemFont(ofSize: 16.0),
        NSForegroundColorAttributeName : UIColor.lightText,
        NSUnderlineStyleAttributeName : 0]
    
    @IBOutlet weak var commentStatus: UISwitch!
    @IBOutlet weak var commentTextLabel: UILabel!
    @IBOutlet weak var commentTextButton: UIButton!
    @IBOutlet weak var commentNotesButton: UIButton!
    @IBOutlet weak var commentFlagsButton: UIButton!
    @IBOutlet weak var commentPhotoButton: UIButton!
    
    @IBAction func statusToggle(_ sender: Any) {
        statusToggleAction?(self)
    }
    
    @IBAction func commentTextButtonTap(_ sender: Any) {
        commentTextButtonTapAction?(self)
    }
    @IBOutlet weak var buttonHiddenWidths: NSLayoutConstraint!
    
    // Closure variable for cell events (set by table's controller during cell init)
    var statusToggleAction: ((CommentViewCell) -> Void)?
    var commentTextButtonTapAction: ((CommentViewCell) -> Void)?
    
    
    
    // Functions
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    // Changes comment text appearance based off of its severity (value passed in from the state controller)
    func updateSeverity(severity: Int) {
        
        //let oldText: String = (commentTextButton.titleLabel?.text)!
        let oldText: String = (commentTextLabel.text)!
        var newText: NSMutableAttributedString
        
        switch (severity) {
        case 0:
            // Low severity -> underline
            commentTextAttributes[NSUnderlineStyleAttributeName] = 0
            commentTextAttributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 16)
            newText = NSMutableAttributedString(string: oldText, attributes: commentTextAttributes)
            //commentTextButton.setAttributedTitle(newText, for: .normal)
            commentTextLabel.attributedText = newText
            break;
        case 1:
            // Low severity -> underline
            commentTextAttributes[NSUnderlineStyleAttributeName] = 1
            commentTextAttributes[NSFontAttributeName] = UIFont.systemFont(ofSize: 16)
            newText = NSMutableAttributedString(string: oldText, attributes: commentTextAttributes)
            //commentTextButton.setAttributedTitle(newText, for: .normal)
            commentTextLabel.attributedText = newText
            break;
        case 2:
            // High severity -> bold + underline
            commentTextAttributes[NSUnderlineStyleAttributeName] = 1
            commentTextAttributes[NSFontAttributeName] = UIFont.boldSystemFont(ofSize: 16)
            newText = NSMutableAttributedString(string: oldText, attributes: commentTextAttributes)
            //commentTextButton.setAttributedTitle(newText, for: .normal)
            commentTextLabel.attributedText = newText
            break;
        default:
            print("Comment with resultId \(self.resultId) updated with bad severity value \(severity)")
        }
    }
    
}
