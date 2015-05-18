//
//  ViewController.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/13/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import UIKit
import CoreLocation

class ResultsViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UISearchBarDelegate, CLLocationManagerDelegate {
    @IBOutlet weak var tableView: UITableView!
    let reactor = Reactor.instance
    var listenerIds : [UInt] = []
    let manager = CLLocationManager()

    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Filters", style: UIBarButtonItemStyle.Plain, target: self, action: "showFilters:")
        self.navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Categories", style: UIBarButtonItemStyle.Plain, target: self, action: "showCategories:")
        
        let searchBar = UISearchBar()
        searchBar.sizeToFit()
        var currentSize = searchBar.frame.size

        currentSize.width = 200
        (searchBar.valueForKey("searchField") as? UITextField)?.textColor = UIColor.whiteColor()
        searchBar.bounds = CGRect(x: 0, y: 0, width: currentSize.width, height: currentSize.height)
        searchBar.searchBarStyle = UISearchBarStyle.Minimal
        searchBar.delegate = self
        self.navigationItem.titleView = searchBar
        
        tableView.estimatedRowHeight = 140.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Start listening for state changes
        self.listenerIds.append(reactor.observe(RESULTS, handler: { (newState) -> () in
            self.tableView.reloadData()
        }))
        self.listenerIds.append(reactor.observe(QUERY, handler: { (newState) -> () in
            self.reactor.dispatch("setOffset", payload: 0)
        }))
        self.listenerIds.append(reactor.observe(CATEGORIES, handler: { (newState) -> () in
            self.reactor.dispatch("setOffset", payload: 0)
        }))
        self.listenerIds.append(reactor.observe(OFFSET, handler: { (newState) -> () in
            YelpClient.sharedInstance.searchWithCurrentTerms()
        }))
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(true)
        manager.delegate = self
        if CLLocationManager.authorizationStatus() == .NotDetermined {
            manager.requestWhenInUseAuthorization()
        }
    }
    
    func locationManager(manager: CLLocationManager!,
        didChangeAuthorizationStatus status: CLAuthorizationStatus) {
        if status == .AuthorizedAlways || status == .AuthorizedWhenInUse {
            manager.startUpdatingLocation()
        }
    }
    
    func locationManager(manager: CLLocationManager!, didUpdateToLocation newLocation: CLLocation!, fromLocation oldLocation: CLLocation!) {
        NSLog("New Location \(newLocation)")
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(true)
        reactor.unobserve(listenerIds)
    }
    
    func searchBar(searchBar: UISearchBar, textDidChange searchText: String) {
        reactor.dispatch("setSearch", payload: searchText)
    }
    
    func showFilters(sender: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(MMDrawerSide.Left, animated: true, completion: nil)
    }
    
    func showCategories(sender: AnyObject) {
        self.mm_drawerController.toggleDrawerSide(MMDrawerSide.Right, animated: true, completion: nil)
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return reactor.evaluate(RESULTS).count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("yowl.result.cell") as! BusinessCell
        cell.index = indexPath.row
        return cell
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        // TODO nav to detail
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let numRows = reactor.evaluate(RESULTS).count
        if indexPath.row ==  numRows - 1 {
            reactor.dispatch("setOffset", payload: numRows)
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}
