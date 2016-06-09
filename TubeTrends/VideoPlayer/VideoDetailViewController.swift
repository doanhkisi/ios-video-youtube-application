//
//  VideoDetailViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/20/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import QorumLogs
import FontAwesomeIconFactory
import FontAwesome_swift

enum UIPanGestureRecognizerDirection: Int {
    case Undefined
    case Up
    case Down
    case Left
    case Right
}

class VideoDetailViewController: V2TViewController, VideoPlayerControlDelegate {
    
    private let relatedVideoListVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController

    
    private let playlistMiniHeight: CGFloat = 44
    
    private var tapGesture: UITapGestureRecognizer!
    private var relatedVideoListVCFrame = CGRect()
    
    private var direction = UIPanGestureRecognizerDirection.Undefined
    private var touchPositionBegan = CGPoint()
    private var parentView = UIView()
    
    private(set) var videoPlayerVC: VideoPlayerViewController!
    
    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var relatedView: UIView!
    @IBOutlet weak var closeButton: NIKFontAwesomeButton!
    
    @IBOutlet weak var playlistView: UIView!
    @IBOutlet weak var queueLabel: UILabel!
    @IBOutlet weak var playlistExpandButton: NIKFontAwesomeButton!
    
    @IBOutlet weak var playlistHeaderView: UIView!
    var miniViewHeight: CGFloat = 120.0
    var bottomPadding: CGFloat = 0.0
    var video: Item! {
        didSet {
            videoPlayerVC?.moviePlayer.stop()
            videoPlayerVC?.video = video
            
            let tableView: V2TTableView = self.relatedVideoListVC.tableView as! V2TTableView
            tableView.showTableViewHeader = true
            let videoDetailView = VideoDetailView()
            sharedYTAPI.getVideoDetails(self.video.id, completionHandler: { (video) -> Void in
                videoDetailView.video = video
            })
            videoDetailView.video = self.video
            videoDetailView.expandButtonTappedHandler = {
                self.relatedVideoListVC.tableView.reloadData()
            }
            tableView.tableHeaderView = videoDetailView
            self.relatedVideoListVC.tableView.setContentOffset(CGPointZero, animated:true)
            sharedYTAPI.getRelatedVideos(self.video.id!, videos: Items(), completionHandler: { (videos) -> Void in
                self.relatedVideoListVC.videos = videos
                self.relatedVideoListVC.tableView.reloadData()
                self.relatedVideoListVC.view.bringSubviewToFront(self.relatedVideoListVC.swipeRefreshControl) // Fix swipe control is hidden by tableViewHeader
            })
            if let playlist = TubeTrends.sharedVideoDetailVC?.playlist {
                let index = playlist.items.indexOf(self.video)
                if let index = index {
                    self.playlistVideoListVC.tableView.reloadData()
                    self.playlistVideoListVC.tableView.scrollToRowAtIndexPath(NSIndexPath(forRow: index, inSection: 0), atScrollPosition: .Top, animated: true)
                    self.queueLabel.text = NSLocalizedString("Queue \(index + 1)/\(playlist.items.count)", comment: "")
                    
                }
            }
        }
    }
    let playlistVideoListVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
    var playlist: Items!
    
