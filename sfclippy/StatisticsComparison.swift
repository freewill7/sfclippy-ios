//
//  StatisticsComparison.swift
//  sfclippy
//
//  Represents routines for comparing character statistics.
//
//  Created by William Lee on 02/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import Foundation

enum StatisticsTrend {
    case TrendingDown;
    case TrendingUp;
    case NoTrend;
}

private func extractStatistics( pref : CharacterPref, isP1 : Bool ) -> UsageStatistic? {
    return isP1 ? pref.p1Statistics : pref.p2Statistics
}

func identifyCharacterTrend( pref : CharacterPref, isP1 : Bool, today : Date ) -> StatisticsTrend {
    let ONE_MONTH = Double(28 * 24 * 60 * 60)
    
    if let stats = extractStatistics( pref: pref, isP1: isP1 ),
        let lastBattle = stats.lastBattle {
        if lastBattle.addingTimeInterval(ONE_MONTH) > today {
            guard let lastWin = stats.lastWin else {
                return StatisticsTrend.TrendingDown
            }
            
            if lastWin < lastBattle {
                return StatisticsTrend.TrendingDown
            } else {
                return StatisticsTrend.TrendingUp
            }
        }
    }
    
    return StatisticsTrend.NoTrend
}

protocol StatisticsCompare {
    // Return a description of this statistical comparison
    func getDescription( ) -> String
    
    // Compare two preferences
    func isGreater( _ pref1 : CharacterPref, _ pref2 : CharacterPref ) -> Bool
    
    // Return a user friendly representation of the statistic
    func getFormattedValue( pref : CharacterPref ) -> String
}

func compareValueThenName<T: Comparable>( _ value1: T, _ value2: T, name1 : String, name2 : String ) -> Bool {
    if value1 == value2 {
        return name1 < name2
    } else {
        return value1 > value2
    }
}

// Extracts number of wins from statistics
class CompareQtyWins : StatisticsCompare {
    let isP1 : Bool
    let today : Date
    let one_month = Double(28 * 24 * 60 * 60)
    
    init( isP1: Bool, today: Date ) {
        self.isP1 = isP1
        self.today = today
    }
    
    func getDescription() -> String {
        return "\(isP1 ? "P1" : "P2") Wins"
    }
    
    func isGreater( _ pref1 : CharacterPref, _ pref2 : CharacterPref ) -> Bool {
        guard let stats1 = extractStatistics(pref: pref1, isP1: isP1) else {
            return false
        }
        
        guard let stats2 = extractStatistics(pref: pref2, isP1: isP1) else {
            return true
        }
        
        return compareValueThenName( stats1.qtyWins, stats2.qtyWins, name1: pref1.name, name2: pref2.name )
    }
    
    func getFormattedValue(pref: CharacterPref) -> String {
        if let stats = extractStatistics(pref: pref, isP1: isP1) {
            return "\(stats.qtyWins)"
        }
        return "0"
    }
}

// Extracts number of battles from statistics
class CompareQtyBattles : StatisticsCompare {
    let isP1 : Bool
    let today : Date
    let one_month = Double(28 * 24 * 60 * 60)
    
    init( isP1: Bool, today: Date ) {
        self.isP1 = isP1
        self.today = today
    }
    
    func getDescription() -> String {
        return "\(isP1 ? "P1" : "P2") Usage"
    }
    
    func isGreater( _ pref1 : CharacterPref, _ pref2 : CharacterPref ) -> Bool {
        guard let stats1 = extractStatistics(pref: pref1, isP1: isP1) else {
            return false
        }
        
        guard let stats2 = extractStatistics(pref: pref2, isP1: isP1) else {
            return true
        }
        
        return compareValueThenName( stats1.qtyBattles, stats2.qtyBattles, name1: pref1.name, name2: pref2.name )
    }
    
