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
    var debounceTimer : NSTimer?
    
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
    
    func searchWithCurrentTerms() {
        if let timer = debounceTimer {
            timer.invalidate()
        }
        debounceTimer = NSTimer(timeInterval: 0.2, target: self, selector: Selector("dispatchRequest:"), userInfo: nil, repeats: false)
        NSRunLoop.currentRunLoop().addTimer(debounceTimer!, forMode: "NSDefaultRunLoopMode")
    }
    
    func dispatchRequest(sender: AnyObject) {
        if let timer = debounceTimer {
            timer.invalidate()
        }
        // For additional parameters, see http://www.yelp.com/developers/documentation/v2/search_api
        
        // For SF: "term": term, "ll": "37.785771,-122.406165"
        var parameters : [String:AnyObject] = [:]
        var categories = Reactor.instance.evaluateToSwift(CATEGORIES) as! String
        
        if !categories.isEmpty {
            parameters["category_filter"] = categories
        }
        
        for (key, val) in Reactor.instance.evaluateToSwift(QUERY) as! [String:Any?] {
            parameters[key] = val as? AnyObject
        }
        println(parameters)
        
        self.GET("search", parameters: parameters, success: { (operation: AFHTTPRequestOperation!, response: AnyObject!) -> Void in
                Reactor.instance.dispatch("setResults", payload: response)
            }, failure: { (operation: AFHTTPRequestOperation!, error: NSError!) -> Void in
                NSLog("Operation error \(error)")
        })
    }
}