    private(set) var isMiniView = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(self.panAction(_:)))
        videoView.addGestureRecognizer(panGesture)
        tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.tapAction(_:)))
        
        videoPlayerVC = VideoPlayerViewController(video: video)
        
        videoPlayerVC.playerControl.delegate = self
        
        self.addChildViewController(videoPlayerVC)
        videoPlayerVC.view.translatesAutoresizingMaskIntoConstraints = false
        self.videoView.addSubview(videoPlayerVC.view)
        videoPlayerVC.didMoveToParentViewController(self)
        
        videoView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[videoPlayerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["videoPlayerView": videoPlayerVC.view]))
        videoView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[videoPlayerView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["videoPlayerView": videoPlayerVC.view]))
        
        UIView.animateKeyframesWithDuration(2.0, delay: 0, options: [.Autoreverse, .Repeat, .AllowUserInteraction], animations: { () -> Void in
            UIView.addKeyframeWithRelativeStartTime(0.0, relativeDuration: 0.5, animations: { () -> Void in
                self.closeButton.transform = CGAffineTransformMakeScale(1.5, 1.5)
                self.addShadow(self.closeButton)
                self.closeButton.frame.origin.y += 17
            })
            UIView.addKeyframeWithRelativeStartTime(0.5, relativeDuration: 0.5, animations: { () -> Void in
                self.closeButton.frame.origin.y -= 17
                self.closeButton.transform = CGAffineTransformIdentity
                self.addShadow(self.closeButton)
            })
            }) { (Bool) -> Void in
                //
        }
        
        // Playlist Video Controller
        playlistVideoListVC.viewDidLoadHandler = {
            if let playlist = self.playlist {
                self.playlistVideoListVC.videos = playlist
                self.playlistVideoListVC.tableView.reloadData()
                self.playlistVideoListVC.view.bringSubviewToFront(self.playlistVideoListVC.swipeRefreshControl) // Fix swipe control is hidden by tableViewHeader
            }
        }
        
        playlistVideoListVC.didSelectedCellItem = { indexPath, video in
            TubeTrends.sharedVideoDetailVC?.video = video
            self.playlistVideoListVC.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            self.queueLabel.text = NSLocalizedString("Queue \(indexPath.row + 1)/\(self.playlistVideoListVC.videos.items.count)", comment: "")
        }
        
        playlistVideoListVC.extraButtonAtCellTappedHandler = { video in
            TubeTrends.showExtraOptionPlaylistVideo(video)
        }
        
        playlistVideoListVC.hilightPlaying = true
        
        self.addChildViewController(playlistVideoListVC)
        self.playlistView.addSubview(playlistVideoListVC.view)
        playlistVideoListVC.view.translatesAutoresizingMaskIntoConstraints = false
        playlistView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[videoListView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["videoListView": playlistVideoListVC.view]))
        playlistView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[playlistHeaderView][videoListView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["videoListView": playlistVideoListVC.view, "playlistHeaderView": playlistHeaderView]))
        playlistVideoListVC.didMoveToParentViewController(self)
        
        // Related Video List
        relatedVideoListVC.viewDidLoadHandler = {
            let tableView: V2TTableView = self.relatedVideoListVC.tableView as! V2TTableView
            tableView.showTableViewHeader = true
            let videoDetailView = VideoDetailView()
            sharedYTAPI.getVideoDetails(self.video.id, completionHandler: { (video) -> Void in
                videoDetailView.video = video
            })
            videoDetailView.video = self.video
            videoDetailView.expandButtonTappedHandler = {
                self.relatedVideoListVC.tableView.reloadData()
            }
            tableView.tableHeaderView = videoDetailView
            self.relatedVideoListVC.tableView.setContentOffset(CGPointZero, animated:true)
            sharedYTAPI.getRelatedVideos(self.video.id!, videos: Items(), completionHandler: { (videos) -> Void in
                self.relatedVideoListVC.videos = videos
                self.relatedVideoListVC.tableView.reloadData()
                self.relatedVideoListVC.view.bringSubviewToFront(self.relatedVideoListVC.swipeRefreshControl) // Fix swipe control is hidden by tableViewHeader
                QL1(videoDetailView.frame)
            })
        }
        relatedVideoListVC.scrollViewDidEndDraggingHandler = {
            if let _ = self.relatedVideoListVC.videos.nextPage {
                sharedYTAPI.getRelatedVideos(self.video.id!, videos: self.relatedVideoListVC.videos, completionHandler: { (videos) -> Void in
                    self.relatedVideoListVC.videos = videos
                    self.relatedVideoListVC.tableView.reloadData()
                })
            }
        }
        relatedVideoListVC.refreshListHander = {
            sharedYTAPI.getRelatedVideos(self.video.id!, videos: self.relatedVideoListVC.videos,
                completionHandler: { (videos) -> Void in
                    self.relatedVideoListVC.videos = Items()
                    self.relatedVideoListVC.videos = videos
                    self.relatedVideoListVC.tableView.reloadData()
                    self.relatedVideoListVC.swipeRefreshControl.endRefreshing()
            })
        }
        relatedVideoListVC.extraButtonAtCellTappedHandler = { cell in
            TubeTrends.showExtraOptionOnlineCell(cell)
        }
        
        self.addChildViewController(relatedVideoListVC)
        self.relatedView.addSubview(relatedVideoListVC.view)
        relatedVideoListVC.view.translatesAutoresizingMaskIntoConstraints = false
        relatedView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[videoListView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["videoListView": relatedVideoListVC.view]))
        relatedView.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[playlistHeaderView][videoListView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["videoListView": relatedVideoListVC.view, "playlistHeaderView": self.playlistHeaderView]))
        relatedVideoListVC.didMoveToParentViewController(self)
        
        // MPMovieDelegate notification
        self.registerObserver(MPMoviePlayerPlaybackDidFinishNotification, object: TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer, queue: nil) { (noti) -> Void in
            /* Find out what the reason was for the player to stop */
            let reason = noti.userInfo![MPMoviePlayerPlaybackDidFinishReasonUserInfoKey]
                as! NSNumber?
            
            if let theReason = reason {
                
                let reasonValue = MPMovieFinishReason(rawValue: theReason.integerValue)
                
                switch reasonValue!{
                case .PlaybackEnded:
                    /* The movie ended normally*/
                    if TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.duration == TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.currentPlaybackTime {
                        let index = TubeTrends.sharedVideoDetailVC?.playlist.items.indexOf(self.video)
                        if let index = index {
                            if index + 1 < TubeTrends.sharedVideoDetailVC?.playlist.items.count {
                                TubeTrends.sharedVideoDetailVC?.video = TubeTrends.sharedVideoDetailVC?.playlist.items[index + 1]
                            }
                        }
                    }
                    break
                case .PlaybackError:
                    if TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.duration == TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.currentPlaybackTime {
                        let index = TubeTrends.sharedVideoDetailVC?.playlist.items.indexOf(self.video)
                        if let index = index {
                            if index + 1 < TubeTrends.sharedVideoDetailVC?.playlist.items.count {
                                TubeTrends.sharedVideoDetailVC?.video = TubeTrends.sharedVideoDetailVC?.playlist.items[index + 1]
                            }
                        }
                    }
                    break
                case .UserExited:
                    /* The user exited the player */
                    break
                }
            }
        }
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: Embed
    func showInViewController(viewController: UIViewController) {
        
        parentView = viewController.view
        viewController.addChildViewController(self)
        self.view.frame = viewController.view.frame
        self.view.autoresizingMask = [.FlexibleHeight, .FlexibleWidth]
        viewController.view.addSubview(self.view)
        self.didMoveToParentViewController(viewController)
        expandView()
        self.view.frame.origin.y = viewController.view.frame.height
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.view.frame.origin.y = viewController.view.frame.origin.y
            }) { (Bool) -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .Fade)
        }
        
        self.becomeFirstResponder()
        UIApplication.sharedApplication().beginReceivingRemoteControlEvents()
    }
    
    func remove() {
        self.willMoveToParentViewController(nil)
        self.view.removeFromSuperview()
        self.removeFromParentViewController()
        videoPlayerVC.moviePlayer.stop()
        playlist = nil
        UIApplication.sharedApplication().endReceivingRemoteControlEvents()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
    }
    
    // MARK: - Gesture
    func panAction(recognizer: UIPanGestureRecognizer) {
//        let y = recognizer.locationInView(recognizer.view).y
        if recognizer.state == .Began {
            direction = getPanDirection(recognizer.velocityInView(recognizer.view))
            touchPositionBegan.x = recognizer.locationInView(videoView).x
            touchPositionBegan.y = recognizer.locationInView(videoView).y
        } else if recognizer.state == .Changed {
            if direction == .Down || direction == .Up {
                UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .Fade)
                closeButton.hidden = true
                videoView.layer.borderColor = UIColor.grayColor().CGColor
                videoView.layer.borderWidth = 0.5
                if view.frame.origin.y >= 0 &&
                    view.frame.origin.y <= parentView.frame.height - miniViewHeight - bottomPadding {
                        let newOffsetY = recognizer.locationInView(view).y - touchPositionBegan.y
                        view.frame.origin.y += newOffsetY
                        view.frame.size.height -= newOffsetY
                        view.frame.size.width -= newOffsetY*0.35
                        view.frame.origin.x += newOffsetY*0.35
                        let percent = view.frame.size.height/parentView.frame.size.height
                        relatedView.alpha = percent
                }
            } else if direction == .Right || direction == .Left {
                if isMiniView {
                    let newOffsetX = recognizer.locationInView(view).x - touchPositionBegan.x
                    view.frame.origin.x += newOffsetX
                    if direction == .Left {
                        view.alpha = view.frame.origin.x/(parentView.frame.size.width-view.frame.width)
                    } else {
                        view.alpha = (parentView.frame.size.width-view.frame.width)/view.frame.origin.x
                    }
                }
            }
            
        } else  if recognizer.state == .Ended {
            if direction == .Down || direction == .Up {
                if view.frame.origin.y < parentView.frame.size.height*0.6 && direction == .Up {
                    expandView()
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                } else if view.frame.origin.y > parentView.frame.size.height*0.3 && direction == .Down {
                    miniView()
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                } else if view.frame.origin.y < parentView.frame.size.height*0.3 && direction == .Down {
                    expandView()
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                } else if view.frame.origin.y > parentView.frame.size.height*0.6 && direction == .Up {
                    miniView()
                    recognizer.setTranslation(CGPointZero, inView: recognizer.view)
                }
            } else if direction == .Right || direction == .Left {
                if isMiniView {
                    if view.frame.origin.x <= 0 || view.frame.origin.x >= parentView.frame.width - 10 {
                        self.remove()
                    } else {
                        view.alpha = 1
                        miniView()
                    }
                }
                recognizer.setTranslation(CGPointZero, inView: recognizer.view)
            }
        }
    }
    
    func tapAction(recognizer: UITapGestureRecognizer) {
        if isMiniView {
            expandView()
        }
    }
    
    // MARK: - Button action
    @IBAction func closeButtonTapped(sender: NIKFontAwesomeButton) {
        miniView()
    }
    @IBAction func playlistExpandButtonTapped(sender: NIKFontAwesomeButton) {
        expandOrCollapsePlaylistView()
    }
    @IBAction func moreExtraButtonTapped(sender: NIKFontAwesomeButton) {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToFavorites(self.video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.List, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToPlaylist(self.video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.ShareAlt, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Share...", comment: ""), selectedAction: { (Void) -> Void in
                
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.AngleDown, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        bottomMenu.showInViewController((appDelegate.window?.rootViewController)!)
    }
    
    // MARK: - VideoPlayerControl delegate
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, backButtonDidTapped button: UIButton) {
        
    }
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, settingButtonDidTapped button: UIButton){
        
    }
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, fullscreenButtonDidTapped button: UIButton){
        
    }
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, playButtonDidTapped button: UIButton){
        
    }
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, pauseButtonDidTapped button: UIButton){
        
    }
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, nextButtonDidTapped button: UIButton){
        self.playNextVideo()
    }
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, prevButtonDidTapped button: UIButton){
        self.playPrevVideo()
    }

    // MARK: - Private function
    private func getPanDirection(velocity: CGPoint) -> UIPanGestureRecognizerDirection {
        let isVerticalGesture = fabs(velocity.y) > fabs(velocity.x)
        if isVerticalGesture {
            if (velocity.y > 0) {
                return .Down
            } else {
                return .Up
            }
        } else {
            if(velocity.x > 0) {
                return .Right
            } else {
                return .Left
            }
        }
    }
    
    private func expandView() {
        let navigationController = self.parentViewController as? RootViewController
        navigationController?.isPortraint = false
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.frame = self.parentView.frame
            self.relatedView.alpha = 1
            self.playlistView.alpha = 1
            }, completion: { (Bool) -> Void in
                UIApplication.sharedApplication().setStatusBarHidden(true, withAnimation: .None)
                self.closeButton.hidden = false
                self.isMiniView = false
                self.videoView.layer.borderWidth = 0
                self.videoView.removeGestureRecognizer(self.tapGesture)
        })
    }
    
    private func miniView() {
        let navigationController = self.parentViewController as? RootViewController
        navigationController?.isPortraint = true
        self.closeButton.hidden = true
        self.videoPlayerVC.playerControl.hide()
        UIApplication.sharedApplication().setStatusBarHidden(false, withAnimation: .None)
        UIView.animateWithDuration(0.4, animations: { () -> Void in
            self.view.frame = CGRect(x: self.parentView.frame.size.width - self.miniViewHeight*1.35, y: self.parentView.frame.size.height - self.miniViewHeight - self.bottomPadding, width: self.miniViewHeight*1.35, height: self.miniViewHeight)
            self.relatedView.alpha = 0
            self.playlistView.alpha = 0
            }, completion: { (Bool) -> Void in
                self.isMiniView = true
                self.videoView.addGestureRecognizer(self.tapGesture)
        })
    }
    
    private func expandOrCollapsePlaylistView() {
        if !self.relatedVideoListVC.view.hidden {
            self.relatedVideoListVCFrame = self.relatedVideoListVC.view.frame
            if let index = TubeTrends.sharedVideoDetailVC?.playlist.items.indexOf(self.video) {
                let indexPath = NSIndexPath(forRow: index, inSection: 0)
                self.playlistVideoListVC.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            }
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.relatedVideoListVC.view.frame.origin.y = UIScreen.mainScreen().bounds.height
                self.playlistExpandButton.color = TubeTrends.Settings.foregroundColor
                }, completion: { (Bool) -> Void in
                    self.relatedVideoListVC.view.hidden = true
            })
        } else {
            self.relatedVideoListVC.view.hidden = false
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                    self.relatedVideoListVC.view.frame = self.relatedVideoListVCFrame
                    self.playlistExpandButton.color = UIColor.whiteColor()
                }, completion: { (Bool) -> Void in
                    
            })
        }
    }
    
    private func addShadow(view: UIView) {
        view.layer.shadowColor = UIColor.whiteColor().CGColor
        view.layer.shadowOffset = CGSizeMake(0, 1)
        view.layer.shadowOpacity = 1
        view.layer.shadowRadius = 4
        view.clipsToBounds = false
    }
    
    private func playNextVideo() {
        let index = TubeTrends.sharedVideoDetailVC?.playlist.items.indexOf(self.video)
        if let index = index {
            if index + 1 < TubeTrends.sharedVideoDetailVC?.playlist.items.count {
                TubeTrends.sharedVideoDetailVC?.video = TubeTrends.sharedVideoDetailVC?.playlist.items[index + 1]
            }
        }
    }
    
    private func playPrevVideo() {
        let index = TubeTrends.sharedVideoDetailVC?.playlist.items.indexOf(self.video)
        if let index = index {
            if index - 1 >= 0 {
                TubeTrends.sharedVideoDetailVC?.video = TubeTrends.sharedVideoDetailVC?.playlist.items[index - 1]
            }
        }
    }
    
    // MARK: Remote control
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func remoteControlReceivedWithEvent(event: UIEvent?) {
        if let event = event {
            switch event.subtype {
            case .None:
                break
            case .MotionShake:
                break
            case .RemoteControlPlay:
                TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.play()
                break
            case .RemoteControlPause:
                TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.pause()
                break
            case .RemoteControlStop:
                TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.stop()
                break
            case .RemoteControlTogglePlayPause:
                if TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.playbackState == .Paused {
                    TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.play()
                } else if TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.playbackState == .Playing {
                    TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.pause()
                }
                break
            case .RemoteControlNextTrack:
                self.playNextVideo()
                break
            case .RemoteControlPreviousTrack:
                self.playPrevVideo()
                break
            case .RemoteControlBeginSeekingBackward:
                break
            case .RemoteControlEndSeekingBackward: 
                break
            case .RemoteControlBeginSeekingForward: 
                break
            case .RemoteControlEndSeekingForward: 
                break
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
