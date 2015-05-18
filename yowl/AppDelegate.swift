//
//  AppDelegate.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/13/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        // Set up the data and reactor
        setupReactor()
        
        // Set up the drawer controllers:
        setupDrawers()
        
        // Download the categories JSON
        downloadCategories()

        return true
    }
    
    func setupReactor() {
        Reactor.instance.registerStore("biz", store: DetailsStore())
        Reactor.instance.registerStore("filters", store: FiltersStore())
        Reactor.instance.registerStore("results", store: SearchResultsStore())
        Reactor.instance.registerStore("categories", store: CategoriesStore())
        Reactor.instance.debug = false
        Reactor.instance.reset()
    }
    
    func setupDrawers() {
        let drawerController = self.window?.rootViewController as! MMDrawerController
        drawerController.setMaximumLeftDrawerWidth(250.0, animated: true, completion: nil)
        drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.BezelPanningCenterView
        drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All
        drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionMode.NavigationBarOnly
    }

    func downloadCategories() {
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "binary/octet-stream") as Set<NSObject>
        manager.GET("https://s3-media2.fl.yelpcdn.com/assets/srv0/developer_pages/5e749b17ad6a/assets/json/categories.json", parameters: nil, success: { (operation, data) -> Void in
            Reactor.instance.dispatch("setCategories", payload: data)
            }) { (operation, error) -> Void in
                println(error.localizedDescription)
        }
    }
}

