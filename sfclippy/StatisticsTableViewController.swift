//
//  StatisticsTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 24/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class StatisticGroup {
    let name : String
    let p1Desc : String
    let p1Comp : StatisticsCompare
    let p2Desc : String
    let p2Comp : StatisticsCompare
    
    init( name: String, p1Desc: String, p1Comp: StatisticsCompare, p2Desc: String, p2Comp : StatisticsCompare ) {
        self.name = name
        self.p1Desc = p1Desc
        self.p1Comp = p1Comp
        self.p2Desc = p2Desc
        self.p2Comp = p2Comp
    }
}

class StatisticsTableViewController: UITableViewController {
    var entries = [StatisticGroup?]()
    let p1Image = #imageLiteral(resourceName: "icon_24_win1")
    let p2Image = #imageLiteral(resourceName: "icon_24_win2")
    var refOverall : DatabaseReference?
    var refCharacters : DatabaseReference?
    var observerOverall : UInt?
    var observerCharacters: UInt?
    var characters = [CharacterPref]()
    let today = Date(timeIntervalSinceNow: 0)
    let compareP1Wins = CompareQtyWins(isP1: true, today: Date(timeIntervalSinceNow: 0))
    let compareP2Wins = CompareQtyWins(isP1: false, today: Date(timeIntervalSinceNow: 0))
    let compareP1Popular = CompareQtyBattles(isP1: true, today: Date(timeIntervalSinceNow: 0))
    let compareP2Popular = CompareQtyBattles(isP1: false, today: Date(timeIntervalSinceNow: 0))
    let compareP1Percent = CompareWinPercent(isP1: true, today: Date(timeIntervalSinceNow: 0))
    let compareP2Percent = CompareWinPercent(isP1: false, today: Date(timeIntervalSinceNow: 0))
    let compareP1Mru = CompareRecentlyUsed(isP1: true, today: Date(timeIntervalSinceNow: 0))
    let compareP2Mru = CompareRecentlyUsed(isP1: false, today: Date(timeIntervalSinceNow: 0))
    var currentCompare : StatisticsCompare?
    var currentIsP1 : Bool?
    
    enum StatIndices : Int {
        case OverallIdx = 0
        case PopularIdx = 1
        case WinRatio = 2
        case RecentlyUsed = 3
    }

    func getNthSection( index: Int ) -> StatisticGroup? {
        var current = 0
        for it in entries {
            if let group = it {
                if current == index {
                    return group
                }
                current += 1
            }
        }
        return nil
    }
    
    func updateOverall(snapshot: DataSnapshot) {
        if let map = snapshot.value as? [String:Any],
            let val = UsageStatistic.initFromMap(fromMap: map) {
            let p1Wins = val.qtyWins
            let p2Wins = val.qtyBattles - val.qtyWins
            entries[StatIndices.OverallIdx.rawValue] = StatisticGroup( name: "Overall Wins", p1Desc: "\(p1Wins)", p1Comp: compareP1Wins, p2Desc: "\(p2Wins)", p2Comp : compareP2Wins)
            tableView.reloadData()
        }
    }
    
    func maxTuple( _ optionalFirst: (String,Int)?, _ second: (String,Int) ) -> (String,Int) {
        if let first = optionalFirst {
            if first.1 > second.1 {
                return first
            } else {
                return second
            }
        } else {
            return second
        }
    }
    
    func generateStatisticGroup( title : String, prefs: [CharacterPref], p1Compare : StatisticsCompare, p2Compare : StatisticsCompare ) -> StatisticGroup {
        let pop1 = characters.sorted { (prefa, prefb) -> Bool in return p1Compare.isGreater(prefa, prefb) }[0]
        let pop2 = characters.sorted { (prefa, prefb) -> Bool in return p2Compare.isGreater(prefa, prefb) }[0]
        
        let p1Desc = "\(pop1.name) - \(p1Compare.getFormattedValue(pref: pop1))"
        let p2Desc = "\(pop2.name) - \(p2Compare.getFormattedValue(pref: pop2))"
        
        return StatisticGroup( name: title, p1Desc: p1Desc, p1Comp: p1Compare, p2Desc: p2Desc, p2Comp : p2Compare)
    }
    
    func updateCharacters(snapshot: DataSnapshot) {
        
        var tmpCharacters = [CharacterPref]()
        if let characterMap = snapshot.value as? [String:Any] {
            for kv in characterMap {
                if let map = kv.value as? [String:Any],
                    let character = CharacterPref.initFromMap(fromMap: map, withId: kv.key) {
                    tmpCharacters.append(character)
                }
            }
        }
        
        characters = tmpCharacters
        
        if characters.count > 0 {

            entries[StatIndices.PopularIdx.rawValue] = generateStatisticGroup(title: "Favourite Character", prefs: characters, p1Compare: compareP1Popular, p2Compare: compareP2Popular)
            entries[StatIndices.WinRatio.rawValue] = generateStatisticGroup(title: "Win Ratio", prefs: characters, p1Compare: compareP1Percent, p2Compare: compareP2Percent)
            entries[StatIndices.RecentlyUsed.rawValue] = generateStatisticGroup(title: "Recently Used", prefs: characters, p1Compare: compareP1Mru, p2Compare: compareP2Mru)
            
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...5 {
                entries.append(nil)
        }
        
        let database = Database.database()
        refOverall = overallStatisticsRef(database: database)
        refCharacters = userCharactersDir( database : database )
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let overall = refOverall {
            observerOverall = overall.observe(.value, with: updateOverall)
        }
        
        if let chars = refCharacters {
            observerCharacters = chars.observe(.value, with: updateCharacters)
        }
        
        tableView.reloadData()
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let overall = refOverall,
            let overallObs = observerOverall {
            overall.removeObserver(withHandle: overallObs)
        }
        
        if let chars = refCharacters,
            let charsObs = observerCharacters {
            chars.removeObserver(withHandle: charsObs)
        }
        
        // clear all statistics
        let qtyEntries = entries.count
        for idx in 0...(qtyEntries-1) {
            entries[idx] = nil
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        var sections = 0
        for it in entries {
            if nil != it {
                sections += 1
            }
        }
        return sections
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 2
    }

    override func tableView(_ tableView : UITableView, titleForHeaderInSection section: Int) -> String? {
        
        if let info = getNthSection(index: section) {
            return info.name
        }
        
        return nil
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(named: "color_primary_1")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsCell", for: indexPath) as! StatisticsTableViewCell

        if let info = getNthSection(index: indexPath.section) {
            if 0 == indexPath.row {
                cell.labelTitle.text = info.p1Desc
                cell.imagePlayer.image = p1Image
                cell.imagePlayer.tintColor = UIColor(named: "color_primary")
                
            } else {
                cell.labelTitle.text = info.p2Desc
                cell.imagePlayer.image = p2Image
                cell.imagePlayer.tintColor = UIColor(named: "color_accent")
            }
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        debugPrint("selected row at \(indexPath.row)")
        
        if let info = getNthSection(index: indexPath.section) {
            if 0 == indexPath.row {
                currentCompare = info.p1Comp
                currentIsP1 = true
            } else {
                currentCompare = info.p2Comp
                currentIsP1 = false
            }

            performSegue(withIdentifier: "showStatistic", sender: self)
        }
    }

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? StatisticsDetailTableViewController,
            let compare = currentCompare {
            dest.optIsP1 = currentIsP1
            dest.compare = compare
            dest.stats = characters
        }
    }

}
