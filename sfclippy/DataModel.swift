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
    
    init( date: Date, p1Id : String, p2Id : String, p1Won : Bool ) {
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
    
    var description: String {
        return "CharacterPref(\(name),\(p1Rating),\(p2Rating))"
    }
    
    static let keyName = "name"
    static let keyP1Rating = "p1Rating"
    static let keyP2Rating = "p2Rating"
    
    init( name : String, p1Rating: Int, p2Rating: Int, id : String? = nil ) {
        self.name = name
        self.p1Rating = p1Rating
        self.p2Rating = p2Rating
        self.id = id
    }
    
    static func ==( lhs : CharacterPref, rhs : CharacterPref ) -> Bool {
        return lhs.name == rhs.name &&
            lhs.p1Rating == rhs.p1Rating &&
            lhs.p2Rating == rhs.p2Rating
    }
    
    func toMap( ) -> [String:Any] {
        return [ CharacterPref.keyName : name,
                 CharacterPref.keyP1Rating : p1Rating,
                 CharacterPref.keyP2Rating : p2Rating ]
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
            return CharacterPref(name: name, p1Rating: p1Rating, p2Rating: p2Rating, id: id )
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
