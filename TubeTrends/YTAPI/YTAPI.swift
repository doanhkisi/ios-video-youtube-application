//
//  YTAPI.swift
//  TubeTrends
//
//  Created by Vũ Trung Thành on 1/19/16.
//  Website: https://v2t.mobi
//  Copyright © 2016 V2T Multimedia. All rights reserved.
//

import UIKit
import Alamofire
import SwiftyJSON
import QorumLogs

let sharedYTAPI = YTAPI()

public class YTAPI: NSObject {
    // Private properties
    private var manager: Alamofire.Manager
    
    override init() {
        // Create a shared URL cache
        let memoryCapacity = 500 * 1024 * 1024; // 500 MB
        let diskCapacity = 500 * 1024 * 1024; // 500 MB
        let cache = NSURLCache(memoryCapacity: memoryCapacity, diskCapacity: diskCapacity, diskPath: "shared_cache")
        
        // Create a custom configuration
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        let defaultHeaders = Alamofire.Manager.sharedInstance.session.configuration.HTTPAdditionalHeaders
        configuration.HTTPAdditionalHeaders = defaultHeaders
        configuration.requestCachePolicy = .UseProtocolCachePolicy // this is the default
        configuration.URLCache = cache
        
        // Create your own manager instance that uses your custom configuration
        manager = Alamofire.Manager(configuration: configuration)
    }
    
