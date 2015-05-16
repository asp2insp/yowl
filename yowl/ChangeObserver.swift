//
//  ChangeObserver.swift
//  Nuclear
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

public class ChangeObserver {
    let tagger = Tag()
    var observers : [Getter:[UInt:((Immutable.State) -> ())]] = [:]
    
    // TODO: move this caching into Evaluator to match Nuclear-JS
    var lastKnownStates : [Int:Int] = [:]
    var reactor : Reactor!
    
    init(reactor: Reactor) {
        self.reactor = reactor
    }
    
    // TODO: look into replacing this with NSNotificationCenter
    func notifyObservers(newState: Immutable.State) {
        for (getter, handlers) in observers {
            // We require that the getter compute function be pure, so if the inputs
            // haven't changed, we don't re-run the getter
            let newInputValue = reactor.evaluate(Getter(keyPath: Evaluator.keyPathParts(getter))).hashValue
            
            // TODO: WE REALLY REALLY NEED TO CHECK THE RECURSIVE GETTERS AS WELL.
            // THIS WHOLE CHECK SHOULD ACTUALLY BE AGAINST A LIST OF TAGS
            if lastKnownStates[getter.hashValue] ?? 0 == newInputValue {
                if reactor.debug { NSLog("No changes, skipping handlers") }
                continue // If the state hasn't changed, no need to update
            }
            lastKnownStates[getter.hashValue] = newInputValue
            for (id, handler) in handlers {
                if reactor.debug { NSLog("Handler #\(id) firing") }
                handler(reactor.evaluate(getter))
            }
        }
    }
    
    func onChange(getter: Getter, handler: ((Immutable.State) -> ())) -> UInt {
        if self.observers[getter] == nil {
            self.observers[getter] = [:]
        }
        let id = tagger.nextTag()
        self.observers[getter]![id] = handler
        return id
    }
    
    func removeHandler(id: UInt) {
        for (getter, var handlers) in self.observers {
            handlers.removeValueForKey(id)
            self.observers[getter] = handlers
        }
    }
    
    func handleReset() {
        lastKnownStates.removeAll(keepCapacity: true)
        observers.removeAll(keepCapacity: true)
    }
}