//
//  File.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/17/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation
import UIKit

class BusinessCell : UITableViewCell {
    @IBOutlet weak var heroImage: UIImageView!
    @IBOutlet weak var ratingImage: UIImageView!
    @IBOutlet weak var restaurantName: UILabel!
    @IBOutlet weak var reviewsLabel: UILabel!
    
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagsLabel: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var priceLabel: UILabel!
    
    var index : Int = 0 {
        didSet {
            let result = Reactor.instance.evaluate(RESULTS).getIn([index])
            
            if let heroUrl = result.getIn(["image_url"]).toSwift() as? String {
                heroImage.setImageWithURL(NSURL(string: heroUrl))
                heroImage.layer.cornerRadius = 5
                heroImage.clipsToBounds = true
            }
            let ratingUrl = result.getIn(["rating_img_url"]).toSwift() as! String
            ratingImage.setImageWithURL(NSURL(string: ratingUrl))
            
            let name = result.getIn(["name"]).toSwift() as! String
            restaurantName.text = "\(index + 1). \(name)"
            
            let numReviews = result.getIn(["review_count"]).toSwift() as! Int
            reviewsLabel.text = "\(numReviews) reviews"
            
            let address = result.getIn(["location", "display_address", 0]).toSwift() as! String
            addressLabel.text = address
            
            let tags = result.getIn(["categories"]).reduce(Immutable.toState(""), f: { (initial, next) -> Immutable.State in
                let current = initial.toSwift() as! String
                let new = next.getIn([0]).toSwift() as! String
                var s : String
                if current.isEmpty {
                    s = new
                } else {
                    s = "\(current), \(new)"
                }
                return Immutable.toState(s)
            }).toSwift() as! String
            tagsLabel.text = tags
            
            if let distance = result.getIn(["distance"]).toSwift() as? Double {
                let dMiles = 0.000621371 * distance
                let milesText = NSString(format: "%.01f", dMiles) as String
                distanceLabel.text = "\(milesText) mi"
            }
        }
    }
    
    //    override func awakeFromNib() {
    //        super.awakeFromNib()
    //        restaurantName.preferredMaxLayoutWidth = restaurantName.frame.size.width
    //    }
    
    override func layoutIfNeeded() {
        super.layoutIfNeeded()
        restaurantName.preferredMaxLayoutWidth = restaurantName.frame.size.width
    }
}
