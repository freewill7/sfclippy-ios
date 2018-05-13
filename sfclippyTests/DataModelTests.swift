//
//  DataModelTests.swift
//  sfclippyTests
//
//  Created by William Lee on 13/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import XCTest
@testable import sfclippy

class DataModelTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimplify() {
        // Tests that we can simplify names into somthing more easily searchable
        XCTAssertEqual("fang", simplifyName("F.A.N.G."))
        XCTAssertEqual("rmika", simplifyName("R.Mika"))
        XCTAssertEqual("ryu", simplifyName("Ryu"))
    }
    
}
