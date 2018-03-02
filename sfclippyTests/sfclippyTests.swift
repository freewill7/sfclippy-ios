//
//  sfclippyTests.swift
//  sfclippyTests
//
//  Created by William Lee on 16/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import XCTest
@testable import sfclippy

class sfclippyTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testSimpleStatistics() {
        let noStats = UsageStatistic()
        let noStatsMap = noStats.toMap()
        let noStatsCopy = UsageStatistic.initFromMap(fromMap: noStatsMap)
        XCTAssertNotNil(noStatsCopy)
        XCTAssertEqual(0, noStatsCopy!.qtyBattles)
        XCTAssertEqual(0, noStatsCopy!.qtyWins)
        XCTAssertNil(noStatsCopy!.lastBattle)
        XCTAssertNil(noStatsCopy!.lastWin)
        
        let losingStat = UsageStatistic()
        losingStat.addResult(won: false)
        let losingMap = losingStat.toMap()
        let losingCopy = UsageStatistic.initFromMap(fromMap: losingMap)
        XCTAssertNotNil(losingCopy)
        XCTAssertEqual(1, losingCopy!.qtyBattles)
        XCTAssertEqual(0, losingCopy!.qtyWins)
        XCTAssertNil(losingCopy!.lastWin)
        XCTAssertNotNil(losingCopy!.lastBattle)
        
        let winningStat = UsageStatistic()
        winningStat.addResult(won: true)
        let winningMap = winningStat.toMap()
        let winningCopy = UsageStatistic.initFromMap(fromMap: winningMap)
        XCTAssertNotNil(winningCopy)
        XCTAssertEqual(1, winningCopy!.qtyBattles)
        XCTAssertEqual(1, winningCopy!.qtyWins)
        XCTAssertNotNil(winningCopy!.lastWin)
        XCTAssertNotNil(winningCopy!.lastBattle)
        XCTAssertEqual(winningCopy!.lastWin, winningCopy!.lastBattle)
    }
    
    func testCombinedStatistic() {
        let formatter = DateFormatter()
        formatter.dateFormat = "YYYY-mm-DD HH:MM:SS"
        
        let stat = UsageStatistic()
        stat.addResult(won: false)
        let lastWin = formatter.date(from: "2017-01-01 09:01:02")!
        stat.addResult(won: true, date: lastWin)
        stat.addResult(won: false)
        let lastBattle = stat.lastBattle!
        
        let serialised = stat.toMap()
        
        if let decoded = UsageStatistic.initFromMap(fromMap: serialised) {
            XCTAssertEqual(stat.qtyBattles, decoded.qtyBattles)
            XCTAssertEqual(stat.qtyWins, decoded.qtyWins)
            XCTAssertEqual(stat.lastBattle, lastBattle)
            XCTAssertEqual(stat.lastWin, lastWin)
        } else {
            XCTAssert(false)
        }
        
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
