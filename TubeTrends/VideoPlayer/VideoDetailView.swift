//
//  VideoDetailView.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/24/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import FontAwesomeIconFactory
import XCDYouTubeKit
import QorumLogs
import RealmSwift
import UIColor_Hex_Swift

class VideoDetailView: UIView {
    
    private var totalBytesRead: Int64 = 0
    private var totalBytesExpectedToRead: Int64 = 0
    
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var viewsCountLabel: UILabel!
    @IBOutlet weak var expanButton: NIKFontAwesomeButton!
    @IBOutlet weak var descriptionLabel: UILabel!
    @IBOutlet weak var likesCountLabel: UILabel!
    @IBOutlet weak var dislikesCountLabel: UILabel!
    @IBOutlet weak var downloadButton: NIKFontAwesomeButton!
    @IBOutlet weak var titleLabelTopMarginConstraint: NSLayoutConstraint!
    
    @IBOutlet weak var bottomToolHeightConstraint: NSLayoutConstraint!
    
    private var downloadOptions: [BottomMenuViewItem] = []
    
    var expandButtonTappedHandler: (Void -> Void)?
    var downloadButtonTappedHandler: (Void -> Void)?
    
    var video: Item! {
        didSet {
            titleLabel.text = video.title
            
            let numberFormatter = NSNumberFormatter()
            numberFormatter.numberStyle = .DecimalStyle
            
            viewsCountLabel.text = numberFormatter.stringFromNumber(video.viewsCount)! + NSLocalizedString(" views", comment: "")
            descriptionLabel.text = video.des
            likesCountLabel.text = numberFormatter.stringFromNumber(video.likesCount)
            dislikesCountLabel.text = numberFormatter.stringFromNumber(video.dislikesCount)
            
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(video.id) { (video, error) -> Void in
                if let video = video {
                    self.downloadOptions = []
                    if let streamURL = video.streamURLs[NSNumber(unsignedInteger: XCDYouTubeVideoQuality.HD720.rawValue) as NSObject] {
                        self.downloadOptions.append(BottomMenuViewItem(title: "720p", selectedAction: { (Void) -> Void in
                            QL1(streamURL)
                            self.downloadVideo(streamURL.absoluteString)
                        }))
                    }
                    if let streamURL = video.streamURLs[NSNumber(unsignedInteger: XCDYouTubeVideoQuality.Medium360.rawValue) as NSObject] {
                        self.downloadOptions.append(BottomMenuViewItem(title: "360p", selectedAction: { (Void) -> Void in
                            QL1(streamURL)
                            self.downloadVideo(streamURL.absoluteString)
                        }))
                    }
                    if let streamURL = video.streamURLs[NSNumber(unsignedInteger: XCDYouTubeVideoQuality.Small240.rawValue) as NSObject] {
                        self.downloadOptions.append(BottomMenuViewItem(title: "240p", selectedAction: { (Void) -> Void in
                            QL1(streamURL)
                            self.downloadVideo(streamURL.absoluteString)
                        }))
                    }
                    if self.downloadOptions.count > 0 {
                        self.downloadButton.color = UIColor(rgba: "#FD2D55")
                        self.downloadButton.setTitleColor(UIColor(rgba: "#FD2D55"), forState: .Normal)
                        self.downloadOptions.append(BottomMenuViewItem(title: NSLocalizedString("Cancel", comment: "")))
                    }
                } else {
                    
                }
            }
            let videoItem = TubeTrends.realm.objects(Items).filter("name = 'Downloads'")[0].items.filter("id contains '\(video.id)'")
            if videoItem.count == 1 {
                self.downloadButton.setTitle(NSLocalizedString(" Downloaded", comment: ""), forState: .Normal)
            }
            
            downloadButton.hidden = !TubeTrends.Settings.isShowDownloadFunction
            
        }
    }
    
    // this name has to match your class file and your xib file
    private let nibName = "VideoDetailView"
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        comminInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        comminInit()
    }
    
    private func comminInit() {
        let bundle = NSBundle(forClass: self.dynamicType)
        let nib = UINib(nibName: nibName, bundle: bundle)
        let view = nib.instantiateWithOwner(self, options: nil).first as! UIView
        addSubview(view)
        
        view.translatesAutoresizingMaskIntoConstraints = false
        let bindings = ["view": view]
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[view]|", options:NSLayoutFormatOptions(rawValue: 0), metrics:nil, views: bindings))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        var height: CGFloat = 0
        height += titleLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height +
            viewsCountLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height +
            titleLabelTopMarginConstraint.constant + bottomToolHeightConstraint.constant + 16
        if !descriptionLabel.hidden {
            height += descriptionLabel.systemLayoutSizeFittingSize(UILayoutFittingCompressedSize).height + 16
        }
        self.frame.size.height = height
    }
    
    @IBAction func expanButtonTapped(sender: NIKFontAwesomeButton) {
        descriptionLabel.hidden = !descriptionLabel.hidden
        if descriptionLabel.hidden {
            expanButton.iconHex = "f0d7"
        } else {
            expanButton.iconHex = "f0d8"
        }
        layoutSubviews()
        expandButtonTappedHandler?()
    }
    
    @IBAction func downloadButtonTapped(sender: NIKFontAwesomeButton) {
        if downloadOptions.count > 0 {
            let bottomMenu = BottomMenuView(items: downloadOptions, didSelectedHandler: nil)
            let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
            bottomMenu.showInViewController((appDelegate.window?.rootViewController)!)
        }
        downloadButtonTappedHandler?()
    }
    
    func updateDownloadPercent() {
        if self.totalBytesRead != 0 {
            self.downloadButton.setTitle(" " + String(format: "%.2f", 100*(Float(totalBytesRead)/Float(totalBytesExpectedToRead))) + "%", forState: .Normal)
        }
        self.performSelector(#selector(self.updateDownloadPercent), withObject: nil, afterDelay: 0.5)
    }
    
    private func downloadVideo(streamURL: String!) {
        self.totalBytesRead = 0
        self.totalBytesExpectedToRead = 0
        self.updateDownloadPercent()
        TubeTrends.downloadStreaming(streamURL, fileName: video.title,
            onProgress: { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                self.totalBytesRead = totalBytesRead
                self.totalBytesExpectedToRead = totalBytesExpectedToRead
            },
            completionHandler: { (path) in
                self.totalBytesRead = 0
                self.totalBytesExpectedToRead = 0
                NSObject.cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.updateDownloadPercent), object: nil)
                dispatch_async(dispatch_get_main_queue()) {
                    self.downloadButton.setTitle(NSLocalizedString(" Downloaded", comment: ""), forState: .Normal)
                }
                let videos = TubeTrends.realm.objects(Items).filter("name = 'Downloads'")[0].items
                try! TubeTrends.realm.write() {
                    self.video.offlinePath = path
                    self.video.createdAt = NSDate()
                    self.video.modifiedAt = NSDate()
                    videos.append(self.video)
                }
        })
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
