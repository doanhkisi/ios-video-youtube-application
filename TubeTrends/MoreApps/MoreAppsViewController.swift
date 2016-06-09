//
//  MoreAppsViewController.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 1/14/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import SwiftyJSON
import Haneke
import FontAwesome_swift

class MoreAppsViewController: V2TTableViewController {
    
    private let reuseableCellIdentifier = "appItemCell"
    
    var appsList: [AppItem] = []

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.title = NSLocalizedString("Interesting game, apps", comment: "")

        // Do any additional setup after loading the view.
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
        return appsList.count
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(reuseableCellIdentifier, forIndexPath: indexPath) as!
        AppItemTableViewCell
        cell.iconImageView.hnk_setImageFromURL(NSURL(string: appsList[indexPath.row].icon)!)
        cell.nameLabel.text = appsList[indexPath.row].name
        cell.descriptionLabel.text = appsList[indexPath.row].descriptions
        cell.appItem = appsList[indexPath.row]
        cell.downloadButtonTappedHandler = { appItem in
            let url = NSURL(string: (appItem.link))
            UIApplication.sharedApplication().openURL(url!)
//            let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
//            let appItemWebVC = storyboard.instantiateViewControllerWithIdentifier("AppItemWebView") as! AppItemWebViewController
//            appItemWebVC.appItem = appItem
//            let navVC = V2TNavigationController(rootViewController: appItemWebVC)
//            self.navigationController?.presentViewController(navVC, animated: true, completion: { () -> Void in
//                //
//            })
            
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let url = NSURL(string: (self.appsList[indexPath.row].link))
        UIApplication.sharedApplication().openURL(url!)
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
