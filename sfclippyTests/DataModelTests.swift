//
//  DataModelTests.swift
//  sfclippyTests
//
//  Created by William Lee on 13/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import XCTest
@testable import sfclippy

// allow us to compare and debug CharacterPref
extension CharacterPref : Equatable, CustomStringConvertible {
    static public func ==( lhs : CharacterPref, rhs : CharacterPref ) -> Bool {
        return lhs.name == rhs.name &&
            lhs.p1Rating == rhs.p1Rating &&
            lhs.p2Rating == rhs.p2Rating &&
            lhs.p1Statistics == rhs.p1Statistics &&
            lhs.p2Statistics == rhs.p2Statistics &&
            lhs.id == rhs.id
    }
    
    public var description : String {
        return "CharacterPref{name=\(self.name)," +
                ",p1Rating=\(self.p1Rating)" +
                ",p2Rating=\(self.p2Rating)" +
                ",p1Stats=\(String(describing:self.p1Statistics))" +
                ",p2Stats=\(String(describing:self.p2Statistics))" +
                ",id=\(String(describing:self.id))"
    }
}

// allow us to compare and debug UsageStatistic
extension UsageStatistic : Equatable, CustomStringConvertible {
    
    static public func == (lhs : UsageStatistic, rhs : UsageStatistic ) -> Bool {
        if lhs.qtyBattles != rhs.qtyBattles {
            debugPrint("qty battles differs")
            return false
        }
        
        if lhs.qtyWins != rhs.qtyWins {
            debugPrint("qty wins differs")
            return false
        }
        
        if lhs.lastBattle != rhs.lastBattle {
            debugPrint("differing last battles")
            return false
        }
        
        if lhs.lastWin != rhs.lastWin {
            debugPrint("differing last win")
            return false
        }
        
        return true
    }
    
