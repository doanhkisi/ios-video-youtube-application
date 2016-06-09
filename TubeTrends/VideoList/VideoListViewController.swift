//
//  VideoListViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
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

class VideoListViewController: V2TTableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {
    
    let videoCellReuseableIdentifier = "videoCell"
    
    var videos = Items()
    var viewDidLoadHandler: (Void -> Void)?
    var scrollViewDidEndDraggingHandler: (Void -> Void)?
    var refreshListHander: (Void -> Void)?
    var didSelectedCellItem: ((NSIndexPath,Item) -> Void)?
    var extraButtonAtCellTappedHandler: ((VideoTableViewCell) -> Void)?
    var swipeRefreshControl: CarbonSwipeRefresh!
    var hilightPlaying: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.tableView.emptyDataSetSource = self
        self.tableView.emptyDataSetDelegate = self
        self.tableView.tableFooterView = UIView()
        
        self.view.backgroundColor = UIColor(rgba: "#212121")
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.estimatedRowHeight = 90
        automaticallyAdjustsScrollViewInsets = true
        self.tableView.contentInset = UIEdgeInsetsZero
        
        swipeRefreshControl = CarbonSwipeRefresh.init(scrollView: self.tableView)
        swipeRefreshControl.colors = [UIColor(rgba: "#FF2D55")]
        swipeRefreshControl.addTarget(self, action: #selector(self.refreshList(_:)), forControlEvents: UIControlEvents.ValueChanged)
        self.view.addSubview(swipeRefreshControl)
        
        let playAllListButtonItem = UIBarButtonItem(image: UIImage.fontAwesomeIconWithName(FontAwesome.Play, textColor: TubeTrends.Settings.foregroundColor, size: CGSize(width: 26, height: 26)), style: .Plain, target: self, action: #selector(self.playAllList(_:)))
        navigationItem.rightBarButtonItem = playAllListButtonItem
        navigationItem.rightBarButtonItem?.enabled = false
        
        viewDidLoadHandler?()
        
        self.registerObserver(UIDeviceOrientationDidChangeNotification, object: nil, queue: nil) { (noti) -> Void in
            self.tableView.reloadData()
        }
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
        return videos.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(videoCellReuseableIdentifier, forIndexPath: indexPath) as! VideoTableViewCell
        cell.video = videos.items[indexPath.row]
        cell.extraButtonTappedHandler = extraButtonAtCellTappedHandler
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(rgba: "#424242")
        cell.selectedBackgroundView = backgroundView
        if TubeTrends.sharedVideoDetailVC?.video.id == cell.video.id && hilightPlaying {
            cell.contentView.backgroundColor = UIColor(rgba: "#424242")
            cell.musicIndicator.hidden = false
        } else {
            cell.musicIndicator.hidden = true
            cell.contentView.backgroundColor = UIColor(rgba: "#212121")
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        if let didSelectedCellItem = didSelectedCellItem {
            didSelectedCellItem(indexPath, videos.items[indexPath.row])
        } else {
            self.playVideo(videos.items[indexPath.row], playlist: nil)
        }
        tableView.reloadData()
    }
    
    override func scrollViewDidEndDragging(scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        let currentOffset = scrollView.contentOffset.y
        let maximumOffset = scrollView.contentSize.height - scrollView.frame.size.height
        if (maximumOffset - currentOffset <= 100) {
            scrollViewDidEndDraggingHandler?()
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
    
    // MARK: Navigation bar button
    func playAllList(button: UIBarButtonItem) {
        if self.videos.items.count > 0 {
            playVideo(self.videos.items[0], playlist: videos)
        }
    }
    
    // MARK: SwipeRefreshControl delegate
    func refreshList(swipeRefreshControl: CarbonSwipeRefresh) {
        if refreshListHander != nil {
            refreshListHander?()
        } else {
            swipeRefreshControl.endRefreshing()
        }
    }
    
    // MARK: - DZNEmptyDataSetSource
    
    func buttonTitleForEmptyDataSet(scrollView: UIScrollView!, forState state: UIControlState) -> NSAttributedString! {
        let string = NSLocalizedString("Tap here to reload data.", comment: "")
        let attributes = [NSFontAttributeName: UIFont.boldSystemFontOfSize(16),
            NSForegroundColorAttributeName: UIColor.grayColor()]
        return NSAttributedString(string: string, attributes: attributes)
    }
    
    func imageForEmptyDataSet(scrollView: UIScrollView!) -> UIImage! {
        return UIImage.fontAwesomeIconWithName(FontAwesome.Film, textColor: UIColor(rgba: "#E0E0E0"), size: CGSize(width: 80, height: 80))
    }
    
    func emptyDataSetDidTapButton(scrollView: UIScrollView!) {
        viewDidLoadHandler?()
    }
    
    // MARK: - Private function
    
    func playVideo(video: Item, playlist: Items?) {
        var oldPlaylist = TubeTrends.sharedVideoDetailVC?.playlist
        TubeTrends.sharedVideoDetailVC?.remove()
        TubeTrends.sharedVideoDetailVC = nil
        TubeTrends.sharedVideoDetailVC = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("VideoDetail") as? VideoDetailViewController
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        TubeTrends.sharedVideoDetailVC?.video = video
        if let playlist = playlist {
            TubeTrends.sharedVideoDetailVC?.playlist = playlist
        } else {
            if oldPlaylist == nil {
                oldPlaylist = Items()
            }
            TubeTrends.sharedVideoDetailVC?.playlist = oldPlaylist
            if TubeTrends.sharedVideoDetailVC?.playlist.items.count > TubeTrends.Settings.videoPlaylistLimit {
                TubeTrends.sharedVideoDetailVC?.playlist.items.removeAtIndex(0)
            }
            if let list = TubeTrends.sharedVideoDetailVC?.playlist.items {
                for item in list {
                    if item == video {
                        list.removeAtIndex(list.indexOf(item)!)
                    }
                }
            }
            TubeTrends.sharedVideoDetailVC?.playlist.items.append(video)
        }
        TubeTrends.sharedVideoDetailVC?.showInViewController((appDelegate.window?.rootViewController)!)
    }

}
