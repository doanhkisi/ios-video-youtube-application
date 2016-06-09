//
//  VideoPlayerControl.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 12/31/15.
//  Website: https://v2t.mobi
//  Copyright © 2015 V2T Multimedia. All rights reserved.
//

import UIKit
import FontAwesome_swift
import MediaPlayer

protocol VideoPlayerControlDelegate: NSObjectProtocol {
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, backButtonDidTapped button: UIButton)
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, settingButtonDidTapped button: UIButton)
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, fullscreenButtonDidTapped button: UIButton)
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, playButtonDidTapped button: UIButton)
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, pauseButtonDidTapped button: UIButton)
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, nextButtonDidTapped button: UIButton)
    func videoPlayerControl(videoPlayerControl: VideoPlayerControl, prevButtonDidTapped button: UIButton)
}

class VideoPlayerControl: UIControl {
    
    var delegate: VideoPlayerControlDelegate?

    var delegatePlayer: MPMoviePlayerController!
    
    let overlayPanel = UIView()
    let topPanel = UIView()
    let bottomPanel = UIView()
    let adsView = UIView()
    
    let playButton = UIButton(type: UIButtonType.Custom)
    let pauseButton = UIButton(type: UIButtonType.Custom)
    let prevButton = UIButton(type: .Custom)
    let nextButton = UIButton(type: .Custom)
    let settingButton = UIButton(type: .Custom)
    let fullscreenButton = UIButton(type: .Custom)
    let backButton = UIButton(type: .Custom)
    
    let titleLabel = UILabel()
    let subTitleLabel = UILabel()
    
    let loadingIndicatiorView = UIActivityIndicatorView()
    
    let currentTimeLabel = UILabel()
    let totalDurationLabel = UILabel()
    let mediaProcessSlider = UISlider()
    
    
    private var timerToHideControl = NSTimer()
    private var isMediaSliderBeingDragged = false
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backButton.hidden = true
        
        self.loadingIndicatiorView.tintColor = UIColor.whiteColor()
        self.loadingIndicatiorView.transform = CGAffineTransformMakeScale(2.0, 2.0)
        self.loadingIndicatiorView.hidden = true
        