    public var description : String {
        return "UsageStatistic{wins=\(self.qtyWins),battles=\(self.qtyBattles),lastBattle=\(String(describing:self.lastBattle)),lastWin=\(String(describing:self.lastWin))}"
    }
}

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
    
    func testStatistics() {
        let original = UsageStatistic(qtyBattles: 0, qtyWins: 0, lastBattle: nil, lastWin: nil)
        let date1 = Date(timeIntervalSince1970: 24*60*60)
        
        let win = original.addResult(won: true, date: date1)
        XCTAssertEqual(win.lastBattle, date1)
        XCTAssertEqual(win.qtyBattles, 1)
        XCTAssertEqual(win.qtyWins, 1)
        XCTAssertEqual(win.lastWin, date1)
        
        let date2 = Date(timeIntervalSince1970: 48*60*60)
        let loss = win.addResult(won: false, date: date2)
        XCTAssertEqual(loss.lastBattle, date2)
        XCTAssertEqual(loss.qtyBattles, 2)
        XCTAssertEqual(win.qtyWins, 1)
        XCTAssertEqual(loss.lastWin, date1)
    }
    
    func testBasicPreferenceConservation() {
        // check we can de-serialise
        
        let original = CharacterPref(name: "Ryu", p1Rating: 2, p2Rating: 4)
        original.id = "XX"
        
        let serialised = original.toMap()
        guard let deserialised = CharacterPref.initFromMap(fromMap: serialised, withId: "XX") else {
            XCTFail("Unable to decode sample preference")
            return
        }
        
        XCTAssertEqual(original, deserialised)
    }
    
    func testUsagePreferenceConservation() {
        let start = Date(timeIntervalSince1970: 0)
        let next = Date(timeIntervalSince1970: 7*24*60*60)
        
        let noWins = UsageStatistic(qtyBattles: 1, qtyWins: 0, lastBattle: start, lastWin: nil)
        let noRecentWin = UsageStatistic(qtyBattles: 2, qtyWins: 1, lastBattle: next, lastWin: start)
        let winning = UsageStatistic(qtyBattles: 5, qtyWins: 5, lastBattle: next, lastWin: next)
        
        let character1 = CharacterPref(name: "Ryu", p1Rating: 5, p2Rating: 2, id: "XX", p1Statistics: noWins, p2Statistics: noRecentWin)
        let character2 = CharacterPref(name: "Ken", p1Rating: 3, p2Rating: 4, id: "YY", p1Statistics: noRecentWin, p2Statistics: winning)
        
        let serialised1 = character1.toMap()
        let serialised2 = character2.toMap()
        
        let deserialised1 = CharacterPref.initFromMap(fromMap: serialised1, withId: "XX")
        let deserialised2 = CharacterPref.initFromMap(fromMap: serialised2, withId: "YY")
        
        XCTAssertEqual(character1, deserialised1!)
        XCTAssertEqual(character2, deserialised2!)
    }
    
    func testPreferenceDeserialise() {
        
        let serialised = [ "name" : "Vega",
                           "p1Rating" : 1,
                           "p2Rating" : 4 ] as [String:Any]
        
        let deserialised = CharacterPref.initFromMap(fromMap: serialised, withId: "ZZZ")
        guard let pref = deserialised else {
            XCTFail("Problem de-serialising")
            return
        }
        XCTAssertEqual("Vega", pref.name)
        XCTAssertEqual(1, pref.p1Rating)
        XCTAssertEqual(4, pref.p2Rating)
        XCTAssertEqual("ZZZ", pref.id)
    }
    
    func testUsagePreferenceDeserialise() {
        
        let p1Statistic = [ "lastBattle" : "2018-04-12T21:02:14",
                            "lastWin" : "2018-04-12T21:02:14",
                            "qtyBattles" : 16,
                            "qtyWins" : 8 ] as [String:Any]
        let p2Statistic = [ "lastBattle" : "2018-05-10T21:12:49",
                            "lastWin" : "2018-05-10T21:12:49",
                            "qtyBattles" : 30,
                            "qtyWins" : 16] as [String:Any]
        let serialised = [ "name" : "Balrog",
                           "p1Rating" : 2,
                           "p1Statistics" : p1Statistic,
                           "p2Rating" : 3,
                           "p2Statistics" : p2Statistic ] as [String:Any]
        
        let deserialised = CharacterPref.initFromMap(fromMap: serialised, withId: "WWW")
        guard let pref = deserialised else {
            XCTFail("Problem de-serialising")
            return
        }
        XCTAssertEqual("Balrog", pref.name)
        XCTAssertEqual(2, pref.p1Rating)
        XCTAssertEqual(3, pref.p2Rating)
        XCTAssertEqual("WWW", pref.id)
        
        guard let stats1 = pref.p1Statistics else {
            XCTFail("Missing p1 stats")
            return
        }
        XCTAssertEqual(16, stats1.qtyBattles)
        XCTAssertEqual(8, stats1.qtyWins)
        XCTAssertEqual("2018-04-12T21:02:14", getFormatter().string(from: stats1.lastBattle!))
        XCTAssertEqual("2018-04-12T21:02:14", getFormatter().string(from: stats1.lastWin!))

        guard let stats2 = pref.p2Statistics else {
            XCTFail("Missing p2 stats")
            return
        }
        XCTAssertEqual(30, stats2.qtyBattles)
        XCTAssertEqual(16, stats2.qtyWins)
        XCTAssertEqual("2018-05-10T21:12:49", getFormatter().string(from: stats2.lastBattle!))
        XCTAssertEqual("2018-05-10T21:12:49", getFormatter().string(from: stats2.lastWin!))
    }
    
    func testCompareBattleResult( ) {
        let originalDate = Date(timeIntervalSince1970: 24*60*60)
        let originalP1Id = "P1XX";
        let originalP1Name = "Ryu"
        let originalP2Id = "P2YY"
        let originalP2Name = "Ken"
        let originalP1Won = false
        let id = "ZZ"
        let originalResult = BattleResult(date: originalDate, p1Id: originalP1Id, p1Name: originalP1Name, p2Id: originalP2Id, p2Name: originalP2Name, p1Won: originalP1Won, id: id)
        
        // check direct copy compares equally
        let copyResult = BattleResult(date: originalDate, p1Id: originalP1Id, p1Name: originalP1Name, p2Id: originalP2Id, p2Name: originalP2Name, p1Won: originalP1Won, id: id)
        XCTAssertEqual(originalResult, copyResult)
        
        // check different winner compares differently
        let differentWinner = copyResult.updateWinner(p1Win: true)
        XCTAssertTrue(originalResult != differentWinner)
        
        // check different date compares differently
        let differentDate = copyResult.updateDate(Date(timeIntervalSince1970: 2*24*60*60))
        XCTAssertTrue(originalResult != differentDate)
        
        // check different p1 compares differently
        let alternativeP1 = CharacterPref(name: "Zangief", p1Rating: 1, p2Rating: 2, id: "ZZ", p1Statistics: nil, p2Statistics: nil)
        let differentP1 = copyResult.updateP1Char(alternativeP1)
        XCTAssertTrue(originalResult != differentP1)
        
        // check different p2 compares differently
        let alternativeP2 = CharacterPref(name: "Laura", p1Rating: 1, p2Rating: 2, id: "LL", p1Statistics: nil, p2Statistics: nil)
        let differentP2 = copyResult.updateP1Char(alternativeP2)
        XCTAssertTrue(originalResult != differentP2)
    }
    
    func testBattleResultMutation( ) {
        let originalDate = Date(timeIntervalSince1970: 24*60*60)
        let originalP1Id = "P1XX";
        let originalP1Name = "Ryu"
        let originalP2Id = "P2YY"
        let originalP2Name = "Ken"
        let originalP1Won = false
        let id = "ZZ"
        let originalResult = BattleResult(date: originalDate, p1Id: originalP1Id, p1Name: originalP1Name, p2Id: originalP2Id, p2Name: originalP2Name, p1Won: originalP1Won, id: id)
        
        // change player 1 character
        let pref1 = CharacterPref(name: "Juri", p1Rating: 1, p2Rating: 2)
        pref1.id = "AA"
        let changedP1 = originalResult.updateP1Char(pref1)
        XCTAssertEqual(pref1.name, changedP1.p1Name)
        XCTAssertEqual(pref1.id, changedP1.p1Id)
        XCTAssertEqual(originalP2Id, changedP1.p2Id)
        XCTAssertEqual(originalP2Name, changedP1.p2Name)
        
        // change player 2 character
        let pref2 = CharacterPref(name: "Dhalsim", p1Rating: 1, p2Rating: 2)
        pref2.id = "BB"
        let changedP2 = originalResult.updateP2Char(pref2)
        XCTAssertEqual(originalP1Name, changedP2.p1Name)
        XCTAssertEqual(originalP1Id, changedP2.p1Id)
        XCTAssertEqual(pref2.name, changedP2.p2Name)
        XCTAssertEqual(pref2.id, changedP2.p2Id)
        
        // change winner
        let changedWinner = originalResult.updateWinner(p1Win: true)
        XCTAssertEqual(changedWinner.p1Won, true)
        
        // change date
        let date2 = Date(timeIntervalSince1970: 2*24*60*60)
        let changedDate = originalResult.updateDate(date2)
        XCTAssertEqual(date2, changedDate.date)
    }
}
