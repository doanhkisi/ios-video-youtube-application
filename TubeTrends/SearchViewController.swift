//
//  SearchViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/15/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import CarbonKit

class SearchViewController: V2TViewController {
    
    @IBOutlet weak var resultView: UIView!
    @IBOutlet weak var searchOptionsSegment: UISegmentedControl!
    
    var query: String = ""
    
    let tabItems = [
        NSLocalizedString("Video", comment: ""),
        NSLocalizedString("Playlist", comment: ""),
        NSLocalizedString("Channel", comment: "")
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let tabSwipeNavigation = CarbonTabSwipeNavigation(items: tabItems, delegate: self)
        tabSwipeNavigation.view.backgroundColor = UIColor(rgba: "#212121")
        tabSwipeNavigation.setIndicatorColor(UIColor(rgba: "#FF2D55"))
        tabSwipeNavigation.setSelectedColor(UIColor(rgba: "#FF2D55"))
        tabSwipeNavigation.setNormalColor(UIColor(rgba: "#F5F5F5"))
        tabSwipeNavigation.setTabBarHeight(32)
        tabSwipeNavigation.carbonSegmentedControl?.backgroundColor = UIColor(rgba: "#212121")
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(UIScreen.mainScreen().bounds.width/3, forSegmentAtIndex: 0)
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(UIScreen.mainScreen().bounds.width/3, forSegmentAtIndex: 1)
        tabSwipeNavigation.carbonSegmentedControl?.setWidth(UIScreen.mainScreen().bounds.width/2.95, forSegmentAtIndex: 2)
        tabSwipeNavigation.setIndicatorHeight(2)
        tabSwipeNavigation.insertIntoRootViewController(self, andTargetView: self.view)

    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CarbonTabSwipeNavigationDelegate
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        switch index {
        case 0:
            return searchVideoListVC(query)
        case 1:
            return searchPlaylistVC(query)
        case 2:
            return searchChannelVC(query)
        default:
            break
        }
        return UIViewController()
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */
    
    private func searchVideoListVC(query: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.viewDidLoadHandler = {
            videoListVC.swipeRefreshControl.startRefreshing()
            sharedYTAPI.searchVideos(self.query, videos: Items(), completionHandler: { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.swipeRefreshControl.endRefreshing()
            })
        }
        videoListVC.scrollViewDidEndDraggingHandler = {
            if let _ = videoListVC.videos.nextPage {
                sharedYTAPI.searchVideos(self.query, videos: videoListVC.videos, completionHandler: { (videos) -> Void in
                    videoListVC.videos = videos
                    videoListVC.tableView.reloadData()
                })
            }
        }
        videoListVC.refreshListHander = {
            sharedYTAPI.searchVideos(self.query, videos: Items(), completionHandler: { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.swipeRefreshControl.endRefreshing()
            })
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            TubeTrends.showExtraOptionOnlineCell(cell)
        }
        
        videoListVC.registerObserver(TubeTrends.Notifications.searchButtonDidTapped, object: nil, queue: nil) { (noti) -> Void in
            videoListVC.swipeRefreshControl.startRefreshing()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            videoListVC.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            sharedYTAPI.searchVideos(self.query, videos: Items(), completionHandler: { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.swipeRefreshControl.endRefreshing()
            })
        }
        return videoListVC
    }
    
    private func searchPlaylistVC(query: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let playlistListVC = storyboard.instantiateViewControllerWithIdentifier("PlaylistList") as! PlaylistListViewController
        playlistListVC.viewDidLoadHandler = {
            playlistListVC.swipeRefreshControl.startRefreshing()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                sharedYTAPI.searchPlaylist(self.query, playlists: Items()) { (playlists) -> Void in
                    playlistListVC.playlists = playlists
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        playlistListVC.tableView.reloadData()
                        playlistListVC.swipeRefreshControl.endRefreshing()
                    })
                }
            })
        }
        playlistListVC.scrollViewDidEndDraggingHandler = {
            if let _ = playlistListVC.playlists.nextPage {
                sharedYTAPI.searchPlaylist(self.query, playlists: playlistListVC.playlists) { (playlists) -> Void in
                    playlistListVC.playlists = playlists
                    playlistListVC.tableView.reloadData()
                }
            }
        }
        playlistListVC.refreshListHander = {
            sharedYTAPI.searchPlaylist(self.query, playlists: Items()) { (playlists) -> Void in
                playlistListVC.playlists = playlists
                playlistListVC.tableView.reloadData()
                playlistListVC.swipeRefreshControl.endRefreshing()
            }
        }
        playlistListVC.extraButtonAtCellTappedHandler = { video in
            
        }
        
        playlistListVC.registerObserver(TubeTrends.Notifications.searchButtonDidTapped, object: nil, queue: nil) { (noti) -> Void in
            playlistListVC.swipeRefreshControl.startRefreshing()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            playlistListVC.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            sharedYTAPI.searchPlaylist(self.query, playlists: Items()) { (playlists) -> Void in
                playlistListVC.playlists = playlists
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    playlistListVC.tableView.reloadData()
                    playlistListVC.swipeRefreshControl.endRefreshing()
                })
            }
        }
        return playlistListVC
    }
    
    private func searchChannelVC(query: String) -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let channelVC = storyboard.instantiateViewControllerWithIdentifier("ChannelList") as! ChannelListViewController
        channelVC.viewDidLoadHandler = {
            channelVC.swipeRefreshControl.startRefreshing()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                sharedYTAPI.searchChannels(self.query, channels: Items()) { (channels) -> Void in
                    channelVC.channels = channels
                    dispatch_async(dispatch_get_main_queue(), { () -> Void in
                        channelVC.tableView.reloadData()
                        channelVC.swipeRefreshControl.endRefreshing()
                    })
                }
            })
        }
        channelVC.scrollViewDidEndDraggingHandler = {
            if let _ = channelVC.channels.nextPage {
                sharedYTAPI.searchChannels(self.query, channels: channelVC.channels) { (channels) -> Void in
                    channelVC.channels = channels
                    channelVC.tableView.reloadData()
                }
            }
        }
        channelVC.refreshListHander = {
            sharedYTAPI.searchChannels(self.query, channels: Items()) { (channels) -> Void in
                channelVC.channels = channels
                channelVC.tableView.reloadData()
                channelVC.swipeRefreshControl.endRefreshing()
            }
        }
        channelVC.extraButtonAtCellTappedHandler = { video in
            
        }
        
        channelVC.registerObserver(TubeTrends.Notifications.searchButtonDidTapped, object: nil, queue: nil) { (noti) -> Void in
            channelVC.swipeRefreshControl.startRefreshing()
            let indexPath = NSIndexPath(forRow: 0, inSection: 0)
            channelVC.tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: .Top, animated: true)
            sharedYTAPI.searchChannels(self.query, channels: Items()) { (channels) -> Void in
                channelVC.channels = channels
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    channelVC.tableView.reloadData()
                    channelVC.swipeRefreshControl.endRefreshing()
                })
            }
        }
        return channelVC
    }

}