        self.backgroundColor = UIColor.clearColor()
        self.overlayPanel.backgroundColor = UIColor.clearColor()
        self.topPanel.backgroundColor = UIColor.clearColor()
        self.bottomPanel.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.7)
        self.adsView.backgroundColor = UIColor.clearColor()
        
        self.playButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.Play, textColor: UIColor.whiteColor(), size: CGSize(width: 32, height: 32)), forState: .Normal)
        self.playButton.layer.cornerRadius = 22
        self.playButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.playButton.layer.borderWidth = 1
        self.playButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 0, 0)
        self.playButton.addTarget(self, action: #selector(self.playButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.pauseButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.Pause, textColor: UIColor.whiteColor(), size: CGSize(width: 32, height: 32)), forState: .Normal)
        self.pauseButton.layer.cornerRadius = 22
        self.pauseButton.layer.borderWidth = 1
        self.pauseButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.pauseButton.contentEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0)
        self.pauseButton.addTarget(self, action: #selector(self.pauseButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.prevButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.StepBackward, textColor: UIColor.whiteColor(), size: CGSize(width: 32, height: 32)), forState: .Normal)
//        self.prevButton.layer.cornerRadius = 22
//        self.prevButton.layer.borderColor = UIColor.whiteColor().CGColor
//        self.prevButton.layer.borderWidth = 1
//        self.prevButton.contentEdgeInsets = UIEdgeInsetsMake(2, 4, 0, 0)
        self.prevButton.addTarget(self, action: #selector(self.prevButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.nextButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.StepForward, textColor: UIColor.whiteColor(), size: CGSize(width: 32, height: 32)), forState: .Normal)
//        self.nextButton.layer.cornerRadius = 22
//        self.nextButton.layer.borderWidth = 1
//        self.nextButton.layer.borderColor = UIColor.whiteColor().CGColor
//        self.nextButton.contentEdgeInsets = UIEdgeInsetsMake(0, 1, 0, 0)
        self.nextButton.addTarget(self, action: #selector(self.nextButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.settingButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.Cog, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20)), forState: .Normal)
        self.settingButton.showsTouchWhenHighlighted = true
        self.settingButton.addTarget(self, action: #selector(self.settingButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.fullscreenButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.Expand, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20)), forState: .Normal)
        self.fullscreenButton.showsTouchWhenHighlighted = true
        self.fullscreenButton.addTarget(self, action: #selector(self.fullscreenButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.backButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.AngleLeft, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20)), forState: .Normal)
        self.backButton.showsTouchWhenHighlighted = true
        self.backButton.layer.cornerRadius = 16
        self.backButton.layer.borderColor = UIColor.whiteColor().CGColor
        self.backButton.layer.borderWidth = 1
        self.backButton.addTarget(self, action: #selector(self.backButtonTapped(_:)), forControlEvents: .TouchUpInside)
        
        self.mediaProcessSlider.setThumbImage(UIImage.fontAwesomeIconWithName(FontAwesome.Circle, textColor: UIColor(rgba: "#d32f2f"), size: CGSize(width: 16, height: 16)), forState: .Normal)
        self.mediaProcessSlider.tintColor = UIColor(rgba: "#d32f2f")
        
        self.mediaProcessSlider.addTarget(self, action: #selector(self.beginDragMediaSlider), forControlEvents: UIControlEvents.TouchDown)
        self.mediaProcessSlider.addTarget(self, action: #selector(self.endDragMediaSlider), forControlEvents: UIControlEvents.TouchCancel)
        self.mediaProcessSlider.addTarget(self, action: #selector(self.endDragMediaSlider), forControlEvents: UIControlEvents.TouchUpOutside)
        self.mediaProcessSlider.addTarget(self, action: #selector(self.endDragMediaSlider), forControlEvents: UIControlEvents.TouchUpInside)
        self.mediaProcessSlider.addTarget(self, action: #selector(self.continueDragMediaSlider), forControlEvents: UIControlEvents.ValueChanged)
        
        self.currentTimeLabel.font = UIFont.systemFontOfSize(10)
        self.currentTimeLabel.textColor = UIColor.whiteColor()
        
        self.totalDurationLabel.font = UIFont.systemFontOfSize(10)
        self.totalDurationLabel.textColor = UIColor.whiteColor()
        
        self.titleLabel.font = UIFont.systemFontOfSize(12)
        self.titleLabel.textColor = UIColor.whiteColor()
        self.titleLabel.textAlignment = .Right
        self.titleLabel.hidden = true
        
        self.subTitleLabel.font = UIFont.systemFontOfSize(10)
        self.subTitleLabel.textColor = UIColor.whiteColor()
        
        self.adsView.translatesAutoresizingMaskIntoConstraints = false
        self.overlayPanel.translatesAutoresizingMaskIntoConstraints = false
        self.topPanel.translatesAutoresizingMaskIntoConstraints = false
        self.bottomPanel.translatesAutoresizingMaskIntoConstraints = false
        self.playButton.translatesAutoresizingMaskIntoConstraints = false
        self.pauseButton.translatesAutoresizingMaskIntoConstraints = false
        self.prevButton.translatesAutoresizingMaskIntoConstraints = false
        self.nextButton.translatesAutoresizingMaskIntoConstraints = false
        self.settingButton.translatesAutoresizingMaskIntoConstraints = false
        self.fullscreenButton.translatesAutoresizingMaskIntoConstraints = false
        self.backButton.translatesAutoresizingMaskIntoConstraints = false
        self.currentTimeLabel.translatesAutoresizingMaskIntoConstraints = false
        self.totalDurationLabel.translatesAutoresizingMaskIntoConstraints = false
        self.mediaProcessSlider.translatesAutoresizingMaskIntoConstraints = false
        self.loadingIndicatiorView.translatesAutoresizingMaskIntoConstraints = false
        self.titleLabel.translatesAutoresizingMaskIntoConstraints = false
        self.subTitleLabel.translatesAutoresizingMaskIntoConstraints = false
        
        self.topPanel.addSubview(backButton)
        self.topPanel.addSubview(titleLabel)
        self.topPanel.addSubview(subTitleLabel)
        
        self.bottomPanel.addSubview(currentTimeLabel)
        self.bottomPanel.addSubview(mediaProcessSlider)
        self.bottomPanel.addSubview(totalDurationLabel)
//        self.bottomPanel.addSubview(settingButton)
        self.bottomPanel.addSubview(fullscreenButton)
        
        self.overlayPanel.addSubview(pauseButton)
        self.overlayPanel.addSubview(playButton)
        self.overlayPanel.addSubview(prevButton)
        self.overlayPanel.addSubview(nextButton)
        self.overlayPanel.addSubview(topPanel)
        self.overlayPanel.addSubview(bottomPanel)
        
        self.addSubview(overlayPanel)
        self.addSubview(loadingIndicatiorView)
        self.addSubview(adsView)
        self.layoutViews()
        
        self.addTarget(self, action: #selector(self.updateOverlayPanel), forControlEvents: UIControlEvents.TouchUpInside)
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(self.updateOverlayPanel))
        self.overlayPanel.addGestureRecognizer(tapGesture)
        
        self.show()
        
        self.loadingIndicatiorView.startAnimating()
        
        self.registerObserver(UIDeviceOrientationDidChangeNotification, object: nil, queue: nil) { (noti) -> Void in
            if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
                self.fullscreenButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.Compress, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20)), forState: .Normal)
                self.titleLabel.hidden = false
            } else {
                self.fullscreenButton.setImage(UIImage.fontAwesomeIconWithName(FontAwesome.Expand, textColor: UIColor.whiteColor(), size: CGSize(width: 20, height: 20)), forState: .Normal)
                self.titleLabel.hidden = true
            }
        }
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func layoutViews() {
        let views = ["overlayPanel": overlayPanel,
        "topPanel": topPanel,
        "bottomPanel": bottomPanel,
        "playButton": playButton,
        "pauseButton": pauseButton,
        "settingButton": settingButton,
        "fullscreenButton": fullscreenButton,
        "currentTimeLabel": currentTimeLabel,
        "totalDurationLabel": totalDurationLabel,
        "mediaProcessSlider": mediaProcessSlider,
        "loadingIndicatorView": loadingIndicatiorView,
        "backButton": backButton,
        "titleLabel": titleLabel,
        "subTitleLabel": subTitleLabel,
        "adsView": adsView,
        "prevButton": prevButton,
        "nextButton": nextButton]
        
        let metrics = ["buttonWH": 32,
            "topPanelHeight": 44,
            "bottomPanelHeight": 32,
            "playButtonWH": 44,
            "pauseButtonWH": 44,
            "prevButtonWH": 32,
            "nextButtonWH": 32,
            "loadingIndicatorViewWH": 44,
            "adsViewHeight": 50,
            "adsViewWidth": 320]
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[overlayPanel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[overlayPanel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[topPanel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[topPanel(topPanelHeight)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[bottomPanel]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[bottomPanel(bottomPanelHeight)]|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        
        self.topPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[backButton(buttonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.topPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[backButton(buttonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.topPanel.addConstraints([
            NSLayoutConstraint(item: backButton, attribute: .CenterY, relatedBy: .Equal, toItem: topPanel, attribute: .CenterY, multiplier: 1.0, constant: 0)
            ])
        self.topPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|-[titleLabel][subTitleLabel]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.topPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[backButton]-[titleLabel]-|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.topPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[backButton]-[subTitleLabel]-|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        
        self.bottomPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|-[currentTimeLabel]-[mediaProcessSlider]-[totalDurationLabel]-[fullscreenButton(buttonWH)]-|", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.bottomPanel.addConstraints([
//            NSLayoutConstraint(item: settingButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: fullscreenButton, attribute: .CenterY, relatedBy: .Equal, toItem: bottomPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: currentTimeLabel, attribute: .CenterY, relatedBy: .Equal, toItem: bottomPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: mediaProcessSlider, attribute: .CenterY, relatedBy: .Equal, toItem: bottomPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: totalDurationLabel, attribute: .CenterY, relatedBy: .Equal, toItem: bottomPanel, attribute: .CenterY, multiplier: 1.0, constant: 0)
            ])
        
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[prevButton(prevButtonWH)]-32-[playButton(playButtonWH)]-32-[nextButton(nextButtonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[playButton(playButtonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[prevButton(prevButtonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[nextButton(nextButtonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[pauseButton(pauseButtonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[pauseButton(pauseButtonWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.overlayPanel.addConstraints([
            NSLayoutConstraint(item: playButton, attribute: .CenterY, relatedBy: .Equal, toItem: overlayPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: prevButton, attribute: .CenterY, relatedBy: .Equal, toItem: overlayPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: nextButton, attribute: .CenterY, relatedBy: .Equal, toItem: overlayPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: playButton, attribute: .CenterX, relatedBy: .Equal, toItem: overlayPanel, attribute: .CenterX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: pauseButton, attribute: .CenterY, relatedBy: .Equal, toItem: overlayPanel, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: pauseButton, attribute: .CenterX, relatedBy: .Equal, toItem: overlayPanel, attribute: .CenterX, multiplier: 1.0, constant: 0)
            ])
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[loadingIndicatorView(loadingIndicatorViewWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[loadingIndicatorView(loadingIndicatorViewWH)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.addConstraints([
            NSLayoutConstraint(item: loadingIndicatiorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: loadingIndicatiorView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: loadingIndicatiorView, attribute: .CenterY, relatedBy: .Equal, toItem: self, attribute: .CenterY, multiplier: 1.0, constant: 0),
            NSLayoutConstraint(item: loadingIndicatiorView, attribute: .CenterX, relatedBy: .Equal, toItem: self, attribute: .CenterX, multiplier: 1.0, constant: 0)
            ])
        
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:[adsView(adsViewWidth)]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
        self.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:[adsView(adsViewHeight)][bottomPanel]", options: NSLayoutFormatOptions(), metrics: metrics, views: views))
    }
    
    func checkVideoState() {
            switch self.delegatePlayer.loadState {
            case MPMovieLoadState.Playable:
                self.loadingIndicatiorView.hidden = false
                break
            case MPMovieLoadState.PlaythroughOK:
                self.loadingIndicatiorView.hidden = true
                break
            case MPMovieLoadState.Stalled:
                self.loadingIndicatiorView.hidden = false
                break
            case MPMovieLoadState.Unknown:
                self.loadingIndicatiorView.hidden = false
                break
            default:
                self.loadingIndicatiorView.hidden = true
                break
            }
    }
    
    func setTimerToHideControl() {
        self.timerToHideControl.invalidate()
        self.timerToHideControl = NSTimer.scheduledTimerWithTimeInterval(8, target: self, selector: #selector(self.hide), userInfo: nil, repeats: false)
    }
    
    func show() {
        self.overlayPanel.alpha = 0
        self.overlayPanel.hidden = false
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.overlayPanel.alpha = 1
            }) { (Bool) -> Void in
                self.refreshMediaControl()
                self.setTimerToHideControl()
        }
    }
    
    func hide() {
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.overlayPanel.alpha = 0
            }) { (Bool) -> Void in
                self.overlayPanel.hidden = true
                self.timerToHideControl.invalidate()
        }
    }
    
    func refreshMediaControl() {
        // duration
        let duration = self.delegatePlayer.duration
        if duration > 0 {
            self.mediaProcessSlider.maximumValue = Float(duration)
            self.totalDurationLabel.text = TubeTrends.formatTimeFromSeconds(duration)
        } else {
            self.totalDurationLabel.text = "--:--"
            self.mediaProcessSlider.maximumValue = 1.0
        }
        
        // position
        var position: Float = 0
        if (isMediaSliderBeingDragged) {
            position = self.mediaProcessSlider.value
        } else {
            position = Float(self.delegatePlayer.currentPlaybackTime)
        }
        
        if position > 0 {
            self.mediaProcessSlider.value = position
        } else {
            self.mediaProcessSlider.value = 0
        }
        
        self.currentTimeLabel.text = TubeTrends.formatTimeFromSeconds(Double(position))
        
        // status
        let isPlaying: Bool! = (self.delegatePlayer.playbackState == MPMoviePlaybackState.Playing)
        self.playButton.hidden = isPlaying
        self.pauseButton.hidden = !isPlaying
        
        self.checkVideoState()
        
        NSObject .cancelPreviousPerformRequestsWithTarget(self, selector: #selector(self.refreshMediaControl), object: nil)
//        if (!self.overlayPanel.hidden) {
            self.performSelector(#selector(self.refreshMediaControl), withObject: nil, afterDelay: 0.5)
//        }
    }
    
    func updateOverlayPanel() {
        if overlayPanel.hidden {
            self.show()
        } else {
            self.hide()
        }
    }
    
    func beginDragMediaSlider() {
        isMediaSliderBeingDragged = true
    }
    
    func endDragMediaSlider() {
        isMediaSliderBeingDragged = false
        self.setTimerToHideControl()
    }
    
    func continueDragMediaSlider() {
        self.delegatePlayer.currentPlaybackTime = Double(self.mediaProcessSlider.value)
        self.delegatePlayer.play()
        refreshMediaControl()
    }
    
    func playButtonTapped(button: UIButton) {
        self.delegatePlayer.play()
        self.refreshMediaControl()
        self.setTimerToHideControl()
    }
    
    func pauseButtonTapped(button: UIButton) {
        self.delegatePlayer.pause()
        self.setTimerToHideControl()
        self.delegate?.videoPlayerControl(self, pauseButtonDidTapped: button)
    }
    
    func backButtonTapped(button: UIButton) {
        self.setTimerToHideControl()
        self.delegate?.videoPlayerControl(self, backButtonDidTapped: button)
    }
    
    func settingButtonTapped(button: UIButton) {
        self.setTimerToHideControl()
        self.delegate?.videoPlayerControl(self, settingButtonDidTapped: button)
    }
    
    func fullscreenButtonTapped(button: UIButton) {
        self.setTimerToHideControl()
        if UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation) {
            let value = UIInterfaceOrientation.Portrait.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        } else {
            let value = UIInterfaceOrientation.LandscapeRight.rawValue
            UIDevice.currentDevice().setValue(value, forKey: "orientation")
        }
        self.delegate?.videoPlayerControl(self, fullscreenButtonDidTapped: button)
    }
    
    func nextButtonTapped(button: UIButton) {
        self.setTimerToHideControl()
        self.delegate?.videoPlayerControl(self, nextButtonDidTapped: button)
    }
    
    func prevButtonTapped(button: UIButton) {
        self.setTimerToHideControl()
        self.delegate?.videoPlayerControl(self, prevButtonDidTapped: button)
    }
    
    func movieRegisterObservers() {
        
    }
    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */

}
