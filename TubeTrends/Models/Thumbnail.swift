//
//  Thumbnail.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import Foundation
import RealmSwift

public class Thumbnail: Object {
    
    dynamic var basic: Image!
    dynamic var medium: Image!
    dynamic var high: Image!
    dynamic var standard: Image!
    dynamic var maxres: Image!
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
