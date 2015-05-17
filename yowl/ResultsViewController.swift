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
        
        tableView.estimatedRowHeight = 120.0;
        tableView.rowHeight = UITableViewAutomaticDimension;
        
        // Start listening for state changes
        self.listenerIds.append(reactor.observe(RESULTS, handler: { (newState) -> () in
            self.tableView.reloadData()
        }))
        self.listenerIds.append(reactor.observe(QUERY, handler: { (newState) -> () in
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

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

}

class BusinessCell : UITableViewCell {
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!

    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var index : Int = 0 {
        didSet {
            let result = Reactor.instance.evaluate(RESULTS).getIn([index])
            
            if let heroUrl = result.getIn(["image_url"]).toSwift() as? String {
                heroImage.setImageWithURL(NSURL(string: heroUrl))
                heroImage.layer.cornerRadius = 5
                heroImage.clipsToBounds = true
            }
            let ratingUrl = result.getIn(["rating_img_url"]).toSwift() as! String
            ratingImage.setImageWithURL(NSURL(string: ratingUrl))
            
            let name = result.getIn(["name"]).toSwift() as! String
            restaurantName.text = "\(index + 1). \(name)"
            
            let numReviews = result.getIn(["review_count"]).toSwift() as! Int
            reviewsLabel.text = "\(numReviews) reviews"
            
            let address = result.getIn(["location", "display_address", 0]).toSwift() as! String
            addressLabel.text = address
            
            let tags = result.getIn(["categories"]).reduce(Immutable.toState(""), f: { (initial, next) -> Immutable.State in
                let current = initial.toSwift() as! String
                let new = next.getIn([0]).toSwift() as! String
                var s : String
                if current.isEmpty {
                    s = new
                } else {
                    s = "\(current), \(new)"
                }
                return Immutable.toState(s)
            }).toSwift() as! String
            tagsLabel.text = tags
            
            if let distance = result.getIn(["distance"]).toSwift() as? Double {
                let dMiles = 0.000621371 * distance
                let milesText = NSString(format: "%.01f", dMiles) as String
                distanceLabel.text = "\(milesText) mi"
            }
        }
    }
    
//    override func awakeFromNib() {
//        super.awakeFromNib()
//        restaurantName.preferredMaxLayoutWidth = restaurantName.frame.size.width
//    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        restaurantName.preferredMaxLayoutWidth = restaurantName.frame.size.width
    }
}

let RESULTS = Getter(keyPath:["results", "businesses"])

// ID: results
class SearchResultsStore : Store {
    override func getInitialState() -> Immutable.State {
        return Immutable.toState([])
    }
    
    override func initialize() {
        self.on("setResults", handler: { (state, results, action) -> Immutable.State in
            return Immutable.toState(results as! AnyObject)
        })
    }
}
