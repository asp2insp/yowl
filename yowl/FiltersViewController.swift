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
    @IBOutlet weak var deals: UISegmentedControl!
    @IBOutlet weak var sort: UISegmentedControl!
    @IBOutlet weak var distance: UISegmentedControl!
    let reactor = Reactor.instance
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        self.title = "Filters"
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    @IBAction func filterChanged(sender: UISegmentedControl) {
        switch sender {
        case deals:
            reactor.dispatch("setDeals", payload: deals.selectedSegmentIndex)
        case sort:
            reactor.dispatch("setSort", payload: sort.selectedSegmentIndex)
        case distance:
            reactor.dispatch("setDistance", payload: distance.selectedSegmentIndex)
        default:
            return
        }
    }
}

