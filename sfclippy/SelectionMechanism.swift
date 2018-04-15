//
//  SelectionMechanisms.swift
//  sfclippy
//
//  Created by William Lee on 23/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//
import Foundation

protocol RandomGenerator {
    func randomInteger( _ max : Int ) -> Int;
}

class SelectionMechanism {
    var generator : RandomGenerator
    
    init( _ generator : RandomGenerator ) {
        self.generator = generator
    }
    
    func randomCharacter( _ characters: [CharacterPref] ) -> CharacterPref {
        let max = characters.count
        let index = generator.randomInteger(max)
        return characters[index]
    }
    
    func preferredCharacter( _ characters: [CharacterPref], playerId: Int ) -> CharacterPref {
        let max = characters.reduce(0) { (result : Int, pref : CharacterPref) -> Int in
            let rating = pref.rating(playerId)
            let input = rating > 1 ? rating : 0
            return result + (input * input)
        }
        let index = generator.randomInteger(max)
        var total = -1 // due to random being [0,n-1]
        var ret = characters.first!
        for character in characters {
            let rating = character.rating(playerId)
            let contrib = rating > 1 ? rating : 0
            total += (contrib * contrib)
            if total >= index {
                ret = character
                break
            }
        }
        return ret
    }
    
    private func isUsageOlder( optA : UsageStatistic?, optB : UsageStatistic? ) -> Bool {
        if let prefA = optA,
            let prefB = optB {
            
            if let battleA = prefA.lastBattle,
                let battleB = prefB.lastBattle {
                return battleA < battleB
            } else if nil == prefA.lastBattle {
                return true
            } else {
                //nil == prefB.lastBattle
                return false
            }
        } else if nil == optA {
            return true
        } else {
            // nil == optB
            return false
        }
    }
    
    func leastRecentlyUsed( _ preferences: [CharacterPref], playerId: Int ) -> CharacterPref {
        
        var extract = { (pref : CharacterPref ) -> UsageStatistic? in return pref.p1Statistics }
        if ( playerId == 1 ) {
            extract = { (pref : CharacterPref) -> UsageStatistic? in return pref.p2Statistics }
        }
        
        // sort
        let sorted = preferences.sorted { (prefa, prefb) -> Bool in return self.isUsageOlder(optA: extract(prefa), optB: extract(prefb) )
        }
        /*debugPrint("playerId \(playerId)")
        for a in sorted {
            debugPrint("\(a)")
        }*/
        
        let sampleSize = min(5, sorted.count)
        let random = generator.randomInteger(sampleSize)
        return sorted[random]
    }
}
