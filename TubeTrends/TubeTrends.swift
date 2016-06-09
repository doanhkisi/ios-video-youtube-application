//
//  TubeTrends.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/21/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import Alamofire
import RealmSwift
import FontAwesome_swift
import QorumLogs
import SSSnackbar
import SwiftyJSON

class TubeTrends: NSObject {
    
    enum VideoQuality: String {
//        case k1080p = "1080p"
        case k720p = "720p"
        case k360p = "360p"
        case k240p = "240p"
    }
    
    class Notifications {
        static let searchButtonDidTapped = "searchButtonDidTapped"
    }
    
    class Constants {
        static let historiesListName = "Histories"
        static let downloadListName = "Downloads"
        static let favoritesListName = "Favorites"
    }
    
    class Settings {
        static let foregroundColor = UIColor(rgba: "#FF2D55")
        static let menuIconSize = CGSize(width: 20, height: 20)
        static let videoPlaylistLimit = 500
        static let favoritesLimitCount = 500
        static let historiesLimitCount = 500
        static let videoPerPlaylistLimitCount = 50
        static let playlistLimitCount = 13
        
        static var videoQuality: VideoQuality {
            get {
            let defaults = NSUserDefaults.standardUserDefaults()
            if let quality = defaults.stringForKey("videoQualitySetting")
        {
            return VideoQuality(rawValue: quality)!
        } else {
            return VideoQuality.k720p
            }
            }
            
            set {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(newValue.rawValue, forKey: "videoQualitySetting")
            }
        }
        
        static var playVideoInBackground: Bool {
            get {
            let defaults = NSUserDefaults.standardUserDefaults()
            return defaults.boolForKey("playVideoInBackgroundSetting")
            }
            
            set {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(newValue, forKey: "playVideoInBackgroundSetting")
            }
        }
        
        static var userCountryCode: String {
            get {
                let defaults = NSUserDefaults.standardUserDefaults()
                if let userCode = defaults.stringForKey("userCountryCodeSetting") {
                    return userCode
                } else {
                    return TubeTrends.Settings.defaultCountryCode
                }
            }
            
            set {
                let defaults = NSUserDefaults.standardUserDefaults()
                defaults.setObject(newValue, forKey: "userCountryCodeSetting")
            }
        }
        
//        static var globalJSON: JSON?
        static var shareVideoLink: String {
            return "https://youtube.apps.v2t.mobi/?v="
        }
        static var isShowDownloadFunction: Bool {
            return true
        }
        static var isShowSearchFunction: Bool {
            return true
        }
        static var defaultCountryCode: String {
            return "US"
        }
        static var topPlaylistKeyword: String {
            return "vevo music"
        }
        static var topTrendsCat: Int {
            return 10
        }
        static var secretKeyApi: [String] {
            let keyArray = ["xxx------Your_YOUTUBE_API_Key---------xxx"]
            return keyArray
        }
    }
    
    static let realm = try! Realm()
    
    static var sharedVideoDetailVC: VideoDetailViewController?
    
    class func formatTimeFromSeconds(totalSeconds: Double) -> String {
        if !totalSeconds.isNaN {
            let hours: Int = Int(totalSeconds / 3600)
            let seconds: Int = Int(totalSeconds % 60)
            let minutes: Int = Int((totalSeconds / 60) % 60)
            return (hours > 0 ? String(hours) + ":" : "") + (minutes < 10 ? "0" + String(minutes) : String(minutes)) + ": " + (seconds < 10 ? "0" + String(seconds) : String(seconds))
        } else {
            return ""
        }
    }
    
    class func downloadStreaming(url: String, fileName: String?, onProgress: ((Int64, Int64, Int64) -> Void)?, completionHandler: (String -> Void)?) {
        
        let fileManager = NSFileManager.defaultManager()
        let directoryURL = fileManager.URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)[0]
        let typePath = "Downloads"
        let dataPath = directoryURL.URLByAppendingPathComponent(typePath)
        var fileName = fileName
        
        if !fileManager.fileExistsAtPath(dataPath.path!) {
            do {
                try fileManager.createDirectoryAtPath(dataPath.path!, withIntermediateDirectories: false, attributes: nil)
            } catch let error as NSError {
                debugPrint(error.localizedDescription)
            }
        }
        
