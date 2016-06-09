//
//  NSObjectRegisterObserver.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 12/20/15.
//  Website: https://v2t.mobi
//  Copyright © 2015 V2T Multimedia. All rights reserved.
//

import UIKit

extension NSObject {
    func registerObserver(name: String?, object obj: AnyObject?, queue: NSOperationQueue?, usingBlock block: (NSNotification) -> Void) {
        NSNotificationCenter.defaultCenter().addObserverForName(name, object: nil, queue: nil, usingBlock: { (notification) -> Void in
            block(notification)
        })
    }
}
