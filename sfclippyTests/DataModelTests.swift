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
}
