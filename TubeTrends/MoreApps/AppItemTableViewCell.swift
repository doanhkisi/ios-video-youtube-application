//
//  AppItemTableViewCell.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 1/14/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class AppItemTableViewCell: UITableViewCell {
    
    var downloadButtonTappedHandler: (AppItem -> Void)?
    
    var appItem: AppItem!

    @IBOutlet weak var iconImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

    @IBAction func downloadButtonTapped(sender: AnyObject) {
//        let url = NSURL(string: (appItem.link))
//        UIApplication.sharedApplication().openURL(url!)
        downloadButtonTappedHandler?(self.appItem)
    }
}
