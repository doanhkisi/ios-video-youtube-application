//
//  PlaylistTableViewCell.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/2/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import Haneke
import NSDate_TimeAgo

class PlaylistTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var createdDateLabel: UILabel!
        
    var playlist: Item! {
        didSet {
            if let url = NSURL(string: playlist.thumbnails.medium.url) {
                thumbImageView.hnk_setImageFromURL(url)
            }
            titleLabel.text = playlist.title
            descriptionLabel.text = playlist.des
            createdDateLabel.text = playlist.publishAt.dateTimeUntilNow()
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
}
