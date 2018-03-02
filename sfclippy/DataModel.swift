//
//  DataModel.swift
//  sfclippy
//
//  Created by William Lee on 19/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import Foundation
import FirebaseDatabase
import FirebaseAuth

func getFormatter( ) -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss"
    return formatter
}

class UsageStatistic {
    var qtyBattles : Int
    var qtyWins : Int
    var lastBattle : Date?
    var lastWin : Date?
    
    static let keyQtyBattles = "qtyBattles"
    static let keyQtyWins = "qtyWins"
    static let keyLastBattle = "lastBattle"
    static let keyLastWin = "lastWin"
    
    init( qtyBattles: Int = 0, qtyWins : Int = 0, lastBattle: Date? = nil, lastWin: Date? = nil ) {
        self.qtyBattles = qtyBattles
        self.qtyWins = qtyWins
        self.lastBattle = lastBattle
        self.lastWin = lastWin
    }
    
    func addResult( won: Bool, date: Date = Date() ) {
        qtyBattles += 1
        lastBattle = (nil == lastBattle) ? date : max(date, lastBattle!)
        if won {
            qtyWins += 1
            lastWin = (nil == lastWin) ? date : max(date, lastWin!)
        }
    }
    
    func toMap( ) -> [String:Any] {
        let dateFormatter = getFormatter()
        
        var lastBattleStr = ""
        var lastWinStr = ""
        if let unwrappedBattle = lastBattle {
            lastBattleStr = dateFormatter.string(from: unwrappedBattle)
        }
        if let unwrappedWin = lastWin {
            lastWinStr = dateFormatter.string(from: unwrappedWin)
        }
        
        return [ UsageStatistic.keyQtyBattles : qtyBattles,
                 UsageStatistic.keyQtyWins: qtyWins,
                 UsageStatistic.keyLastBattle : lastBattleStr,
                 UsageStatistic.keyLastWin : lastWinStr ]
    }
    
    static func initFromMap( fromMap map: [String:Any] ) -> UsageStatistic? {
        if let qtyBattles = map[keyQtyBattles] as? Int,
            let qtyWins = map[keyQtyWins] as? Int,
            let strLastBattle = map[keyLastBattle] as? String,
            let strLastWin = map[keyLastWin] as? String {
            
            let dateFormatter = getFormatter()
            let lastBattle = dateFormatter.date(from: strLastBattle)
            let lastWin = dateFormatter.date(from: strLastWin)

            return UsageStatistic(qtyBattles: qtyBattles, qtyWins: qtyWins, lastBattle: lastBattle, lastWin: lastWin)
        } else {
            debugPrint("missing statistic fields")
            return nil
        }
    }
}

class BattleResult {
    var date : Date
    var p1Id : String
    var p2Id : String
    var p1Won : Bool
    
    static let keyDate = "date"
    static let keyP1 = "p1Character"
    static let keyP2 = "p2Character"
    static let keyP1Won = "p1Won"
    static let valueTrue = "true"
    static let valueFalse = "false"
    
    init( date: Date, p1Id : String, p2Id : String, p1Won : Bool) {
        self.date = date
        self.p1Id = p1Id
        self.p2Id = p2Id
        self.p1Won = p1Won
    }
    
    func toMap( ) -> [String:Any] {
        let dateFormatter = getFormatter()
        let strDate = dateFormatter.string(from: date)
        
        return [ BattleResult.keyP1 : p1Id,
                 BattleResult.keyP2 : p2Id,
                 BattleResult.keyDate : strDate,
                 BattleResult.keyP1Won : p1Won ]

    }
    
    static func initFromMap( fromMap map: [String:Any] ) -> BattleResult? {
        if let pDate = map[keyDate] as? String,
            let pP1Id = map[keyP1] as? String,
            let pP2Id = map[keyP2] as? String,
            let pP1Won = map[keyP1Won] as? Bool {
            
            let formatter = getFormatter()
 
            if let date = formatter.date(from: pDate) {
                return BattleResult(date: date, p1Id: pP1Id, p2Id: pP2Id, p1Won: pP1Won)
            } else {
                debugPrint("Bad date")
                return nil
            }
        } else {
            debugPrint("missing values in result map")
            return nil
        }
    }
}

class CharacterPref : Equatable, CustomStringConvertible {
    var id : String?
    var name : String
    var p1Rating : Int
    var p2Rating: Int
    var p1Statistics : UsageStatistic?
    var p2Statistics : UsageStatistic?

    var description: String {
        return "CharacterPref(\(name),\(p1Rating),\(p2Rating))"
    }
    
