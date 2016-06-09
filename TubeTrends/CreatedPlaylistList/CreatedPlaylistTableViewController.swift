//
//  CreatedPlaylistTableViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/17/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import RealmSwift
import UIColor_Hex_Swift
import XCDYouTubeKit
import DZNEmptyDataSet
import FontAwesome_swift
import CarbonKit
import AutoScrollLabel

class CreatedPlaylistTableViewController: UITableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {
    
    private let reuseableCellIdentifiler = "cell"
    
    var playlists: Results<Items>?
    var swipeRefreshControl: CarbonSwipeRefresh!

    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = NSLocalizedString("Playlist", comment: "")
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        swipeRefreshControl = CarbonSwipeRefresh.init(scrollView: self.tableView)
        swipeRefreshControl.colors = [UIColor(rgba: "#FF2D55")]
        swipeRefreshControl.addTarget(self, action: #selector(self.refreshList(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(swipeRefreshControl)
        
        self.playlists = TubeTrends.realm.objects(Items).filter("name != 'Favorites' && name != 'Histories' && name != 'Downloads'")
        self.tableView.reloadData()
        self.swipeRefreshControl.endRefreshing()
        
        let editButtonItem = UIBarButtonItem(title: NSLocalizedString("Edit", comment: ""), style: .Plain, target: self, action: #selector(self.editPlaylistButtonTapped(_:)))
        navigationItem.rightBarButtonItem = editButtonItem
//        navigationItem.rightBarButtonItem?.enabled = false

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }
    
    override func viewWillAppear(animated: Bool) {
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if let playlists = self.playlists {
            return playlists.count
        } else {
            return 0
        }
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseableCellIdentifiler, forIndexPath: indexPath)
        cell.textLabel?.text = playlists![indexPath.row].name
        cell.detailTextLabel?.text = "\(playlists![indexPath.row].items.count) video(s)"
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(rgba: "#424242")
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let videoListVC = self.videoListVC(playlists![indexPath.row])
        //        playlistVideoVC.title = self.playlists.items[indexPath.row].title
        
        let titleLabel = CBAutoScrollLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 44))
        titleLabel.text = playlists![indexPath.row].name
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.labelSpacing = 35
        titleLabel.pauseInterval = 3.7
        titleLabel.scrollSpeed = 30
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.fadeLength = 12
        videoListVC.navigationItem.titleView = titleLabel
        
        self.navigationController?.pushViewController(videoListVC, animated: true)
    }
    
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            try! TubeTrends.realm.write({ () -> Void in
                TubeTrends.realm.delete(playlists![indexPath.row])
                self.tableView.reloadData()
            })
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(tableView: UITableView, canEditRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(tableView: UITableView, commitEditingStyle editingStyle: UITableViewCellEditingStyle, forRowAtIndexPath indexPath: NSIndexPath) {
        if editingStyle == .Delete {
            // Delete the row from the data source
            tableView.deleteRowsAtIndexPaths([indexPath], withRowAnimation: .Fade)
        } else if editingStyle == .Insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(tableView: UITableView, moveRowAtIndexPath fromIndexPath: NSIndexPath, toIndexPath: NSIndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(tableView: UITableView, canMoveRowAtIndexPath indexPath: NSIndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    // MARK: - Navigation bar button action
    func editPlaylistButtonTapped(sender: UIBarButtonItem) {
        if self.tableView.editing {
            self.tableView.setEditing(false, animated: true)
            navigationItem.rightBarButtonItem?.title = NSLocalizedString("Edit", comment: "")
        } else {
            self.tableView.setEditing(true, animated: true)
            navigationItem.rightBarButtonItem?.title = NSLocalizedString("Done", comment: "")
        }
    }
    
    // MARK: SwipeRefreshControl delegate
    func refreshList(swipeRefreshControl: CarbonSwipeRefresh) {
        self.playlists = TubeTrends.realm.objects(Items).filter("name != 'Favorites' && name != 'Histories' && name != 'Downloads'")
        self.tableView.reloadData()
        swipeRefreshControl.endRefreshing()
    }
    
    // MARK: - DZNEmptyDataSetSource
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let string = NSLocalizedString("Create new playlist.", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
            NSForegroundColorAttributeName: UIColor.grayColor()]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIconWithName(FontAwesome.Film, textColor: UIColor(rgba: "#E0E0E0"), size: CGSize(width: 80, height: 80))
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
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
        createNewPlaylistVC.addButtonTappedHandler = {
            popup.hide()
            self.playlists = TubeTrends.realm.objects(Items).filter("name != 'Favorites' && name != 'Histories' && name != 'Downloads'")
            self.tableView.reloadData()
        }
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        popup.showInViewController((appDelegate.window?.rootViewController)!)
    }
    
    // MARK: - Private function
    private func videoListVC(playlist: Items) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.title = NSLocalizedString("Favorites", comment: "")
        videoListVC.viewDidLoadHandler = {
            videoListVC.videos = playlist
            videoListVC.tableView.reloadData()
            videoListVC.navigationItem.rightBarButtonItem?.enabled = true
        }
        videoListVC.refreshListHander = {
            videoListVC.videos = playlist
            videoListVC.tableView.reloadData()
            videoListVC.swipeRefreshControl.endRefreshing()
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            var items: [BottomMenuViewItem] = []
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Trash, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Delete", comment: ""), selectedAction: { (Void) -> Void in
                    dispatch_async(dispatch_get_main_queue()) {
                        autoreleasepool {
                            try! TubeTrends.realm.write() {
                                playlist.items.removeAtIndex(playlist.items.indexOf(cell.video)!)
                                videoListVC.tableView.reloadData()
                            }
                        }
                    }
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.Heart, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to favorites", comment: ""), selectedAction: { (Void) -> Void in
                    TubeTrends.addVideoToFavorites(cell.video)
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.ListOL, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to queue", comment: ""), selectedAction: { (Void) -> Void in
                    TubeTrends.addVideoToQueue(cell.video)
            }))
            items.append(BottomMenuViewItem(icon:
                UIImage.fontAwesomeIconWithName(FontAwesome.List, textColor: UIColor(rgba: "#FF2D55"), size: CGSize(width: 20, height: 20)), title: NSLocalizedString("Add to playlist", comment: ""), selectedAction: { (Void) -> Void in
                    
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
        return videoListVC
    }

}
