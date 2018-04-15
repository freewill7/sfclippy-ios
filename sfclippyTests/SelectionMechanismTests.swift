//
//  SelectionMechanismTests.swift
//  sfclippyTests
//
//  Created by William Lee on 23/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import XCTest
@testable import sfclippy

class SelectionMechanismTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    class ArrayRandomGenerator : RandomGenerator {
        var arr : [Int]
        var index = 0
        var recordedMaxes = [Int]()
        
        init( _ arr : [Int] ) {
            self.arr = arr
        }
        
        func randomInteger( _ max: Int ) -> Int {
            recordedMaxes.append( max )
            let current = index
            index = (index + 1) % arr.count
            return arr[current]
        }
    }
    
    func testRandom() {
        let char1 = CharacterPref( name : "ryu", p1Rating: 1, p2Rating: 4)
        let char2 = CharacterPref( name : "ken", p1Rating: 2, p2Rating: 5)
        let char3 = CharacterPref( name : "juri", p1Rating: 3, p2Rating: 6)
        let characters = [char1,char2,char3]
        
        let numbers = [0,2,1,1,2,1]
        let generator = ArrayRandomGenerator(numbers)
        let selector = SelectionMechanism( generator )
        
        XCTAssertEqual(char1, selector.randomCharacter(characters))
        XCTAssertEqual(char3, selector.randomCharacter(characters))
        XCTAssertEqual(char2, selector.randomCharacter(characters))
        XCTAssertEqual(char2, selector.randomCharacter(characters))
        XCTAssertEqual(char3, selector.randomCharacter(characters))
        XCTAssertEqual(char2, selector.randomCharacter(characters))
    }
    
    func testPreferred() {
        let char1 = CharacterPref( name : "ryu", p1Rating: 1, p2Rating: 5)
        let char2 = CharacterPref( name : "ken", p1Rating: 3, p2Rating: 3)
        let char3 = CharacterPref( name : "juri", p1Rating: 3, p2Rating: 1)
        let characters = [char1,char2,char3]

        // we don't want to select 1* players
        // but we want a bias towards popular choices
        // therefore contribution per rating: (n > 1) ? n*n : 0
        let p1Sum = 9 + 9
        let p1Randoms = [8,9,17] // ken, juri, juri
        let p1Generator = ArrayRandomGenerator(p1Randoms)
        let p1Selector = SelectionMechanism(p1Generator)
        XCTAssertEqual(char2, p1Selector.preferredCharacter(characters, playerId: 0))
        XCTAssertEqual(p1Sum, p1Generator.recordedMaxes.last!)
        XCTAssertEqual(char3, p1Selector.preferredCharacter(characters, playerId: 0))
        XCTAssertEqual(p1Sum, p1Generator.recordedMaxes.last!)
        XCTAssertEqual(char3, p1Selector.preferredCharacter(characters, playerId: 0))
        XCTAssertEqual(p1Sum, p1Generator.recordedMaxes.last!)
        
        //
        let p2Sum = 25 + 9
        let p2Randoms = [24,25,33] // ryu, ken, ken
        let p2Generator = ArrayRandomGenerator(p2Randoms)
        let p2Selector = SelectionMechanism(p2Generator)
        XCTAssertEqual(char1, p2Selector.preferredCharacter(characters, playerId: 1))
        XCTAssertEqual(p2Sum, p2Generator.recordedMaxes.last!)
        XCTAssertEqual(char2, p2Selector.preferredCharacter(characters, playerId: 1))
        XCTAssertEqual(p2Sum, p2Generator.recordedMaxes.last!)
        XCTAssertEqual(char2, p2Selector.preferredCharacter(characters, playerId: 1))
        XCTAssertEqual(p2Sum, p2Generator.recordedMaxes.last!)
    }
    
    func testLeastRecentlyUsed() {
        // no p1 usage, youngest p2 usage
        let char1 = CharacterPref( name: "ryu", p1Rating: 1, p2Rating: 1 )
        char1.p2Statistics = UsageStatistic(qtyBattles: 1, qtyWins: 0, lastBattle: Date(timeIntervalSince1970: 5000), lastWin: nil)
        
        // oldest p1 usage, no p2 usage
        let char2 = CharacterPref( name: "ken", p1Rating: 1, p2Rating: 1 )
        char2.p1Statistics = UsageStatistic(qtyBattles: 1, qtyWins: 0, lastBattle: Date(timeIntervalSince1970: 1000), lastWin: nil)
        
        // youngest p1 usage, oldest p2 usage
        let char3 = CharacterPref(name: "juri", p1Rating: 1, p2Rating: 1)
        char3.p1Statistics = UsageStatistic(qtyBattles: 1, qtyWins: 0, lastBattle: Date(timeIntervalSince1970: 2000), lastWin: nil)
        char3.p2Statistics = UsageStatistic(qtyBattles: 1, qtyWins: 0, lastBattle: Date(timeIntervalSince1970: 4000), lastWin: nil)
        
        let chars = [char1, char2, char3]
        
        // test p1 mechanism
        let p1Randoms = [2,1,0] // juri, ken, ryu
        let p1Generator = ArrayRandomGenerator(p1Randoms)
        let p1Selector = SelectionMechanism(p1Generator)
        XCTAssertEqual( char3, p1Selector.leastRecentlyUsed(chars, playerId: 0) )
        XCTAssertEqual( char2, p1Selector.leastRecentlyUsed(chars, playerId: 0) )
        XCTAssertEqual( char1, p1Selector.leastRecentlyUsed(chars, playerId: 0) )

        // test p2 mechanism
        let p2Randoms = [0,1,2] // ken, juri, ryu
        let p2Generator = ArrayRandomGenerator(p2Randoms)
        let p2Selector = SelectionMechanism(p2Generator)
        XCTAssertEqual( char2, p2Selector.leastRecentlyUsed(chars, playerId: 1) )
        XCTAssertEqual( char3, p2Selector.leastRecentlyUsed(chars, playerId: 1) )
        XCTAssertEqual( char1, p2Selector.leastRecentlyUsed(chars, playerId: 1) )
    }
    
}