        Alamofire.download(.GET, url, destination: { temporaryURL, response in
            if let name = response.suggestedFilename {
                if fileName == nil {
                    fileName = name
                } else {
                    fileName = fileName! + "." + NSString(string: name).pathExtension
                }
                if fileManager.fileExistsAtPath(dataPath.URLByAppendingPathComponent(fileName!).path!) {
                    let tempName: NSString = fileName!
                    fileName = tempName.stringByDeletingPathExtension + "_copy." + tempName.pathExtension
                }
            }
            return dataPath.URLByAppendingPathComponent(fileName!)
        })
            .progress { bytesRead, totalBytesRead, totalBytesExpectedToRead in
                onProgress?(bytesRead, totalBytesRead, totalBytesExpectedToRead)
                debugPrint(totalBytesRead)
                // This closure is NOT called on the main queue for performance
                // reasons. To update your ui, dispatch to the main queue.
                dispatch_async(dispatch_get_main_queue()) {
                    debugPrint("Total bytes read on main queue: \(totalBytesRead)")
                }
            }
            .response { _, response, _, error in
                if let error = error {
                    debugPrint("Failed with error: \(error)")
                } else {
                    debugPrint("Downloaded file successfully")
                    debugPrint(dataPath.URLByAppendingPathComponent(fileName!))
                    completionHandler?(typePath + "/" + fileName!)
                }
        }
    }
    
    class func showExtraOptionOnlineCell(cell: VideoTableViewCell) {
        TubeTrends.showExtraOptionOnlineVideo(cell.video)
    }
    
    class func showExtraOptionOnlineVideo(video: Item) {
        var items: [BottomMenuViewItem] = []
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToFavorites(video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.ListOL, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to queue", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToQueue(video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.List, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToPlaylist(video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.ShareAlt, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Share...", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.shareVideo(video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.AngleDown, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        bottomMenu.showInViewController((appDelegate.window?.rootViewController)!)
    }
    
    class func showExtraOptionPlaylistVideo(cell: VideoTableViewCell) {
        var items: [BottomMenuViewItem] = []
        if let id = TubeTrends.sharedVideoDetailVC?.video.id {
            if cell.video.id != id {
                items.append(BottomMenuViewItem(icon:
                    UIImage.fontAwesomeIconWithName(FontAwesome.Trash, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Remove from queue", comment: ""), selectedAction: { (Void) -> Void in
                        if let index = TubeTrends.sharedVideoDetailVC?.playlistVideoListVC.tableView.indexPathForCell(cell)?.row {
                            TubeTrends.sharedVideoDetailVC?.playlist.items.removeAtIndex(index)
                            TubeTrends.sharedVideoDetailVC?.playlistVideoListVC.tableView.reloadData()
                        }
                }))
            }
        }
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToFavorites(cell.video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.List, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.addVideoToPlaylist(cell.video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.ShareAlt, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Share...", comment: ""), selectedAction: { (Void) -> Void in
                TubeTrends.shareVideo(cell.video)
        }))
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.AngleDown, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        bottomMenu.showInViewController((appDelegate.window?.rootViewController)!)
    }
    
    class func addVideoToQueue(video: Item) {
        TubeTrends.sharedVideoDetailVC?.playlist.items.append(video)
        TubeTrends.sharedVideoDetailVC?.playlistVideoListVC.tableView.reloadData()
        let snackBar = SSSnackbar.init(message: NSLocalizedString("Added to queue", comment: ""), actionText:nil, duration: 1, actionBlock: nil, dismissalBlock: nil)
        snackBar.show()
    }
    
    class func addVideoToPlaylist(video: Item) {
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        var items: [BottomMenuViewItem] = []
        let playlists = TubeTrends.realm.objects(Items).filter("name != 'Favorites' && name != 'Histories' && name != 'Downloads'")
        for playlist in playlists {
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.List, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("\(playlist.name)", comment: ""), selectedAction: { (Void) -> Void in
                    try! TubeTrends.realm.write({
                        playlist.items.append(video)
                    })
            }))
        }
        if playlists.count < (TubeTrends.Settings.playlistLimitCount - 3) { // if playlist count equal limited playlist count, user can't create new playlist
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Plus, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Create new playlist...", comment: ""), selectedAction: { (Void) -> Void in
                    let popup = PopUpViewController(size: CGSize(width: 280, height: 120))
                    let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                    let createNewPlaylistVC = storyboard.instantiateViewControllerWithIdentifier("CreateNewPlaylist") as! CreateNewPlaylistViewController
                    popup.addChildViewController(createNewPlaylistVC)
                    popup.viewContainer.addSubview(createNewPlaylistVC.view)
                    createNewPlaylistVC.view.translatesAutoresizingMaskIntoConstraints = false
                    popup.viewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[createNewPlaylistView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["createNewPlaylistView": createNewPlaylistVC.view]))
                    popup.viewContainer.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[createNewPlaylistView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["createNewPlaylistView": createNewPlaylistVC.view]))
                    createNewPlaylistVC.cancelButtonTappedHandler = {
                        popup.hide()
                    }
                    createNewPlaylistVC.createdPlaylistHandler = { playlist in
                        playlist.items.append(video)
                        popup.hide()
                    }
                    popup.showInViewController((appDelegate.window?.rootViewController)!)
            }))
        }
        items.append(BottomMenuViewItem(icon:
            UIImage.fontAwesomeIconWithName(FontAwesome.AngleDown, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Cancel", comment: ""), selectedAction: { (Void) -> Void in
                
        }))
        let bottomMenu = BottomMenuView(items: items, didSelectedHandler: nil)
        bottomMenu.showInViewController((appDelegate.window?.rootViewController)!)
    }
    
    class func addVideoToFavorites(video: Item) {
        let videos = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items
        if videos.filter("id = '\(video.id)'").count == 0 {
            if videos.count <= Settings.favoritesLimitCount {
                try! TubeTrends.realm.write() {
                    video.createdAt = NSDate()
                    video.modifiedAt = NSDate()
                    videos.append(video)
                    QL1("Video \(video.title) was added to favorites.")
                }
            } else {
                let snackBar = SSSnackbar.init(message: NSLocalizedString("You only can add \(Settings.favoritesLimitCount) videos", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                snackBar.show()
            }
        }
    }
    
    class func shareVideo(video: Item) {
        let shareString = NSLocalizedString("I'm watching video at ", comment: "") + TubeTrends.Settings.shareVideoLink + video.id
        let activityViewController = UIActivityViewController(activityItems: [shareString], applicationActivities: nil)
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        appDelegate.window?.rootViewController!.presentViewController(activityViewController, animated: true, completion: {})
    }
}
