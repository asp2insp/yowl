//
//  CategoriesViewController.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/16/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation

//
//  FiltersViewController.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/14/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation
import UIKit

class CategoriesViewController : UITableViewController {
    let reactor = Reactor.instance
    var listener : UInt!
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        listener = reactor.observe(Getter(keyPath: ["categories"]), handler: { (s) -> () in
            self.tableView.reloadData()
        })
        self.title = "Categories"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        reactor.unobserve([listener])
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier("yowl.filter.category") as! CategorySwitchCell
        cell.index = indexPath.row
        return cell
    }
    
    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Reactor.instance.evaluate(Getter(keyPath: ["categories"])).count
    }
}

class CategorySwitchCell : UITableViewCell {
    var index : Int = 0 {
        didSet {
            let category = Reactor.instance.evaluate(Getter(keyPath: ["categories", index]))
            if category.exists {
                let display = category.getIn(["title"]).toSwift() as! String
                self.filterName.text = display
                let enabled = category.getIn(["enabled"]).toSwift() as! Bool
                self.toggle.on = enabled
            }
        }
    }
    
    @IBAction func switchValueChanged(sender: UISwitch) {
        Reactor.instance.dispatch("toggleCategory", payload: index)
    }
    
    
    @IBOutlet weak var filterName: UILabel!
    @IBOutlet weak var toggle: UISwitch!
}

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
