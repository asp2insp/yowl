//
//  FiltersStore.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/17/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation


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
            "sort": [
                "display": "Sort By",
                "param": "sort",
                "value": 0,
                "disabled": false,
            ],
            "radius": [
                "display": "Radius",
                "param": "radius_filter",
                "value": 804,
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
        self.on("setDeals", handler: { (state, deals, action) -> Immutable.State in
            let dealsBool = deals as! Int == 1
            return state.setIn(["deals", "value"], withValue: Immutable.toState(dealsBool))
        })
        self.on("setDistance", handler: { (state, distance, action) -> Immutable.State in
            var d : Int = -1
            switch distance as! Int {
            case 0:
                d = 804 // 0.5 miles in meters
            case 1:
                d = 1608 // 1 miles in meters
            case 2:
                d = 3216 // 2 miles in meters
            case 3:
                d = 8040 // 5 miles in meters
            default:
                d = -1
            }
            if d == -1 {
                return state.setIn(["radius", "disabled"], withValue: Immutable.toState(true))
            }
            return state.setIn(["radius", "disabled"], withValue: Immutable.toState(false)).setIn(["radius", "value"], withValue: Immutable.toState(d))
        })
        self.on("setSort", handler: { (state, sortType, action) -> Immutable.State in
            let sort = sortType as! Int
            return state.setIn(["sort", "value"], withValue: Immutable.toState(sort))
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
