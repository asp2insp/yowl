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
        Reactor.instance.registerStore("biz", store: DetailsStore())
        Reactor.instance.registerStore("filters", store: FiltersStore())
        Reactor.instance.registerStore("results", store: SearchResultsStore())
        Reactor.instance.registerStore("categories", store: CategoriesStore())
        Reactor.instance.debug = false
        Reactor.instance.reset()
        
        // Set up the drawer controllers:
        let drawerController = self.window?.rootViewController as! MMDrawerController
        drawerController.setMaximumLeftDrawerWidth(250.0, animated: true, completion: nil)
        drawerController.openDrawerGestureModeMask = MMOpenDrawerGestureMode.BezelPanningCenterView
        drawerController.closeDrawerGestureModeMask = MMCloseDrawerGestureMode.All
        drawerController.centerHiddenInteractionMode = MMDrawerOpenCenterInteractionMode.NavigationBarOnly
//        drawerController.setDrawerVisualStateBlock(MMDrawerVisualState.slideAndScaleVisualStateBlock())
        
        let manager = AFHTTPRequestOperationManager()
        manager.responseSerializer.acceptableContentTypes = NSSet(object: "binary/octet-stream") as Set<NSObject>
        manager.GET("https://s3-media2.fl.yelpcdn.com/assets/srv0/developer_pages/5e749b17ad6a/assets/json/categories.json", parameters: nil, success: { (operation, data) -> Void in
            Reactor.instance.dispatch("setCategories", payload: data)
            }) { (operation, error) -> Void in
                println(error.localizedDescription)
        }
        return true
    }

    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