    static let keyName = "name"
    static let keyP1Rating = "p1Rating"
    static let keyP2Rating = "p2Rating"
    static let keyP1Stat = "p1Statistics"
    static let keyP2Stat = "p2Statistics"
    
    init( name : String, p1Rating: Int, p2Rating: Int, id : String? = nil, p1Statistics: UsageStatistic? = nil, p2Statistics: UsageStatistic? = nil  ) {
        self.name = name
        self.p1Rating = p1Rating
        self.p2Rating = p2Rating
        self.id = id
        self.p1Statistics = p1Statistics
        self.p2Statistics = p2Statistics
    }
    
    static func ==( lhs : CharacterPref, rhs : CharacterPref ) -> Bool {
        return lhs.name == rhs.name &&
            lhs.p1Rating == rhs.p1Rating &&
            lhs.p2Rating == rhs.p2Rating
    }
    
    func toMap( ) -> [String:Any] {
        var ret = [ CharacterPref.keyName : name,
                 CharacterPref.keyP1Rating : p1Rating,
        CharacterPref.keyP2Rating : p2Rating ] as [String:Any]
        
        if let p1Stats = p1Statistics {
            ret[CharacterPref.keyP1Stat] = p1Stats.toMap()
        }
        if let p2Stats = p2Statistics {
            ret[CharacterPref.keyP2Stat] = p2Stats.toMap()
        }
        return ret
    }
    
    func rating( _ playerId: Int ) -> Int {
        if 0 == playerId {
            return p1Rating
        } else {
            return p2Rating
        }
    }
    
    static func initFromMap( fromMap map : [String:Any], withId id : String ) -> CharacterPref? {
        if let name = map[keyName] as? String,
            let p1Rating = map[keyP1Rating] as? Int,
            let p2Rating = map[keyP2Rating] as? Int {
            
            var p1Statistics : UsageStatistic?
            if let pP1Stat = map[keyP1Stat] as? [String:Any] {
                p1Statistics = UsageStatistic.initFromMap(fromMap: pP1Stat)
            }
            
            var p2Statistics : UsageStatistic?
            if let pP2Stat = map[keyP2Stat] as? [String:Any] {
                p2Statistics = UsageStatistic.initFromMap(fromMap: pP2Stat)
            }
            
            return CharacterPref(name: name, p1Rating: p1Rating, p2Rating: p2Rating, id: id, p1Statistics: p1Statistics, p2Statistics: p2Statistics )
        } else {
            debugPrint("character map missing fields",map)
            return nil
        }
    }
}

func userDir( ) -> String? {
    if let uid = Auth.auth().currentUser?.uid {
        return "/users/" + uid
    }
    return nil
}

func userCharactersDir( database : Database ) -> DatabaseReference? {
    if let userHome = userDir() {
        let path = userHome + "/characters"
        return database.reference(withPath: path)
    }
    return nil
}

func userCharactersPref( database : Database, characterId : String ) -> DatabaseReference? {
    if let parent = userCharactersDir(database: database ) {
        return parent.child(characterId)
    }
    return nil
}

func userResultsRef( database : Database ) -> DatabaseReference? {
    if let userHome = userDir() {
        let path = userHome + "/results"
        return database.reference(withPath: path)
    }
    return nil
}

func overallStatisticsRef( database: Database ) -> DatabaseReference? {
    if let userHome = userDir() {
        let path = userHome + "/statistics/p1Statistics/overall"
        return database.reference(withPath: path)
    }
    return nil
}

func p1CharacterStatisticsRef( database: Database, characterId: String ) -> DatabaseReference? {
    return userCharactersPref(database: database, characterId: characterId)?.child("p1Statistics")
}

func p2CharacterStatisticsRef( database: Database, characterId: String ) -> DatabaseReference? {
    return userCharactersPref(database: database, characterId: characterId)?.child("p2Statistics")
}

func p1VsStatisticsRef( database: Database, p1Id : String, p2Id: String ) -> DatabaseReference? {
    if let userHome = userDir() {
        let path = userHome + "/statistics/p1Statistics/character/\(p1Id)/\(p2Id)"
        return database.reference(withPath: path)
    }
    return nil
}

func p2VsStatisticsRef( database: Database, p2Id: String, p1Id: String ) -> DatabaseReference? {
    if let userHome = userDir() {
        let path = userHome + "/statistics/p2Statistics/character/\(p2Id)/\(p1Id)"
        return database.reference(withPath: path)
    }
    return nil
}
