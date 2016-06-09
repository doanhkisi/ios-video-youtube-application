//
//  PlaylistListViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/2/16.
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

class PlaylistListViewController: V2TTableViewController, DZNEmptyDataSetSource, DZNEmptyDataSetDelegate  {

    let playlistCellReuseableIdentifier = "playlistCell"
    
    var playlists = Items()
    var viewDidLoadHandler: (Void -> Void)?
    var scrollViewDidEndDraggingHandler: (Void -> Void)?
    var refreshListHander: (Void -> Void)?
    var extraButtonAtCellTappedHandler: (Item -> Void)?
    var swipeRefreshControl: CarbonSwipeRefresh!
    
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
        return playlists.items.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(playlistCellReuseableIdentifier, forIndexPath: indexPath) as! PlaylistTableViewCell
        cell.playlist = playlists.items[indexPath.row]
        let backgroundView = UIView()
        backgroundView.backgroundColor = UIColor(rgba: "#424242")
        cell.selectedBackgroundView = backgroundView
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        let playlistVideoVC = self.playlistVideoVC(self.playlists.items[indexPath.row].id)
//        playlistVideoVC.title = self.playlists.items[indexPath.row].title
        
        let titleLabel = CBAutoScrollLabel(frame: CGRect(x: 0, y: 0, width: UIScreen.mainScreen().bounds.width, height: 44))
        titleLabel.text = self.playlists.items[indexPath.row].title
        titleLabel.textColor = UIColor.whiteColor()
        titleLabel.labelSpacing = 35
        titleLabel.pauseInterval = 3.7
        titleLabel.scrollSpeed = 30
        titleLabel.textAlignment = NSTextAlignment.Center
        titleLabel.fadeLength = 12
        playlistVideoVC.navigationItem.titleView = titleLabel

        self.navigationController?.pushViewController(playlistVideoVC, animated: true)
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
    
    // MARK: - private function
    private func playlistVideoVC(playlistId: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.viewDidLoadHandler = {
            videoListVC.swipeRefreshControl.startRefreshing()
            sharedYTAPI.getPlaylistItems(playlistId, videos: Items(), completionHandler: { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.navigationItem.rightBarButtonItem?.enabled = true // enable play all list button
                videoListVC.swipeRefreshControl.endRefreshing()
            })
        }
        videoListVC.didSelectedCellItem = { indexPath, video in
            videoListVC.playVideo(video, playlist: videoListVC.videos)
        }
        videoListVC.scrollViewDidEndDraggingHandler = {
            if let _ = videoListVC.videos.nextPage {
                sharedYTAPI.getPlaylistItems(playlistId, videos: videoListVC.videos, completionHandler: { (videos) -> Void in
                    videoListVC.videos = videos
                    videoListVC.tableView.reloadData()
                })
            }
        }
        videoListVC.refreshListHander = {
            sharedYTAPI.getPlaylistItems(playlistId, videos: Items(), completionHandler: { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.swipeRefreshControl.endRefreshing()
            })
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            TubeTrends.showExtraOptionOnlineCell(cell)
        }
        return videoListVC
    }

}
