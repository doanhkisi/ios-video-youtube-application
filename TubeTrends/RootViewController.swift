//
//  RootViewController.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/29/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit

class RootViewController: V2TViewController {
    
    var isPortraint: Bool = true {
        didSet {
            UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            //            if !isPortraint {
            //                if (UIDeviceOrientationIsLandscape(UIDevice.currentDevice().orientation)) {
            //                    UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            //                }
            //                UIDevice.currentDevice().setValue(UIInterfaceOrientation.LandscapeRight.rawValue, forKey: "orientation")
            //            } else {
            //                UIDevice.currentDevice().setValue(UIInterfaceOrientation.Portrait.rawValue, forKey: "orientation")
            //            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func shouldAutorotate() -> Bool {
        if isPortraint {
            return false
        } else {
            return true
        }
    }
    
    override func supportedInterfaceOrientations() -> UIInterfaceOrientationMask {
        if isPortraint {
            return UIInterfaceOrientationMask.Portrait
        } else {
            return UIInterfaceOrientationMask.All
        }
    }
    
    override func preferredInterfaceOrientationForPresentation() -> UIInterfaceOrientation {
        if isPortraint {
            return UIInterfaceOrientation.Portrait
        } else {
            return UIInterfaceOrientation.LandscapeLeft
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

}
