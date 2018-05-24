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

func getUserFormatter() -> DateFormatter {
    let formatter = DateFormatter()
    formatter.timeZone = TimeZone(secondsFromGMT: 0)
    formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
    return formatter
}

func simplifyName( _ name : String ) -> String {
    return name.lowercased().replacingOccurrences(of: ".", with: "")
}

// "struct" implementation so it has copy rather than reference semantics
struct UsageStatistic : Equatable {
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
    
    func addResult( won: Bool, date: Date = Date() ) -> UsageStatistic {
        let nextQtyBattles = qtyBattles + 1
        let nextLastBattle = (nil == lastBattle) ? date : max(date, lastBattle!)
        let nextQtyWins = won ? qtyWins+1 : qtyWins;
        let nextLastWin = won ? ((nil == lastWin) ? date : max(date, lastWin!)) : lastWin
        return UsageStatistic(qtyBattles: nextQtyBattles, qtyWins: nextQtyWins, lastBattle: nextLastBattle, lastWin: nextLastWin)
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

// "struct" implementation so it has copy rather than reference semantics
struct BattleResult : Equatable {
    var date : Date
    var p1Id : String
    var p1Name : String
    var p2Id : String
    var p2Name : String
    var p1Won : Bool
    var id : String?
    
    static let keyDate = "date"
    static let keyP1Id = "p1Id"
    static let keyP1Name = "p1Name"
    static let keyP2Id = "p2Id"
    static let keyP2Name = "p2Name"
    static let keyP1Won = "p1Won"
    static let valueTrue = "true"
    static let valueFalse = "false"
    
    init( date: Date, p1Id : String, p1Name: String, p2Id : String, p2Name: String, p1Won : Bool, id: String?) {
        self.date = date
        self.p1Id = p1Id
        self.p1Name = p1Name
        self.p2Id = p2Id
        self.p2Name = p2Name
        self.p1Won = p1Won
        self.id = id
    }
    
    func toMap( ) -> [String:Any] {
        let dateFormatter = getFormatter()
        let strDate = dateFormatter.string(from: date)
        
        return [ BattleResult.keyP1Id : p1Id,
                 BattleResult.keyP1Name : p1Name,
                 BattleResult.keyP2Id : p2Id,
                 BattleResult.keyP2Name : p2Name,
                 BattleResult.keyDate : strDate,
                 BattleResult.keyP1Won : p1Won ]

    }
    
    static func initFromMap( fromMap map: [String:Any], withId id: String ) -> BattleResult? {
        if let pDate = map[keyDate] as? String,
            let pP1Id = map[keyP1Id] as? String,
            let pP1Name = map[keyP1Name] as? String,
            let pP2Id = map[keyP2Id] as? String,
            let pP2Name = map[keyP2Name] as? String,
            let pP1Won = map[keyP1Won] as? Bool {
            
            let formatter = getFormatter()
 
            if let date = formatter.date(from: pDate) {
                return BattleResult(date: date, p1Id: pP1Id, p1Name: pP1Name, p2Id: pP2Id, p2Name: pP2Name, p1Won: pP1Won, id: id)
            } else {
                debugPrint("Bad date")
                return nil
            }
        } else {
            debugPrint("missing values in result map")
            return nil
        }
    }
    
    func updateDate( _ newDate : Date ) -> BattleResult {
        return BattleResult(date: newDate, p1Id: p1Id, p1Name: p1Name, p2Id: p2Id, p2Name: p2Name, p1Won: p1Won, id: id)
    }
    
    func updateWinner( p1Win : Bool ) -> BattleResult {
        return BattleResult(date: date, p1Id: p1Id, p1Name: p1Name, p2Id: p2Id, p2Name: p2Name, p1Won: p1Win, id: id)
    }
    
    func updateP1Char( _ p1Char : CharacterPref ) -> BattleResult {
        return BattleResult(date: date, p1Id: p1Char.id!, p1Name: p1Char.name, p2Id: p2Id, p2Name: p2Name, p1Won: p1Won, id: id)
    }
    
    func updateP2Char( _ p2Char : CharacterPref ) -> BattleResult {
        return BattleResult(date: date, p1Id: p1Id, p1Name: p1Name, p2Id: p2Char.id!, p2Name: p2Char.name, p1Won: p1Won, id: id)
    }
    
    static func == (lhs : BattleResult, rhs : BattleResult) -> Bool {
        return lhs.date == rhs.date &&
            lhs.id == rhs.id &&
            lhs.p1Id == rhs.p1Id &&
            lhs.p1Won == rhs.p1Won &&
            lhs.p2Id == rhs.p2Id &&
            lhs.p2Name == rhs.p2Name &&
            lhs.p1Won == rhs.p1Won
    }
}

struct CharacterPref : Equatable {
    static func == (lhs: CharacterPref, rhs: CharacterPref) -> Bool {
        return lhs.id == rhs.id
            && lhs.name == rhs.name
            && lhs.p1Rating == rhs.p1Rating
            && lhs.p2Rating == rhs.p2Rating
            && lhs.p1Statistics == rhs.p1Statistics
            && lhs.p2Statistics == rhs.p2Statistics
    }
    
    var id : String?
    var name : String
    var p1Rating : Int
    var p2Rating: Int
    var p1Statistics : UsageStatistic?
    var p2Statistics : UsageStatistic?
    
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
    
    func changeName( _ newName : String ) -> CharacterPref {
        return CharacterPref(name: newName, p1Rating: p1Rating, p2Rating: p2Rating, id: id, p1Statistics: p1Statistics, p2Statistics: p2Statistics)
    }
    
    func changeP1Rating( _ rating : Int ) -> CharacterPref {
        return CharacterPref(name: name, p1Rating: rating, p2Rating: p2Rating, id: id, p1Statistics: p1Statistics, p2Statistics: p2Statistics)
    }
    
    func changeP2Rating( _ rating : Int ) -> CharacterPref {
        return CharacterPref(name: name, p1Rating: p1Rating, p2Rating: rating, id: id, p1Statistics: p1Statistics, p2Statistics: p2Statistics)
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

func userResultsDirRef( database : Database ) -> DatabaseReference? {
    if let userHome = userDir() {
        let path = userHome + "/results"
        return database.reference(withPath: path)
    }
    return nil
}

func userResultsRecordRef( database : Database, id: String ) -> DatabaseReference? {
    if let resDir = userResultsDirRef(database: database) {
        return resDir.child(id)
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

private func updateStatisticsMap( map: inout [String:UsageStatistic], key: String, won: Bool, date: Date ) {
    var statistic = map[key, default: UsageStatistic()]
    statistic = statistic.addResult(won: won, date:date)
    map[key] = statistic
}

private func updateStatisticsMapMap( map: inout [String:[String:UsageStatistic]], key1: String, key2: String, won: Bool, date: Date) {
    var statsMap = map[key1, default: [String:UsageStatistic]()]
    updateStatisticsMap(map: &statsMap, key: key2, won: won, date: date)
    map[key1] = statsMap
}

func parseResultsSnapshot( snapshot : DataSnapshot ) -> [BattleResult] {
    var ret = [BattleResult]()
    if let results = snapshot.value as? [String:[String:Any]] {
        for pair in results {
            if let result = BattleResult.initFromMap(fromMap: pair.value, withId: pair.key) {
                ret.append( result )
            }
        }
    }
    return ret
}

func regenerateStatistics( database: Database, snapshot: DataSnapshot, p1CharId : String? = nil, p2CharId : String? = nil) {
    let results = parseResultsSnapshot(snapshot: snapshot)
    regenerateStatistics(database: database, results: results, p1CharId: p1CharId, p2CharId: p2CharId)
}
    
func regenerateStatistics( database: Database, results: [BattleResult], p1CharId : String? = nil, p2CharId : String? = nil) {

    var overall = UsageStatistic()
    var p1CharOverall = [String:UsageStatistic]()
    var p2CharOverall = [String:UsageStatistic]()
    var p1CharMap = [String:[String:UsageStatistic]]()
    var p2CharMap = [String:[String:UsageStatistic]]()
    
    // generate statistics
    for result in results {
        let date = result.date
        let p1Id = result.p1Id
        let p2Id = result.p2Id
        let p1Won = result.p1Won
        
        overall = overall.addResult(won: p1Won, date: date)
        
        updateStatisticsMap(map: &p1CharOverall, key: p1Id, won: p1Won, date: date)
        updateStatisticsMap(map: &p2CharOverall, key: p2Id, won: !p1Won, date: date)
        
        updateStatisticsMapMap(map: &p1CharMap, key1: p1Id, key2: p2Id, won: p1Won, date: date)
        updateStatisticsMapMap(map: &p2CharMap, key1: p2Id, key2: p1Id, won: !p1Won, date: date)
    }
    
    // store statistics
    if let refOverall = overallStatisticsRef(database: database) {
        refOverall.setValue(overall.toMap())
    }
    
    // store overall p1 results
    for kv in p1CharOverall {
        if let ref = p1CharacterStatisticsRef(database: database, characterId: kv.key) {
            ref.setValue(kv.value.toMap())
        }
    }
    
    // store overall p2 results
    for kv in p2CharOverall {
        if let ref = p2CharacterStatisticsRef(database: database, characterId: kv.key) {
            ref.setValue(kv.value.toMap())
        }
    }
    
    // store per character p1 stats
    for kkv in p1CharMap {
        if nil == p1CharId || kkv.key == p1CharId {
            for kv in kkv.value {
                if nil == p2CharId || kv.key == p2CharId {
                    if let ref = p1VsStatisticsRef(database: database, p1Id: kkv.key, p2Id: kv.key) {
                        ref.setValue(kv.value.toMap())
                    }
                }
            }
        }
    }
    
    // store per character p2 stats
    for kkv in p2CharMap {
        if nil == p2CharId || kkv.key == p2CharId {
            for kv in kkv.value {
                if nil == p1CharId || kv.key == p1CharId {
                    if let ref = p2VsStatisticsRef(database: database, p2Id: kkv.key, p1Id: kv.key) {
                        ref.setValue(kv.value.toMap())
                    }
                }
            }
        }
    }
}

func renameResults( database: Database, snapshot: DataSnapshot, pref : CharacterPref ) {
    
    var results = parseResultsSnapshot(snapshot: snapshot)
    
    // update name
    let range = 0...(results.count-1)
    for idx in range {
        var result = results[idx]
        if let id = result.id {
            
            var changed = false
                
            if result.p1Id == pref.id {
                result = result.updateP1Char(pref)
                changed = true
            }
                
            if result.p2Id == pref.id {
                result = result.updateP2Char(pref)
                changed = true
            }
                
            if changed {
                if let ref = userResultsRecordRef( database : database, id: id ) {
                    let serialise = result.toMap()
                    ref.setValue(serialise)
                }
                
                results[idx] = result
            }
        }
    }
    
    // regenerate statistics
    regenerateStatistics(database: database, results: results)
}

