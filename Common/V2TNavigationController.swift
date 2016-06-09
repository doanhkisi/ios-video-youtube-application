//
//  V2TNavigationController.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 12/4/15.
//  Website: https://v2t.mobi
//  Copyright © 2015 V2T Multimedia. All rights reserved.
//

import UIKit

class V2TNavigationController: UINavigationController {
    
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
//        navigationBar.setBackgroundImage(UIImage(), forBarMetrics:UIBarMetrics.Default)
        navigationBar.translucent = false
        navigationBar.shadowImage = UIImage()
        // Do any additional setup after loading the view.
        
        // Set navigation bar background colour
        navigationBar.barTintColor = UIColor(rgba: "#212121")
        
        // Set navigation bar title text colour
        navigationBar.titleTextAttributes = [NSForegroundColorAttributeName: UIColor.whiteColor()]
        
        // Set navigation bar tin color
        navigationBar.tintColor = UIColor(rgba: "#FF2D55")
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
