//
//  FiltersViewController.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation
import UIKit

class FiltersViewController : UIViewController {
    
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
            "location": [
                "display": "Location",
                "param": "location",
                "value": "San Francisco",
                "disabled": false,
            ],
            "latlong": [
                "display": "LatLong",
                "param": "cll",
                "value": "",
                "disabled": false,
            ],
        ])
    }
    
    override func initialize() {
        self.on("setResults", handler: { (state, results, action) -> Immutable.State in
            return Immutable.toState(results as! AnyObject)
        })
    }
}

let QUERY = Getter(keyPath: ["filters"], withFunc: { (filters: Immutable.State) -> Immutable.State in
    filters.reduce(Immutable.toState("?"), f: {(initial: Immutable.State, next: Immutable.State) -> Immutable.State in
    })
    return Immutable.State.None
})

