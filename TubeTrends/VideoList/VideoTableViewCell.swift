//
//  VideoTableViewCell.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import Haneke
import ESTMusicIndicator

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var thumbImageView: UIImageView!
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likePercentLabel: UILabel!
    @IBOutlet weak var viewCountLabel: UILabel!
    @IBOutlet weak var musicIndicator: ESTMusicIndicatorView!
    
    var extraButtonTappedHandler: (VideoTableViewCell -> Void)?
    
    var video: Item! {
        didSet {
            if let url = NSURL(string: video.thumbnails.medium.url) {
                thumbImageView.hnk_setImageFromURL(url)
            }
            titleLabel.text = video.title
            descriptionLabel.text = video.des
            if video.viewsCount != 0 {
                viewCountLabel.text = String(video.viewsCount)
            }
            if video.likesCount + video.dislikesCount != 0 {
                likePercentLabel.text = String(100*video.likesCount/(video.likesCount + video.dislikesCount)) + "%"
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        musicIndicator.state = .ESTMusicIndicatorViewStatePlaying
    }

    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    @IBAction func extraButtonTapped(sender: AnyObject) {
        extraButtonTappedHandler?(self)
    }
    

}
