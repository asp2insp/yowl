//
//  YelpClient.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

//
//  YelpClient.swift
//  Yelp
//
//  Created by Timothy Lee on 9/19/14.
//  Copyright (c) 2014 Timothy Lee. All rights reserved.
//

import UIKit

// You can register for Yelp API keys here: http://www.yelp.com/developers/manage_api_keys
let yelpConsumerKey = "jefUNHNlaU0Ku7EndY7opg"
let yelpConsumerSecret = "FOzSN3-R1Y7KjTfjWIScdimnIoI"
let yelpToken = "CbCSzMQqH6pc8wD7_o4UU01EQnMq987z"
let yelpTokenSecret = "JvbR6jTcelDly1FN5TEX1RQrvxU"

enum YelpSortMode: Int {
    case BestMatched = 0, Distance, HighestRated
}

class YelpClient: BDBOAuth1RequestOperationManager {
    var accessToken: String!
    var accessSecret: String!
    
    class var sharedInstance : YelpClient {
        struct Static {
            static var token : dispatch_once_t = 0
            static var instance : YelpClient? = nil
        }
        
        dispatch_once(&Static.token) {
            Static.instance = YelpClient(consumerKey: yelpConsumerKey, consumerSecret: yelpConsumerSecret, accessToken: yelpToken, accessSecret: yelpTokenSecret)
        }
        return Static.instance!
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init(consumerKey key: String!, consumerSecret secret: String!, accessToken: String!, accessSecret: String!) {
        self.accessToken = accessToken
        self.accessSecret = accessSecret
        var baseUrl = NSURL(string: "http://api.yelp.com/v2/")
        super.init(baseURL: baseUrl, consumerKey: key, consumerSecret: secret);
        
        var token = BDBOAuth1Credential(token: accessToken, secret: accessSecret, expiration: nil)
        self.requestSerializer.saveAccessToken(token)
    }
    
//    func searchWithCurrentTerms() -> AFHTTPRequestOperation {
//        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
//        
//        // Default the location to San Francisco
//        var parameters: [String : AnyObject] = ["term": term, "ll": "37.785771,-122.406165"]
//        
//        if sort != nil {
//            parameters["sort"] = sort!.rawValue
//        }
//        
//        if categories != nil && categories!.count > 0 {
//            parameters["category_filter"] = ",".join(categories!)
//        }
//        
//        if deals != nil {
//            parameters["deals_filter"] = deals!
//        }
//        
//        println(parameters)
//        
//        return self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
//            var dictionaries = response["businesses"] as? [NSDictionary]
//            if dictionaries != nil {
//                completion(Business.businesses(array: dictionaries!), nil)
//            }
//            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
//                completion(nil, error)
//        })
//    }
}