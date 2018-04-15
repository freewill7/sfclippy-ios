//
//  CharactersUITests.swift
//  sfclippyUITests
//
//  Created by William Lee on 20/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import XCTest

class CharactersUITests: XCTestCase {
        
    override func setUp() {
        super.setUp()
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
        
        // In UI tests it is usually best to stop immediately when a failure occurs.
        continueAfterFailure = false
        // UI tests must launch the application that they test. Doing this in setup will make sure it happens for each test method.
        XCUIApplication().launch()

        // In UI tests it’s important to set the initial state - such as interface orientation - required for your tests before they run. The setUp method is a good place to do this.
        
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testBootstrap() {
        // Use recording to get started writing UI tests.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        //let app = XCUIApplication()
        
        // move to characters screen
        //app/*@START_MENU_TOKEN@*/.buttons["Button"]/*[[".otherElements[\"ViewController\"].buttons[\"Button\"]",".buttons[\"Button\"]"],[[[-1,1],[-1,0]]],[0]]@END_MENU_TOKEN@*/.tap()
        
        // check that we're presented with a welcome message
        //XCTAssertTrue(app.alerts["Welcome"].exists)
        
        // populate characters with sample
        //app.alerts["Welcome"].buttons["Use sample"].tap()
    }
    
}
