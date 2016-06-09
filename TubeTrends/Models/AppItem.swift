//
//  AppItem.swift
//  ChiaSeNhac
//
//  Created by Vũ Trung Thành on 1/14/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import Foundation
import RealmSwift

class AppItem: Object {
    
    dynamic var icon : String!
    dynamic var name : String!
    dynamic var descriptions : String!
    dynamic var link : String!
    dynamic var id : String!
    
    
    /**
     * Instantiate the instance using the passed dictionary values to set the properties values
     */
    class func fromDictionary(dictionary: NSDictionary) -> AppItem	{
        let this = AppItem()
        if let id = dictionary["id"] as? String{
            this.id = id
        }
        if let icon = dictionary["icon"] as? String{
            this.icon = icon
        }
        if let name = dictionary["title"] as? String{
            this.name = name
        }
        if let descriptions = dictionary["description"] as? String{
            this.descriptions = descriptions
        }
        if let link = dictionary["link"] as? String{
            this.link = link
        }
        return this
    }
    
    /**
     * Returns all the available property values in the form of NSDictionary object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> NSDictionary
    {
        let dictionary = NSMutableDictionary()
        if id != nil{
            dictionary["id"] = id
        }
        if icon != nil{
            dictionary["icon"] = icon
        }
        if name != nil{
            dictionary["title"] = name
        }
        if link != nil{
            dictionary["link"] = link
        }
        if descriptions != nil{
            dictionary["description"] = descriptions
        }
        return dictionary
    }
// Specify properties to ignore (Realm won't persist these)
    
//  override static func ignoredProperties() -> [String] {
//    return []
//  }
}
