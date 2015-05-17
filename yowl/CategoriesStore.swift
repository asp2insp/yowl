//
//  CategoriesStore.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/17/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation


// ID: categories
class CategoriesStore : Store {
    override func getInitialState() -> Immutable.State {
        return Immutable.toState([])
    }
    
    override func initialize() {
        self.on("setCategories", handler: { (state, categoriesJson, action) -> Immutable.State in
            return Immutable.toState(categoriesJson as! AnyObject).filter({(s: Immutable.State) -> Bool in
                if s.getIn(["country_whitelist"]).exists {
                    return s.getIn(["country_whitelist"]).containsValue("US")
                }
                if s.getIn(["country_blacklist"]).exists {
                    return !s.getIn(["country_blacklist"]).containsValue("US")
                }
                return true
            }).map({(s, index) -> Immutable.State in
                let id = s.getIn(["alias"]).toSwift() as! String
                let title = s.getIn(["title"]).toSwift() as! String
                return Immutable.toState([
                    "id": id,
                    "title": title,
                    "enabled": false
                    ])
            })
        })
        self.on("toggleCategory", handler: { (state, index, action) -> Immutable.State in
            let i = index as! Int
            let currentlyEnabled = state.getIn([i, "enabled"]).toSwift() as! Bool
            return state.setIn([i, "enabled"], withValue: Immutable.toState(!currentlyEnabled))
        })
    }
}

let CATEGORIES = Getter(keyPath: ["categories"], withFunc: {(states) -> Immutable.State in
    return states[0].reduce(Immutable.toState(""), f: {(current, next) -> Immutable.State in
        if next.getIn(["enabled"]).toSwift() as! Bool {
            var currentString = current.toSwift() as! String
            var nextString = next.getIn(["id"]).toSwift() as! String
            if !currentString.isEmpty {
                currentString = "\(currentString),"
            }
            return Immutable.toState("\(currentString)\(nextString)")
        }
        return current
    })
})
