//
//  SwitchBoolTableViewCell.swift
//  ChiaSeNhac
//
//  Created by Phan Hữu Thắng on 1/6/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class SwitchBoolTableViewCell: UITableViewCell {

    @IBOutlet weak var switchControl: UISwitch!
    @IBOutlet weak var titleCell: UILabel!
    
    var switchBoolCellChanged: (SwitchBoolTableViewCell -> Void)?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func switchBoolChanged(sender: AnyObject) {
        switchBoolCellChanged?(self)
    }
    

}
