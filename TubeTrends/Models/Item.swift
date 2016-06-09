//
//  Video.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import Foundation
import RealmSwift

public enum Kind: String {
    case Video = "youtube#video"
    case Playlist = "youtube#playlist"
    case Channel = "youtube#channel"
}

public class Item: Object {
    
    var kind: Kind? = .Video
    
    dynamic var id: String!
    dynamic var title: String!
    dynamic var des: String!
    dynamic var publishAt = NSDate()
    dynamic var channelId: String!
    dynamic var channelTitle: String!
    dynamic var thumbnails: Thumbnail!
//    dynamic var tags: [String] = []
    dynamic var duration: Int = 0
    dynamic var dimension: String!
    dynamic var definition: String!
    dynamic var viewsCount: Int = 0
    dynamic var likesCount: Int = 0
    dynamic var dislikesCount: Int = 0
    dynamic var favoriteCount: Int = 0
    dynamic var commentsCount: Int = 0
    
    // Offline properties
    dynamic var offlinePath: String!
    dynamic var createdAt = NSDate()
    dynamic var modifiedAt = NSDate()
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
