//
//  FiltersViewController.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation
import UIKit

class FiltersViewController : UITableViewController {
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("yowl.filter.toggle") as! SwitchCell
        let filter = Reactor.instance.evaluate(Getter(keyPath: ["filters", indexPath.row]))
        let display = filter.getIn(["display"]).toSwift() as! String
        cell.filterName.text = display
        if let enabled = filter.getIn(["value"]).toSwift() as? Bool {
            cell.toggle.on = enabled
        }
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Reactor.instance.evaluate(Getter(keyPath: ["filters"])).count
    }
}

class SwitchCell : UITableViewCell {
    var key : String = ""
    
    @IBOutlet weak var filterName: UILabel!
    @IBOutlet weak var toggle: UISwitch!
}

// ID: filters
class FiltersStore : Store {
    override func getInitialState() -> Immutable.State {
        return Immutable.toState([
            "search": [
                "display": "Search...",
                "param": "term",
                "value": "",
                "disabled": false,
            ],
            "limit": [
                "display": "Limit",
                "param": "limit",
                "value": 20,
                "disabled": false,
            ],
            "sort": [
                "display": "Sort By",
                "param": "sort",
                "value": 0,
                "disabled": false,
            ],
            "category": [
                "display": "Category",
                "param": "category_filter",
                "value": "",
                "disabled": true,
            ],
            "radius": [
                "display": "Radius",
                "param": "radius_filter",
                "value": 100,
                "disabled": true,
            ],
            "deals": [
                "display": "Has Deals",
                "param": "deals_filter",
                "value": false,
                "disabled": false,
            ],
            "latlong": [
                "display": "LatLong",
                "param": "ll",
                "value": "37.785771,-122.406165",
                "disabled": false,
            ],
        ])
    }
    
    override func initialize() {
        self.on("setSearch", handler: { (state, searchTerm, action) -> Immutable.State in
            let newSearch = searchTerm as! String
            return state.setIn(["search", "value"], withValue: Immutable.toState(newSearch))
        })
    }
}

let QUERY = Getter(keyPath: ["filters"], withFunc: { (args) -> Immutable.State in
    return args[0].reduce(Immutable.toState([:]), f: {(query, next) -> Immutable.State in
        let param = next.getIn(["param"]).toSwift() as! String
        let disabled = next.getIn(["disabled"]).toSwift() as! Bool
        if disabled {
            return query
        }
        return query.setIn([param], withValue: next.getIn(["value"]))
    })
})

