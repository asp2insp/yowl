//
//  BizStore.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/17/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

// ID: biz
class DetailsStore : Store {
    override func getInitialState() -> Immutable.State {
        return Immutable.toState([:])
    }
    
    override func initialize() {
        self.on("setBiz", handler: { (state, results, action) -> Immutable.State in
            return Immutable.toState(results as! AnyObject)
        })
    }
}