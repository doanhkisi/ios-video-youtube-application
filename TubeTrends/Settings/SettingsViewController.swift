//
//  SettingsViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/21/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class SettingsViewController: V2TTableViewController {

    private let reuseCellIdentifierNormal: String = "normalCell"
    private let reuseCellIdentifierSwitchBool: String = "switchControlCell"
    
    enum RowType {
        case Normal
        case SwitchBool
    }
    
    class RowItem: NSObject {
        var title: String = ""
        var value: AnyObject?
        var hidden: Bool = false
        var type: RowType = .Normal
        var action: (AnyObject -> Void)?
        init(title: String, value: AnyObject?, type: RowType, action: (AnyObject -> Void)?) {
            super.init()
            self.title = title
            self.value = value
            self.action = action
            self.type = type
        }
    }
    
    var rows: [RowItem] {
        return [
            RowItem(title: NSLocalizedString("Video Quality", comment: ""), value: TubeTrends.Settings.videoQuality.rawValue, type: .Normal, action: { (indexPath) -> Void in
                self.showVideoQualityOptions(atCell: self.tableView.cellForRowAtIndexPath(indexPath as! NSIndexPath))
            }),
            RowItem(title: NSLocalizedString("Play video in background", comment: ""), value: TubeTrends.Settings.playVideoInBackground, type: .SwitchBool, action: { (switchBoolCell) -> Void in
                let cell = switchBoolCell as! SwitchBoolTableViewCell
                TubeTrends.Settings.playVideoInBackground = cell.switchControl.on
                TubeTrends.sharedVideoDetailVC?.videoPlayerVC.moviePlayer.backgroundPlaybackEnabled = TubeTrends.Settings.playVideoInBackground
            })
        ]
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
        self.navigationItem.title = NSLocalizedString("Settings", comment: "")
        self.tableView.bounces = false
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
    // Get the new view controller using segue.destinationViewController.
    // Pass the selected object to the new view controller.
    }
    */
    
    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rows.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        switch self.rows[indexPath.row].type {
        case .Normal:
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseCellIdentifierNormal, forIndexPath: indexPath) as UITableViewCell
            cell.textLabel?.text = self.rows[indexPath.row].title
            cell.detailTextLabel?.text = self.rows[indexPath.row].value as? String
            let backgroundView = UIView()
            backgroundView.backgroundColor = UIColor(rgba: "#424242")
            cell.selectedBackgroundView = backgroundView
            return cell
        case .SwitchBool:
            let cell = tableView.dequeueReusableCellWithIdentifier(reuseCellIdentifierSwitchBool, forIndexPath: indexPath) as! SwitchBoolTableViewCell
            cell.titleCell.text = self.rows[indexPath.row].title
            cell.switchControl.on = self.rows[indexPath.row].value as! Bool
            cell.switchBoolCellChanged = self.rows[indexPath.row].action
            return cell
        }
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        self.tableView.deselectRowAtIndexPath(indexPath, animated: true)
        self.rows[indexPath.row].action?(indexPath)
    }
    
    func showVideoQualityOptions(atCell cell: UITableViewCell?) {
        let items: [BottomMenuViewItem] = [
            BottomMenuViewItem(title: "720p", selectedAction: { (Void) -> Void in
                TubeTrends.Settings.videoQuality = .k720p
            }),
            BottomMenuViewItem(title: "360p", selectedAction: { (Void) -> Void in
                TubeTrends.Settings.videoQuality = .k360p
            }),
            BottomMenuViewItem(title: "240p", selectedAction: { (Void) -> Void in
                TubeTrends.Settings.videoQuality = .k240p
            }),
            BottomMenuViewItem(title: "Cancel", selectedAction: { (Void) -> Void in
                
            })
        ]
        let bottomMenu = BottomMenuView(items: items) { (index) -> Void in
            if let cell = cell {
                cell.detailTextLabel?.text = items[index].title
            }
        }
        //        bottomMenu.itemAgliment = .Center
        let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
        bottomMenu.showInViewController(appDelegate.window!.rootViewController!)
    }

}
