//
//  PersonalViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/28/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import FontAwesome_swift
import QorumLogs
import SSSnackbar
import MessageUI

class PersonalMenuViewController: V2TTableViewController, MFMailComposeViewControllerDelegate {
    
    private let cellIdentifier = "menuCell"
    private let headerCellIdentifier = "headerCell"
    
    class MenuItem: NSObject {
        var icon: UIImage?
        var title: String = ""
        var hidden: Bool = false
        var action: (NSIndexPath -> Void)?
        init(icon: UIImage, title: String, action: (NSIndexPath -> Void)?) {
            super.init()
            self.icon = icon
            self.title = title
            self.action = action
        }
    }
    
    var menus: [[String: AnyObject]] {
        return [
            ["name": NSLocalizedString("General", comment: ""),
                "items": [
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Favorites", comment: ""), action: { (indexPath) -> Void in
                        self.navigationController?.pushViewController(self.favoritesVideoListVC(), animated: true)
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.Film, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("My Videos", comment: ""), action: { (indexPath) -> Void in
                        self.navigationController?.pushViewController(self.downloadsVideoListVC(), animated: true)
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.History, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Histories", comment: ""), action: { (indexPath) -> Void in
                        self.navigationController?.pushViewController(self.historiesVideoListVC(), animated: true)
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.List, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Playlists", comment: ""), action: { (indexPath) -> Void in
                        self.navigationController?.pushViewController(self.createdPlaylistListVC(), animated: true)
                    }),
                ]
            ],
            ["name": NSLocalizedString("Extra", comment: ""),
                "items": [
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.Cog, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Settings", comment: ""), action: { (indexPath) -> Void in
                        self.navigationController?.pushViewController(self.settingsVC(), animated: true)
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.Flag, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Tutorial", comment: ""), action: { (indexPath) -> Void in
                        let link = "https://v2t.mobi"
                        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                        let webVC = storyboard.instantiateViewControllerWithIdentifier("WebViewController") as! V2TWebViewController
                        webVC.linkString = link
                        webVC.title = NSLocalizedString("Tutorials", comment: "")
                        let navVC = V2TNavigationController(rootViewController: webVC)
                        self.navigationController?.presentViewController(navVC, animated: true, completion: { () -> Void in
                            //
                        })
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.Info, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Helps & Feedbacks", comment: ""), action: { (indexPath) -> Void in
                        
                        let mailComposeViewController = self.configuredMailComposeViewController()
                        if MFMailComposeViewController.canSendMail() {
                            self.presentViewController(mailComposeViewController, animated: true, completion: nil)
                        } else {
                            self.showSendMailErrorAlert()
                        }
                        
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.Star, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Rate & review", comment: ""), action: { (indexPath) -> Void in
                        let url = NSURL(string: "https://itunes.apple.com/us/app/video-yt-youtuble-playlist/id1086349582?mt=8")!
                        UIApplication.sharedApplication().openURL(url)
                    }),
                    MenuItem(icon: UIImage.fontAwesomeIconWithName(FontAwesome.CartPlus, textColor: TubeTrends.Settings.foregroundColor, size: TubeTrends.Settings.menuIconSize), title: NSLocalizedString("Bonus Application", comment: ""), action: { (indexPath) -> Void in
                        self.navigationController?.pushViewController(self.bonousAppsVC(), animated: true)
                    }),
                ]
            ]
        ]
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - Table view data source
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return menus.count
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        let items = self.menus[section]["items"]
        return items!.count
    }
    
    override func tableView(tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerCell = tableView.dequeueReusableCellWithIdentifier(headerCellIdentifier)!
        headerCell.textLabel?.text = menus[section]["name"] as? String
        headerCell.backgroundColor = UIColor(rgba: "#424242")
        return headerCell
    }
    
    override func tableView(tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 44
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier, forIndexPath: indexPath) as UITableViewCell
        let menu: MenuItem = (menus[indexPath.section]["items"] as! Array)[indexPath.row]
        cell.imageView?.image = menu.icon
        cell.textLabel?.text = menu.title
        
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(rgba: "#424242")
        cell.selectedBackgroundView = backgroundView
        cell.backgroundColor = UIColor.clearColor()
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let menu: MenuItem = (menus[indexPath.section]["items"] as! Array)[indexPath.row]
        menu.action?(indexPath)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Private function
    private func favoritesVideoListVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.title = NSLocalizedString("Favorites", comment: "")
        videoListVC.viewDidLoadHandler = {
            let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items.sorted("createdAt", ascending: false)
            let videos = Items()
            videos.items.appendContentsOf(videoItems)
            videoListVC.videos = videos
            videoListVC.tableView.reloadData()
            videoListVC.navigationItem.rightBarButtonItem?.enabled = true
        }
        videoListVC.refreshListHander = {
            let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items.sorted("createdAt", ascending: false)
            let videos = Items()
            videos.items.appendContentsOf(videoItems)
            videoListVC.videos = videos
            videoListVC.tableView.reloadData()
            videoListVC.swipeRefreshControl.endRefreshing()
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            var items: [BottomMenuViewItem] = []
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Trash, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Delete", comment: ""), selectedAction: { (Void) -> Void in
                    let videos = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items
                    for i in 0...videos.count - 1 {
                        if videos[i].id == cell.video.id {
                            dispatch_async(dispatch_get_main_queue()) {
                                autoreleasepool {
                                    try! TubeTrends.realm.write() {
                                        videos.removeAtIndex(i)
                                        let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items.sorted("modifiedAt", ascending: false)
                                        let videos = Items()
                                        videos.items.appendContentsOf(videoItems)
                                        videoListVC.videos = videos
                                        videoListVC.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.ListOL, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to queue", comment: ""), selectedAction: { (Void) -> Void in
                    TubeTrends.addVideoToQueue(cell.video)
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
        return videoListVC
    }
    
    private func downloadsVideoListVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.title = NSLocalizedString("Downloads", comment: "")
        videoListVC.viewDidLoadHandler = {
            let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.downloadListName)'")[0].items.sorted("createdAt", ascending: false)
            let videos = Items()
            videos.items.appendContentsOf(videoItems)
            videoListVC.videos = videos
            videoListVC.tableView.reloadData()
            videoListVC.navigationItem.rightBarButtonItem?.enabled = true
        }
        videoListVC.refreshListHander = {
            let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.downloadListName)'")[0].items.sorted("createdAt", ascending: false)
            let videos = Items()
            videos.items.appendContentsOf(videoItems)
            videoListVC.videos = videos
            videoListVC.tableView.reloadData()
            videoListVC.swipeRefreshControl.endRefreshing()
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            var items: [BottomMenuViewItem] = []
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Trash, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Delete", comment: ""), selectedAction: { (Void) -> Void in
                    let videos = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.downloadListName)'")[0].items
                    for i in 0...videos.count - 1 {
                        if videos[i].id == cell.video.id {
                            let fileManager = NSFileManager.defaultManager()
                            let directoryURL = NSHomeDirectory().stringByAppendingString("/Documents")
                            do {
                                try fileManager.removeItemAtPath(directoryURL + "/" + (videos[i].offlinePath))
                            }
                            catch let error as NSError {
                                print("Ooops! Something went wrong: \(error)")
                            }
                            dispatch_async(dispatch_get_main_queue()) {
                                autoreleasepool {
                                    try! TubeTrends.realm.write() {
                                        videos.removeAtIndex(i)
                                        let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.downloadListName)'")[0].items.sorted("modifiedAt", ascending: false)
                                        let videos = Items()
                                        videos.items.appendContentsOf(videoItems)
                                        videoListVC.videos = videos
                                        videoListVC.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                    let videos = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items
                    if videos.filter("id = '\(cell.video.id)'").count == 0 {
                        if videos.count <= TubeTrends.Settings.favoritesLimitCount {
                            try! TubeTrends.realm.write() {
                                cell.video.createdAt = NSDate()
                                cell.video.modifiedAt = NSDate()
                                videos.append(cell.video)
                                QL1("Video \(cell.video.title) was added to favorites.")
                            }
                        } else {
                            let snackBar = SSSnackbar.init(message: NSLocalizedString("You only can add \(TubeTrends.Settings.favoritesLimitCount) videos", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                            snackBar.show()
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.ListOL, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to queue", comment: ""), selectedAction: { (Void) -> Void in
                    TubeTrends.addVideoToQueue(cell.video)
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
        return videoListVC
    }
    
    private func historiesVideoListVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.title = NSLocalizedString("Histories", comment: "")
        videoListVC.viewDidLoadHandler = {
            let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.historiesListName)'")[0].items.sorted("modifiedAt", ascending: false)
            let videos = Items()
            videos.items.appendContentsOf(videoItems)
            videoListVC.videos = videos
            videoListVC.tableView.reloadData()
            videoListVC.navigationItem.rightBarButtonItem?.enabled = true
        }
        videoListVC.refreshListHander = {
            let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.historiesListName)'")[0].items.sorted("modifiedAt", ascending: false)
            let videos = Items()
            videos.items.appendContentsOf(videoItems)
            videoListVC.videos = videos
            videoListVC.tableView.reloadData()
            videoListVC.swipeRefreshControl.endRefreshing()
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            var items: [BottomMenuViewItem] = []
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Trash, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Delete", comment: ""), selectedAction: { (Void) -> Void in
                    let videos = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.historiesListName)'")[0].items
                    for i in 0...videos.count - 1 {
                        if videos[i].id == cell.video.id {
                            dispatch_async(dispatch_get_main_queue()) {
                                autoreleasepool {
                                    try! TubeTrends.realm.write() {
                                        videos.removeAtIndex(i)
                                        let videoItems = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.historiesListName)'")[0].items.sorted("modifiedAt", ascending: false)
                                        let videos = Items()
                                        videos.items.appendContentsOf(videoItems)
                                        videoListVC.videos = videos
                                        videoListVC.tableView.reloadData()
                                    }
                                }
                            }
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                    let videos = TubeTrends.realm.objects(Items).filter("name = '\(TubeTrends.Constants.favoritesListName)'")[0].items
                    if videos.filter("id = '\(cell.video.id)'").count == 0 {
                        if videos.count <= TubeTrends.Settings.favoritesLimitCount {
                            try! TubeTrends.realm.write() {
                                cell.video.createdAt = NSDate()
                                cell.video.modifiedAt = NSDate()
                                videos.append(cell.video)
                                QL1("Video \(cell.video.title) was added to favorites.")
                            }
                        } else {
                            let snackBar = SSSnackbar.init(message: NSLocalizedString("You only can add \(TubeTrends.Settings.favoritesLimitCount) videos", comment: ""), actionText: NSLocalizedString("OK", comment: ""), duration: 5, actionBlock: nil, dismissalBlock: nil)
                            snackBar.show()
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.ListOL, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to queue", comment: ""), selectedAction: { (Void) -> Void in
                    TubeTrends.addVideoToQueue(cell.video)
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
        return videoListVC
    }
    
    private func createdPlaylistListVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let createdPlaylistListVC = storyboard.instantiateViewControllerWithIdentifier("CreatedPlaylistList") as! CreatedPlaylistTableViewController
        return createdPlaylistListVC
    }
    
    private func settingsVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let settingsVC = storyboard.instantiateViewControllerWithIdentifier("SettingsView") as! SettingsViewController
        return settingsVC
    }
    
    private func bonousAppsVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let bonousAppsVC = storyboard.instantiateViewControllerWithIdentifier("MoreApps") as! MoreAppsViewController
        return bonousAppsVC
    }
    
    private func configuredMailComposeViewController() -> MFMailComposeViewController {
        let mailComposerVC = MFMailComposeViewController()
        mailComposerVC.mailComposeDelegate = self // Extremely important to set the --mailComposeDelegate-- property, NOT the --delegate-- property
        
        mailComposerVC.setToRecipients(["support@v2t.mobi"])
        mailComposerVC.setSubject("[VideoTrends-iOS] - Feedback")
        mailComposerVC.setMessageBody("VideoTrends application is interesting...", isHTML: false)
        
        return mailComposerVC
    }
    
    private func showSendMailErrorAlert() {
        let sendMailErrorAlert = UIAlertView(title: "Could Not Send Email", message: "Your device could not send e-mail.  Please check e-mail configuration and try again.", delegate: self, cancelButtonTitle: "OK")
        sendMailErrorAlert.show()
    }
    
    // MARK: MFMailComposeViewControllerDelegate Method
    func mailComposeController(controller: MFMailComposeViewController, didFinishWithResult result: MFMailComposeResult, error: NSError?) {
        controller.dismissViewControllerAnimated(true, completion: nil)
    }

}
