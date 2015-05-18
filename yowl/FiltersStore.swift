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
        return Immutable.toState(["otherFilters": [
            "search": [
                "param": "term",
                "value": "",
                "disabled": false,
            ],
            "sort": [
                "param": "sort",
                "value": 0,
                "disabled": false,
            ],
            "radius": [
                "param": "radius_filter",
                "value": 804,
                "disabled": true,
            ],
            "deals": [
                "param": "deals_filter",
                "value": false,
                "disabled": false,
            ],
            "latlong": [
                "param": "ll",
                "value": "37.785771,-122.406165",
                "disabled": false,
            ],
        ], "offset": 0])
    }
    
    override func initialize() {
        self.on("setSearch", handler: { (state, searchTerm, action) -> Immutable.State in
            let newSearch = searchTerm as! String
            return state.setIn(["otherFilters", "search", "value"], withValue: Immutable.toState(newSearch))
        })
        self.on("setDeals", handler: { (state, deals, action) -> Immutable.State in
            let dealsBool = deals as! Int == 1
            return state.setIn(["otherFilters", "deals", "value"], withValue: Immutable.toState(dealsBool))
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
                return state.setIn(["otherFilters", "radius", "disabled"], withValue: Immutable.toState(true))
            }
            return state.setIn(["otherFilters", "radius", "disabled"], withValue: Immutable.toState(false)).setIn(["otherFilters", "radius", "value"], withValue: Immutable.toState(d))
        })
        self.on("setSort", handler: { (state, sortType, action) -> Immutable.State in
            let sort = sortType as! Int
            return state.setIn(["otherFilters", "sort", "value"], withValue: Immutable.toState(sort))
        })
        self.on("setOffset", handler: { (state, offset, action) -> Immutable.State in
            let offsetInt = offset as! Int
            return state.setIn(["offset"], withValue: Immutable.toState(offsetInt))
        })
    }
}

let OFFSET = Getter(keyPath: ["filters", "offset"])

let QUERY = Getter(keyPath: ["filters", "otherFilters"], withFunc: { (args) -> Immutable.State in
    return args[0].reduce(Immutable.toState([:]), f: {(query, next) -> Immutable.State in
        let param = next.getIn(["param"]).toSwift() as! String
        let disabled = next.getIn(["disabled"]).toSwift() as! Bool
        if disabled {
            return query
        }
        return query.setIn([param], withValue: next.getIn(["value"]))
    })
})
