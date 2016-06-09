//
//  VideoPlayerViewController.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 12/31/15.
//  Website: https://v2t.mobi
//  Copyright © 2015 V2T Multimedia. All rights reserved.
//

import UIKit
import MediaPlayer
import XCDYouTubeKit
import QorumLogs

public class VideoPlayerViewController: UIViewController {
    
    private let preferredVideoQualities: [Any] = [
        NSNumber(unsignedInteger: XCDYouTubeVideoQuality.HD720.rawValue),
        NSNumber(unsignedInteger: XCDYouTubeVideoQuality.Medium360.rawValue),
        NSNumber(unsignedInteger: XCDYouTubeVideoQuality.Small240.rawValue)
    ]
    
    var moviePlayer: MPMoviePlayerController!
    
    let playerControl = VideoPlayerControl()
    
    var video: Item! {
        didSet {
            self.playVideo(video)
        }
    }
    
    func startVideo(video video: XCDYouTubeVideo, streamURL: NSURL) {
        self.playerControl.titleLabel.text = video.title
        self.moviePlayer.contentURL = streamURL
        self.moviePlayer.prepareToPlay()
    }
    
    init(video: Item) {
        super.init(nibName: nil, bundle: nil)
        
        self.video = video
        
        self.moviePlayer = MPMoviePlayerController(contentURL: nil)
        
        self.view.addSubview(moviePlayer.view)
        self.moviePlayer.view.translatesAutoresizingMaskIntoConstraints = false
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[moviePlayerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["moviePlayerView": moviePlayer.view]))
        view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[moviePlayerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["moviePlayerView": moviePlayer.view]))
        
        self.moviePlayer.controlStyle = .None
        
        self.moviePlayer.backgroundPlaybackEnabled = TubeTrends.Settings.playVideoInBackground
        
        self.view.backgroundColor = UIColor.clearColor()
        
        self.view.addSubview(self.playerControl)
        
        self.playerControl.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[playerControlView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["playerControlView": self.playerControl]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[playerControlView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["playerControlView": self.playerControl]))
        
        self.playerControl.delegatePlayer = self.moviePlayer
        self.playVideo(video)
        // Save video to histories
        let videos = TubeTrends.realm.objects(Items).filter("name = 'Histories'")[0].items
        if videos.filter("id = '\(video.id)'").count == 0 {
            if !(videos.count <= TubeTrends.Settings.historiesLimitCount) {
                try! TubeTrends.realm.write() {
                    videos.removeAtIndex(0)
                }
            }
            try! TubeTrends.realm.write() {
                video.createdAt = NSDate()
                video.modifiedAt = NSDate()
                videos.append(video)
                QL1("Video \(video.title) was added to histories.")
            }
        } else {
            try! TubeTrends.realm.write() {
                video.modifiedAt = NSDate()
                QL1("Video \(video.title) was updated to histories.")
            }
        }
        
        self.registerObserver(MPMoviePlayerLoadStateDidChangeNotification, object: self.moviePlayer, queue: nil) { (noti) -> Void in
            var songInfo: [String: AnyObject] = Dictionary()
            songInfo[MPMediaItemPropertyTitle] = self.video.title
            songInfo[MPNowPlayingInfoPropertyPlaybackRate] = 1.0
            songInfo[MPNowPlayingInfoPropertyElapsedPlaybackTime] = self.moviePlayer.currentPlaybackTime
            songInfo[MPMediaItemPropertyPlaybackDuration] = self.moviePlayer.duration
            if let imageURL = self.video.thumbnails.high.url {
                let url = NSURL(string: imageURL)
                if let data = NSData(contentsOfURL: url!) {
                    let image = UIImage(data: data)
                    songInfo[MPMediaItemPropertyArtwork] = MPMediaItemArtwork(image: image!)
                }
            }
            
            MPNowPlayingInfoCenter.defaultCenter().nowPlayingInfo = songInfo
        }
    }

    required public init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()
        
//        self.playerControl.delegate = self.superclass as? VideoDetailsViewController
    }
    
    public override func preferredStatusBarStyle() -> UIStatusBarStyle {
        return UIStatusBarStyle.Default
    }
    
    public override func prefersStatusBarHidden() -> Bool {
        return false
    }
    
    public override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.moviePlayer.prepareToPlay()
        UIApplication.sharedApplication().idleTimerDisabled = true
    }
    
    public override func viewDidDisappear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().idleTimerDisabled = false
    }
    
    public override func removeFromParentViewController() {
        super.removeFromParentViewController()
        self.moviePlayer.stop()
    }

    override public func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Private function 
    
    private func playVideo(video: Item) {
        if let offlinePath = video.offlinePath {
            let fileManager = NSFileManager.defaultManager()
            let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
            let dataPath = directoryURL.URLByAppendingPathComponent(offlinePath)
            debugPrint(dataPath)
            self.startVideo(video: XCDYouTubeVideo(), streamURL: dataPath)
        } else {
            XCDYouTubeClient.defaultClient().getVideoWithIdentifier(self.video.id) { (video, error) -> Void in
                if let video = video {
                    QL1(video.streamURLs)
                    var streamURL: NSURL?
                    switch TubeTrends.Settings.videoQuality {
                    case .k720p:
                        streamURL = video.streamURLs[NSNumber(unsignedInteger: XCDYouTubeVideoQuality.HD720.rawValue) as NSObject]
                        break
                    case .k360p:
                        streamURL = video.streamURLs[NSNumber(unsignedInteger: XCDYouTubeVideoQuality.Medium360.rawValue) as NSObject]
                        break
                    case .k240p:
                        streamURL = video.streamURLs[NSNumber(unsignedInteger: XCDYouTubeVideoQuality.Small240.rawValue) as NSObject]
                        break
                    }
                    if streamURL == nil {
                        for videoQuality in self.preferredVideoQualities {
                            if let streamURL = video.streamURLs[videoQuality as! NSObject] {
                                self.startVideo(video: video, streamURL: streamURL)
                                break
                            }
                        }
                    } else {
                        self.startVideo(video: video, streamURL: streamURL!)
                    }
                } else {
                    
                }
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
