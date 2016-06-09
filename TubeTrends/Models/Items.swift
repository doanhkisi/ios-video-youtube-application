//
//  Videos.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import Foundation
import RealmSwift

public class Items: Object {
    
    let items = List<Item>()
    dynamic var total: Int = 0
    dynamic var itemPerPage: Int = 0
    dynamic var nextPage: String!
    dynamic var prevPage: String!
    dynamic var name: String!
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
