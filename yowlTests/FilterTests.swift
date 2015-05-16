//
//  FilterTests.swift
//  yowl
//
//  Created by Josiah Gaskin on 5/15/15.
//  Copyright (c) 2015 Josiah Gaskin. All rights reserved.
//

import Foundation
import UIKit
import XCTest

class FilterTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        Reactor.instance.registerStore("filters", store: FiltersStore())
        Reactor.instance.reset()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testQueryParam() {
        // Check base state
        let query = Reactor.instance.evaluate(QUERY).description()
        XCTAssertEqual("(Map {location : (Value San Francisco), limit : (Value 20), term : (Value ), deals_filter : (Value 0), sort : (Value 0), cll : (Value )})", query, "")
    }
    
}
