//
//  ResultsStore.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/17/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation


let RESULTS = Getter(keyPath:["results", "businesses"])

// ID: results
class SearchResultsStore : Store {
    override func getInitialState() -> Immutable.State {
        return Immutable.toState([])
    }
    
    override func initialize() {
        self.on("setResults", handler: { (state, results, action) -> Immutable.State in
            let offset = Reactor.instance.evaluateToSwift(OFFSET) as! Int
            if offset == 0 {
                return Immutable.toState(results as! AnyObject)
            } else {
                return state.mutateIn(["businesses"], withMutator: {(s) -> Immutable.State in
                    let newResults = results as! [String:AnyObject]
                    let newBiz = newResults["businesses"] as! [AnyObject]
                    var result = s!
                    for biz in newBiz {
                        result = result.push(Immutable.toState(biz))
                    }
                    return result
                })
            }
        })
    }
}