//
//  ViewController.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/13/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import UIKit

class ResultsViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

// ID: results
class SearchResultsStore : Store {
    override func getInitialState() -> Immutable.State {
        return Immutable.toState([])
    }
    
    override func initialize() {
        self.on("setResults", handler: { (state, results, action) -> Immutable.State in
            return Immutable.toState(results as! AnyObject)
        })
    }
}