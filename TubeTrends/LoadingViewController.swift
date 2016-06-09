//
//  LoadingViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 2/21/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class LoadingViewController: V2TViewController {

    @IBOutlet weak var loadingIndicator: UIActivityIndicatorView!
    override func viewDidLoad() {
        super.viewDidLoad()
        loadingIndicator.startAnimating()
        // Do something... Ex: load data config from your server before launch app.
        dispatch_after(3000,
            dispatch_get_main_queue()){
                let storyboard = UIStoryboard(name: "Main", bundle: NSBundle.mainBundle())
                let rootVC = storyboard.instantiateViewControllerWithIdentifier("RootView") as! RootViewController
                
                let appDelegate = UIApplication.sharedApplication().delegate as! AppDelegate
                appDelegate.window?.rootViewController = rootVC
        }
        
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

}