    func getFormattedValue(pref: CharacterPref) -> String {
        if let stats = extractStatistics(pref: pref, isP1: isP1) {
            return "\(stats.qtyBattles)"
        }
        return "0"
    }
}

// Extracts win percentage from statistics
class CompareWinPercent : StatisticsCompare {
    let isP1 : Bool
    let today : Date
    let one_month = Double(28 * 24 * 60 * 60)

    init( isP1: Bool, today: Date ) {
        self.isP1 = isP1
        self.today = today
    }
    
    func getDescription() -> String {
        return "\(isP1 ? "P1" : "P2") Win Percentage"
    }

    func isGreater( _ pref1 : CharacterPref, _ pref2 : CharacterPref ) -> Bool {
        guard let stats1 = extractStatistics(pref: pref1, isP1: isP1) else {
            return false
        }
        
        guard let stats2 = extractStatistics(pref: pref2, isP1: isP1) else {
            return true
        }
        
        if stats1.qtyBattles < 4 {
            return false
        }
        if stats2.qtyBattles < 4 {
            return true
        }
        
        let win1 = (100 * stats1.qtyWins) / stats1.qtyBattles
        let win2 = (100 * stats2.qtyWins) / stats2.qtyBattles
        return compareValueThenName( win1, win2, name1: pref1.name, name2: pref2.name )
    }
    
    func getFormattedValue(pref: CharacterPref) -> String {
        let optStat = isP1 ? pref.p1Statistics : pref.p2Statistics
        if let stat = optStat,
            stat.qtyBattles >= 4 {
                let percent = (stat.qtyWins*100)/stat.qtyBattles
                return "\(percent)% (\(stat.qtyWins)/\(stat.qtyBattles))"
        }
        return ""
    }
}

// Extracts most recently used
class CompareRecentlyUsed : StatisticsCompare {
    let isP1 : Bool
    let today : Date
    let one_month = Double(28 * 24 * 60 * 60)
    let one_day = Double(24 * 60 * 60)
    let one_week = Double(7 * 24 * 60 * 60)
    
    init( isP1: Bool, today : Date ) {
        self.isP1 = isP1
        self.today = today
    }
    
    func getDescription() -> String {
        return "\(isP1 ? "P1" : "P2") Recent"
    }
    
    func isGreater( _ pref1 : CharacterPref, _ pref2 : CharacterPref ) -> Bool {
        guard let stats1 = extractStatistics(pref: pref1, isP1: isP1),
            let used1 = stats1.lastBattle else {
            return false
        }
        
        guard let stats2 = extractStatistics(pref: pref2, isP1: isP1),
            let used2 = stats2.lastBattle else {
            return true
        }
        
        return compareValueThenName( used1, used2, name1: pref1.name, name2: pref2.name )
    }
    
    func getFormattedValue(pref: CharacterPref) -> String {
        guard let stats = extractStatistics(pref: pref, isP1: isP1),
            let date = stats.lastBattle else {
            return ""
        }
        
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd"
        if let startOfToday = formatter.date(from: formatter.string(from: today)) {
            let startOfYesterday = startOfToday.addingTimeInterval(-1 * one_day)
            let startOfThisWeek = startOfToday.addingTimeInterval(-1 * one_week)
            let startOfThisMonth = startOfToday.addingTimeInterval(-1 * one_month)
            
            if date > startOfToday {
                return "Today"
            } else if date > startOfYesterday {
                return "Yesterday"
            } else if date > startOfThisWeek {
                let days = Int(today.timeIntervalSince(date) / one_day) + 1
                return "\(days) Days Ago"
            } else if date > startOfThisMonth {
                let weeks = Int(today.timeIntervalSince(date) / one_week) + 1
                return "\(weeks) Weeks Ago"
            } else {
                let months = Int(today.timeIntervalSince(date) / one_month) + 1
                return "\(months) Months Ago"
            }
        }
        
        return formatter.string(from: date)
    }
}
