//
//  CategoriesSwitchCell.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/17/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation


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
