//
//  ViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/17/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import CarbonKit
import UIColor_Hex_Swift
import FontAwesome_swift
import QorumLogs

class MainViewController: V2TViewController, CarbonTabSwipeNavigationDelegate, UISearchBarDelegate {
    
    let searchController = UISearchController(searchResultsController: nil)
    var searchResultController: SearchViewController = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle()).instantiateViewControllerWithIdentifier("SearchViewResult") as! SearchViewController
    
    @IBOutlet weak var contentView: UIView!
    
    let tabItems = [
        NSLocalizedString("Top 30 Videos", comment: ""),
        NSLocalizedString("Playlist", comment: ""),
        NSLocalizedString("Personal", comment: "")
        
    ]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.backgroundColor = UIColor(rgba: "#212121")
        
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
        tabSwipeNavigation.insertIntoRootViewController(self, andTargetView: self.contentView)
        
        if TubeTrends.Settings.isShowSearchFunction {
            // Do any additional setup after loading the view.
            searchController.hidesNavigationBarDuringPresentation = false
            searchController.dimsBackgroundDuringPresentation = false
            searchController.searchBar.delegate = self
            searchController.searchBar.placeholder = NSLocalizedString("What do you want to listen...?", comment: "")
            searchController.searchBar.tintColor = UIColor(rgba: "#FF2D55")
            searchController.searchBar.barTintColor = UIColor.clearColor()
            searchController.searchBar.backgroundImage = UIImage()
            searchController.searchBar.translucent = true
            let textField: UITextField? = searchController.searchBar.valueForKey("_searchField") as? UITextField
            textField?.backgroundColor = UIColor(rgba: "#424242")
            textField?.textColor = UIColor(rgba: "#FF2D55")
            textField?.tintColor = UIColor(rgba: "#FF2D55")
            let textFieldInsideSearchBarLabel = textField?.valueForKey("placeholderLabel") as? UILabel
            textFieldInsideSearchBarLabel?.textColor = UIColor(rgba: "#FF2D55")
            navigationItem.titleView = searchController.searchBar
        } else {
            title = NSLocalizedString("Video Trends", comment: "")
        }
        
        // Remove cache if networking is avaiable
        if V2TReachability.isConnectedToNetwork() == true {
            
        } else {
            debugPrint("Internet connection FAILED")
            
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // MARK: - CarbonTabSwipeNavigationDelegate
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, viewControllerAtIndex index: UInt) -> UIViewController {
        switch index {
        case 0:
            return self.topTrendsVideoVC()
        case 1:
            return self.playlistViewController()
        case 2:
            return self.personalViewController()
        default:
            break
        }
        return UIViewController()
    }
    
    func carbonTabSwipeNavigation(carbonTabSwipeNavigation: CarbonTabSwipeNavigation, didMoveAtIndex index: UInt) {
//        self.title = tabItems[Int(index)]
    }
    
    // MARK: - UISearchBarDelegate
    func searchBarCancelButtonClicked(searchBar: UISearchBar) {
        searchController.searchBar.showsCancelButton = false
        searchController.searchBar.resignFirstResponder()
        
        searchResultController.willMoveToParentViewController(nil)
        searchResultController.view.removeFromSuperview()
        searchResultController.removeFromParentViewController()
        
        navigationItem.leftBarButtonItem = nil
    }
    
    func searchBarTextDidBeginEditing(searchBar: UISearchBar) {
        searchController.searchBar.showsCancelButton = true
        
        searchBar.text = searchResultController.query
        self.addChildViewController(searchResultController)
        self.view.addSubview(searchResultController.view)
        searchResultController.view.translatesAutoresizingMaskIntoConstraints = false
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("H:|[searchView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["searchView": searchResultController.view]))
        self.view.addConstraints(NSLayoutConstraint.constraintsWithVisualFormat("V:|[searchView]|", options: NSLayoutFormatOptions(), metrics: nil, views: ["searchView": searchResultController.view]))
        searchResultController.didMoveToParentViewController(self)
        
        if UIDevice.currentDevice().userInterfaceIdiom == .Pad {
            let backButtonItem = UIBarButtonItem(image: UIImage.fontAwesomeIconWithName(FontAwesome.ArrowLeft, textColor: TubeTrends.Settings.foregroundColor, size: CGSize(width: 26, height: 26)), style: .Plain, target: self, action: #selector(UISearchBarDelegate.searchBarCancelButtonClicked(_:)))
            navigationItem.leftBarButtonItem = backButtonItem
        }
    }
    
    func searchBarTextDidEndEditing(searchBar: UISearchBar) {
        searchController.searchBar.resignFirstResponder()
        
    }
    
    func searchBarSearchButtonClicked(searchBar: UISearchBar) {
        if let query = searchBar.text {
            searchResultController.query = query
            NSNotificationCenter.defaultCenter().postNotificationName(TubeTrends.Notifications.searchButtonDidTapped, object: nil)
        }
    }
    
    // MARK: - Private function
    
    private func topTrendsVideoVC() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let videoListVC = storyboard.instantiateViewControllerWithIdentifier("VideoList") as! VideoListViewController
        videoListVC.viewDidLoadHandler = {
            videoListVC.swipeRefreshControl.startRefreshing()
            sharedYTAPI.getMostPopularVideos(videoListVC.videos) { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.swipeRefreshControl.endRefreshing()
            }
        }
        videoListVC.scrollViewDidEndDraggingHandler = {
            if let _ = videoListVC.videos.nextPage {
                sharedYTAPI.getMostPopularVideos(videoListVC.videos) { (videos) -> Void in
                    videoListVC.videos = videos
                    videoListVC.tableView.reloadData()
                }
            }
        }
        videoListVC.refreshListHander = {
            sharedYTAPI.getMostPopularVideos(Items()) { (videos) -> Void in
                videoListVC.videos = videos
                videoListVC.tableView.reloadData()
                videoListVC.swipeRefreshControl.endRefreshing()
            }
        }
        videoListVC.extraButtonAtCellTappedHandler = { cell in
            TubeTrends.showExtraOptionOnlineCell(cell)
        }
        return videoListVC
    }
    
    private func playlistViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let playlistListVC = storyboard.instantiateViewControllerWithIdentifier("PlaylistList") as! PlaylistListViewController
        playlistListVC.viewDidLoadHandler = {
            playlistListVC.swipeRefreshControl.startRefreshing()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), {
                sharedYTAPI.searchPlaylist(TubeTrends.Settings.topPlaylistKeyword, playlists: Items()) { (playlists) -> Void in
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
                sharedYTAPI.searchPlaylist("vevo music", playlists: playlistListVC.playlists) { (playlists) -> Void in
                    playlistListVC.playlists = playlists
                    playlistListVC.tableView.reloadData()
                }
            }
        }
        playlistListVC.refreshListHander = {
            sharedYTAPI.searchPlaylist("vevo music", playlists: Items()) { (playlists) -> Void in
                playlistListVC.playlists = playlists
                playlistListVC.tableView.reloadData()
                playlistListVC.swipeRefreshControl.endRefreshing()
            }
        }
        playlistListVC.extraButtonAtCellTappedHandler = { video in
            
        }
        return playlistListVC
    }
    
    private func personalViewController() -> UIViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
        let personalVC = storyboard.instantiateViewControllerWithIdentifier("PersonalMenuView") as! PersonalMenuViewController
        
        return personalVC
    }


}

