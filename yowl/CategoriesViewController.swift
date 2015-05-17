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
