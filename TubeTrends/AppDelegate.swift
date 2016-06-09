//
//  AppDelegate.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/17/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import QorumLogs
import AVFoundation
import RealmSwift

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        QorumLogs.enabled = true
        window?.backgroundColor = UIColor(rgba: "#212121")
        
//        sharedV2TAds.getAdsInfo(nil)
        
        // Default setting
        TubeTrends.Settings.videoQuality = TubeTrends.VideoQuality.k720p
        TubeTrends.Settings.playVideoInBackground = true
        
        // Start audio session
        do {
            try AVAudioSession.sharedInstance().setCategory(AVAudioSessionCategoryPlayback)
            try AVAudioSession.sharedInstance().setActive(true)
        } catch {
            
        }
        
        QL1(Realm.Configuration.defaultConfiguration)
        
        let defaults = NSUserDefaults.standardUserDefaults()
        if defaults.stringForKey("isFirstInstall") == nil {
            // Created DowloadList and Favorites list if not exits
            let downloadList = Items()
            downloadList.name = "Downloads"
            
            let favoriteList = Items()
            favoriteList.name = "Favorites"
            
            let historiesList = Items()
            historiesList.name = "Histories"
            
            try! TubeTrends.realm.write({
                TubeTrends.realm.add(downloadList)
                TubeTrends.realm.add(favoriteList)
                TubeTrends.realm.add(historiesList)
                defaults.setObject(1, forKey: "isFirstInstall")
            })
        }
        
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

