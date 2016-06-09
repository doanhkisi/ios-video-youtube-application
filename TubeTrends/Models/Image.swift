//
//  Image.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import Foundation
import RealmSwift
import Realm

public class Image: Object {
    
    dynamic var url: String!
    dynamic var width: Int = 0
    dynamic var height: Int = 0
    
    init(url: String!, width: Int, height: Int) {
        super.init()
        self.url = url
        self.width = width
        self.height = height
    }
    override init(realm: RLMRealm, schema: RLMObjectSchema) {
        super.init(realm: realm, schema: schema)
    }
    required public init() {
        super.init()
    }
    
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