    public func getMostPopularVideos(videos: Items, completionHandler: (Items -> Void)?) {
        self.request(Router.getMostPopularVideos(pageToken: videos.nextPage)) { (json) -> Void in
            
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func getRelatedVideos(videoId: String!, videos: Items, completionHandler: (Items -> Void)?) {
        self.request(Router.getRelatedVideos(videoId: videoId, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func getVideoDetails(videoId: String, completionHandler: (Item -> Void)?){
        self.request(Router.getVideoDetails(videoId: videoId)) { (json) -> Void in
            completionHandler?(self.itemFromJSON(json["items"][0]))
        }
    }
    
    public func searchPlaylist(query: String, playlists: Items, completionHandler: (Items ->Void)?) {
        self.request(Router.searchPlaylists(query: query, pageToken: playlists.nextPage)) { (json) -> Void in
            playlists.total = json["pageInfo"]["totalResults"].intValue
            playlists.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            playlists.nextPage = json["nextPageToken"].string
            playlists.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                playlists.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(playlists)
        }
    }
    
    public func searchVideos(query: String, videos: Items, completionHandler: (Items ->Void)?) {
        self.request(Router.searchVideos(query: query, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func searchChannels(query: String, channels: Items, completionHandler: (Items ->Void)?) {
        self.request(Router.searchChannels(query: query, pageToken: channels.nextPage)) { (json) -> Void in
            channels.total = json["pageInfo"]["totalResults"].intValue
            channels.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            channels.nextPage = json["nextPageToken"].string
            channels.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                channels.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(channels)
        }
    }
    
    public func getPlaylistItems(playlistId: String, videos: Items, completionHandler: (Items -> Void)?) {
        self.request(Router.getPlaylistItems(playlistId: playlistId, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func getChannelItems(channelId: String, videos: Items, completionHandler: (Items -> Void)?) {
        self.request(Router.getChannelItems(channelId: channelId, pageToken: videos.nextPage)) { (json) -> Void in
            videos.total = json["pageInfo"]["totalResults"].intValue
            videos.itemPerPage = json["pageInfo"]["resultsPerPage"].intValue
            videos.nextPage = json["nextPageToken"].string
            videos.prevPage = json["prevPageToken"].string
            
            for item in json["items"].arrayValue {
                videos.items.append(self.itemFromJSON(item))
            }
            
            completionHandler?(videos)
        }
    }
    
    public func request(router: Router, completionHandler: (JSON -> Void)?) {
        self.manager.request(router).responseJSON { (response) -> Void in
            QL1("Request: \(response.request?.allHTTPHeaderFields)")
            QL1(response)
            if response.result.isSuccess {
                completionHandler?(JSON(response.result.value!))
            }
            if response.result.isFailure {
                completionHandler?(JSON(response.result.error!))
            }
        }
    }
    
    public enum Router: URLRequestConvertible {
        static private let baseURL = "https://www.googleapis.com"
        static private let basePath = "/youtube/v3"
        static private var key = TubeTrends.Settings.secretKeyApi.chooseOne
        
        case getMostPopularVideos(pageToken: String!)
        case searchVideos(query: String!, pageToken: String!)
        case searchPlaylists(query: String!, pageToken: String!)
        case searchChannels(query: String!, pageToken: String!)
        case getRelatedVideos(videoId: String!, pageToken: String!)
        case getPlaylistItems(playlistId: String!, pageToken: String!)
        case getChannelItems(channelId: String!, pageToken: String!)
        case getVideoDetails(videoId: String!)
        
        var method: Alamofire.Method {
            switch self {
            case .getMostPopularVideos:
                return .GET
            case .searchVideos:
                return .GET
            case .searchPlaylists:
                return .GET
            case .searchChannels:
                return .GET
            case .getRelatedVideos:
                return .GET
            case .getPlaylistItems:
                return .GET
            case .getChannelItems:
                return .GET
            case .getVideoDetails:
                return .GET
            }
        }
        
        var path: String {
            switch self {
            case .getMostPopularVideos, getVideoDetails:
                return "/videos"
            case .searchVideos, .searchChannels, .searchPlaylists, .getRelatedVideos, .getChannelItems:
                return "/search"
            case .getPlaylistItems:
                return "/playlistItems"
            }
        }
        
        // MARK: URLRequestConvertible
        
        public var URLRequest: NSMutableURLRequest {
            let urlComponent = NSURLComponents(string: Router.baseURL)!
            urlComponent.path = Router.basePath.stringByAppendingString(path)
            
            let mutableURLRequest = NSMutableURLRequest(URL: urlComponent.URL!)
            mutableURLRequest.HTTPMethod = method.rawValue
            
            var parameters: [String: AnyObject] = Dictionary()
            parameters["key"] = Router.key
            parameters["hl"] = "en"
            parameters["regionCode"] = TubeTrends.Settings.userCountryCode
            parameters["maxResults"] = 30
            
            switch self {
            case .getMostPopularVideos(let pageToken):
                parameters["part"] = "snippet,contentDetails,statistics"
                parameters["chart"] = "mostPopular"
                parameters["videoCategoryId"] = TubeTrends.Settings.topTrendsCat
                if let pageToken = pageToken {
                        parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .getRelatedVideos(let videoId, let pageToken):
                parameters["relatedToVideoId"] = videoId
                parameters["part"] = "snippet"
                parameters["type"] = "video"
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .getVideoDetails(let videoId):
                parameters["part"] = "snippet,contentDetails,statistics"
                parameters["id"] = videoId
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .searchPlaylists(let query, let pageToken):
                parameters["part"] = "snippet"
                parameters["q"] = query
                parameters["type"] = "playlist"
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .searchVideos(let query, let pageToken):
                parameters["part"] = "snippet"
                parameters["q"] = query
                parameters["type"] = "video"
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .searchChannels(let query, let pageToken):
                parameters["part"] = "snippet"
                parameters["q"] = query
                parameters["type"] = "channel"
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .getPlaylistItems(let playlistId, let pageToken):
                parameters["part"] = "snippet,contentDetails"
                parameters["playlistId"] = playlistId
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
            case .getChannelItems(let channelId, let pageToken):
                parameters["part"] = "snippet"
                parameters["channelId"] = channelId
                parameters["type"] = "video"
                if let pageToken = pageToken {
                    parameters["pageToken"] = pageToken
                }
                return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: parameters).0
//            default:
//                return mutableURLRequest
            }
        }
    }
    
    private func itemFromJSON(json: JSON) -> Item {
        let item = Item()
        item.kind = Kind(rawValue: json["id"]["kind"].stringValue)
        item.id = json["id"].stringValue
        if item.id == "" {
            item.id = json["id"]["videoId"].stringValue
        }
        if let id = json["contentDetails"]["videoId"].string {
            item.id = id
        }
        if item.kind == .Playlist {
            item.id = json["id"]["playlistId"].stringValue
        }
        if item.kind == .Channel {
            item.id = json["id"]["channelId"].stringValue
        }
        let snippet = json["snippet"]
        item.title = snippet["title"].stringValue
        item.des = snippet["description"].stringValue
        item.channelId = snippet["channelId"].stringValue
        let strDate = snippet["publishedAt"].stringValue
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z'"
        if let date = dateFormatter.dateFromString(strDate) {
            item.publishAt = date
        }
        let thumbnai = Thumbnail()
        thumbnai.basic = Image(url: snippet["thumbnails"]["default"]["url"].stringValue,
            width: snippet["thumbnails"]["default"]["width"].intValue,
            height: snippet["thumbnails"]["default"]["height"].intValue)
        thumbnai.medium = Image(url: snippet["thumbnails"]["medium"]["url"].stringValue,
            width: snippet["thumbnails"]["medium"]["width"].intValue,
            height: snippet["thumbnails"]["medium"]["height"].intValue)
        thumbnai.high = Image(url: snippet["thumbnails"]["high"]["url"].stringValue,
            width: snippet["thumbnails"]["high"]["width"].intValue,
            height: snippet["thumbnails"]["high"]["height"].intValue)
        thumbnai.standard = Image(url: snippet["thumbnails"]["standard"]["url"].stringValue,
            width: snippet["thumbnails"]["standard"]["width"].intValue,
            height: snippet["thumbnails"]["standard"]["height"].intValue)
        thumbnai.maxres = Image(url: snippet["thumbnails"]["maxres"]["url"].stringValue,
            width: snippet["thumbnails"]["maxres"]["width"].intValue,
            height: snippet["thumbnails"]["maxres"]["height"].intValue)
        item.thumbnails = thumbnai
        
        item.dimension = json["contentDetails"]["dimension"].stringValue
        item.definition = json["contentDetails"]["definition"].stringValue
        
        item.likesCount = json["statistics"]["likeCount"].intValue
        item.dislikesCount = json["statistics"]["dislikeCount"].intValue
        item.viewsCount = json["statistics"]["viewCount"].intValue
        
        return item
    }
}
