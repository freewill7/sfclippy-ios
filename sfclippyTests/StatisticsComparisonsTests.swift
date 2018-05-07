//
//  StatisticsComparisonsTests.swift
//  sfclippyTests
//
//  Created by William Lee on 02/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import XCTest
@testable import sfclippy

class StatisticsComparisonsTests: XCTestCase {
    
    let now = Date(timeIntervalSinceNow: 0)
    let yesterday = Date(timeIntervalSinceNow: -1*(24*60*60))
    let lastWeek = Date(timeIntervalSinceNow: -7*(24*60*60))
    let twoWeeks = Date(timeIntervalSinceNow: -14*(24*60*60))
    let lastMonth = Date(timeIntervalSinceNow: -28*(24*60*60))
    let twoMonths = Date(timeIntervalSinceNow: -56*(24*60*60))
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testCompareWins() {
        let comparison1 = CompareQtyWins(isP1: true, today: now)
        let comparison2 = CompareQtyWins(isP1: false, today: now)
        
        XCTAssertEqual("P1 Wins", comparison1.getDescription() )
        XCTAssertEqual("P2 Wins", comparison2.getDescription() )
        
        let char1 = CharacterPref( name : "ryu", p1Rating: 1, p2Rating: 4)
        char1.p1Statistics = UsageStatistic(qtyBattles: 7, qtyWins: 1, lastBattle: now, lastWin: now)
        char1.p2Statistics = UsageStatistic(qtyBattles: 8, qtyWins: 2, lastBattle: now, lastWin: yesterday)
        let char2 = CharacterPref( name : "ken", p1Rating: 2, p2Rating: 5)
        // missing p1Statistics
        char2.p2Statistics = UsageStatistic(qtyBattles: 9, qtyWins: 3, lastBattle: now, lastWin: twoMonths)
        let char3 = CharacterPref( name : "juri", p1Rating: 3, p2Rating: 6)
        char3.p1Statistics = UsageStatistic(qtyBattles: 9, qtyWins: 3, lastBattle: nil, lastWin: nil)
        // missing p2Statistics
        
        XCTAssert( comparison1.isGreater(char1, char2) )
        XCTAssertEqual("1", comparison1.getFormattedValue(pref: char1))
        XCTAssert( !comparison1.isGreater(char2, char3) )
        XCTAssertEqual("0", comparison1.getFormattedValue(pref: char2))
        XCTAssert( !comparison1.isGreater(char1, char3) )
        XCTAssertEqual("3", comparison1.getFormattedValue(pref: char3))
        
        XCTAssert( !comparison2.isGreater(char1, char2) )
        XCTAssertEqual("2", comparison2.getFormattedValue(pref: char1))
        XCTAssert( comparison2.isGreater(char2, char3) )
        XCTAssertEqual("3", comparison2.getFormattedValue(pref: char2))
        XCTAssert( comparison2.isGreater(char1, char3) )
        XCTAssertEqual("0", comparison2.getFormattedValue(pref: char3))
        
        // both stats have had wins in the last month
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison1.trend(char1))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison2.trend(char1))
        // no statistics
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison1.trend(char2))
        // no wins recently
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison2.trend(char2))
    }
    
    func testCompareUsage() {
        let comparison1 = CompareQtyBattles(isP1: true, today: now)
        let comparison2 = CompareQtyBattles(isP1: false, today: now)
        
        XCTAssertEqual("P1 Usage", comparison1.getDescription() )
        XCTAssertEqual("P2 Usage", comparison2.getDescription() )
        
        let char1 = CharacterPref( name : "ryu", p1Rating: 1, p2Rating: 4)
        char1.p1Statistics = UsageStatistic(qtyBattles: 7, qtyWins: 1, lastBattle: now, lastWin: now)
        char1.p2Statistics = UsageStatistic(qtyBattles: 8, qtyWins: 2, lastBattle: now, lastWin: yesterday)
        let char2 = CharacterPref( name : "ken", p1Rating: 2, p2Rating: 5)
        // missing p1Statistics
        char2.p2Statistics = UsageStatistic(qtyBattles: 9, qtyWins: 3, lastBattle: twoMonths, lastWin: nil)
        let char3 = CharacterPref( name : "juri", p1Rating: 3, p2Rating: 6)
        char3.p1Statistics = UsageStatistic(qtyBattles: 9, qtyWins: 3, lastBattle: nil, lastWin: nil)
        // missing p2Statistics
        
        XCTAssert( comparison1.isGreater(char1, char2) )
        XCTAssertEqual("7", comparison1.getFormattedValue(pref: char1))
        XCTAssert( !comparison1.isGreater(char2, char3) )
        XCTAssertEqual("0", comparison1.getFormattedValue(pref: char2))
        XCTAssert( !comparison1.isGreater(char1, char3) )
        XCTAssertEqual("9", comparison1.getFormattedValue(pref: char3))
        
        XCTAssert( !comparison2.isGreater(char1, char2) )
        XCTAssertEqual("8", comparison2.getFormattedValue(pref: char1))
        XCTAssert( comparison2.isGreater(char2, char3) )
        XCTAssertEqual("9", comparison2.getFormattedValue(pref: char2))
        XCTAssert( comparison2.isGreater(char1, char3) )
        XCTAssertEqual("0", comparison2.getFormattedValue(pref: char3))
        
        // we've used the character in the past mont
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison1.trend(char1))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison2.trend(char1))
        // never used the character
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison1.trend(char2))
        // more than a month old
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison2.trend(char2))
        
    }
    
    func testCompareWinPercent() {
        let comparison1 = CompareWinPercent(isP1: true, today: now)
        let comparison2 = CompareWinPercent(isP1: false, today: now)
        
        XCTAssertEqual("P1 Win Percentage", comparison1.getDescription() )
        XCTAssertEqual("P2 Win Percentage", comparison2.getDescription() )
        
        let char1 = CharacterPref( name : "ryu", p1Rating: 1, p2Rating: 4)
        char1.p1Statistics = UsageStatistic(qtyBattles: 4, qtyWins: 1, lastBattle: now, lastWin: now)
        char1.p2Statistics = UsageStatistic(qtyBattles: 8, qtyWins: 6, lastBattle: now, lastWin: yesterday)
        let char2 = CharacterPref( name : "ken", p1Rating: 2, p2Rating: 5)
        // missing p1Statistics
        char2.p2Statistics = UsageStatistic(qtyBattles: 8, qtyWins: 4, lastBattle: twoWeeks, lastWin: twoMonths)
        let char3 = CharacterPref( name : "juri", p1Rating: 3, p2Rating: 6)
        char3.p1Statistics = UsageStatistic(qtyBattles: 10, qtyWins: 2, lastBattle: nil, lastWin: nil)
        // missing p2Statistics
        
        XCTAssert( comparison1.isGreater(char1, char2) )
        XCTAssertEqual("25% (1/4)", comparison1.getFormattedValue(pref: char1))
        XCTAssert( !comparison1.isGreater(char2, char3) )
        XCTAssertEqual("", comparison1.getFormattedValue(pref: char2))
        XCTAssert( comparison1.isGreater(char1, char3) )
        XCTAssertEqual("20% (2/10)", comparison1.getFormattedValue(pref: char3))
        
        XCTAssert( comparison2.isGreater(char1, char2) )
        XCTAssertEqual("75% (6/8)", comparison2.getFormattedValue(pref: char1))
        XCTAssert( comparison2.isGreater(char2, char3) )
        XCTAssertEqual("50% (4/8)", comparison2.getFormattedValue(pref: char2))
        XCTAssert( !comparison2.isGreater(char3, char1) )
        XCTAssertEqual("", comparison2.getFormattedValue(pref: char3))
        
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison1.trend(char1))
        XCTAssertEqual(StatisticsTrend.TrendingDown, comparison2.trend(char1))
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison1.trend(char2))
        XCTAssertEqual(StatisticsTrend.TrendingDown, comparison2.trend(char2))
    }
    
    func testCompareMostRecent() {
        let comparison1 = CompareRecentlyUsed(isP1: true, today: now)
        let comparison2 = CompareRecentlyUsed(isP1: false, today: now)
        
        XCTAssertEqual("P1 Recent", comparison1.getDescription() )
        XCTAssertEqual("P2 Recent", comparison2.getDescription() )
        
        let ryu = CharacterPref( name : "ryu", p1Rating: 1, p2Rating: 4)
        ryu.p1Statistics = UsageStatistic(qtyBattles: 4, qtyWins: 1, lastBattle: now, lastWin: nil)
        ryu.p2Statistics = UsageStatistic(qtyBattles: 8, qtyWins: 6, lastBattle: yesterday, lastWin: nil)
        let ken = CharacterPref( name : "ken", p1Rating: 1, p2Rating: 4)
        ken.p1Statistics = UsageStatistic(qtyBattles: 4, qtyWins: 1, lastBattle: now, lastWin: nil)
        ken.p2Statistics = UsageStatistic(qtyBattles: 8, qtyWins: 6, lastBattle: now, lastWin: nil)
        let laura = CharacterPref( name : "laura", p1Rating: 5, p2Rating: 1)
        laura.p1Statistics = UsageStatistic(qtyBattles: 2, qtyWins: 1, lastBattle: twoWeeks, lastWin: nil)
        let ibuki = CharacterPref( name : "ibuki", p1Rating: 1, p2Rating: 5)
        ibuki.p2Statistics = UsageStatistic(qtyBattles: 4, qtyWins: 1, lastBattle: lastMonth, lastWin: nil)
        let karin = CharacterPref( name: "karin", p1Rating: 4, p2Rating : 4)
        karin.p1Statistics = UsageStatistic(qtyBattles: 3, qtyWins: 2, lastBattle: twoMonths, lastWin: nil)
        
        XCTAssert( comparison1.isGreater(ken, ryu) ) // alphabatical order
        XCTAssert( comparison1.isGreater(ken, laura) )
        XCTAssert( comparison1.isGreater(laura, ibuki) )
        XCTAssert( !comparison1.isGreater(ibuki, ryu))
        XCTAssert( comparison1.isGreater(laura, karin))
        
        XCTAssertEqual("Today", comparison1.getFormattedValue(pref: ryu))
        XCTAssertEqual("Yesterday", comparison2.getFormattedValue(pref: ryu))
        XCTAssertEqual("Today", comparison1.getFormattedValue(pref: ken))
        XCTAssertEqual("Today", comparison2.getFormattedValue(pref: ken))
        XCTAssertEqual("2 Weeks Ago", comparison1.getFormattedValue(pref: laura))
        XCTAssertEqual("", comparison2.getFormattedValue(pref: laura))
        XCTAssertEqual("", comparison1.getFormattedValue(pref: ibuki))
        XCTAssertEqual("4 Weeks Ago", comparison2.getFormattedValue(pref: ibuki))
        XCTAssertEqual("2 Months Ago", comparison1.getFormattedValue(pref: karin))
        XCTAssertEqual("", comparison2.getFormattedValue(pref: karin))

        XCTAssert( comparison2.isGreater(ken, ryu) )
        XCTAssert( comparison2.isGreater(ken, laura) )
        XCTAssert( !comparison2.isGreater(laura, ibuki) )
        XCTAssertEqual("", comparison2.getFormattedValue(pref: laura))
        XCTAssert( !comparison2.isGreater(ibuki, ryu))
        
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison1.trend(ryu))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison2.trend(ryu))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison1.trend(ken))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison2.trend(ken))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison1.trend(laura))
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison2.trend(laura))
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison1.trend(ibuki))
        XCTAssertEqual(StatisticsTrend.TrendingUp, comparison2.trend(ibuki))
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison1.trend(karin))
        XCTAssertEqual(StatisticsTrend.NoTrend, comparison2.trend(karin))
    }
}

