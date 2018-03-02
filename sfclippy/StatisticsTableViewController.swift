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
    let p2Desc : String
    
    init( name: String, p1Desc: String, p2Desc: String ) {
        self.name = name
        self.p1Desc = p1Desc
        self.p2Desc = p2Desc
    }
}

class StatisticsTableViewController: UITableViewController {
    var entries = [StatisticGroup?]()
    let p1Image = #imageLiteral(resourceName: "icon_24_win1")
    let p2Image = #imageLiteral(resourceName: "icon_24_win2")
    
    enum StatIndices : Int {
        case OverallIdx = 0
        case PopularIdx = 1
        case MostWins = 2
        case WinRatio = 3
        case LoseRatio = 4
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
            entries[StatIndices.OverallIdx.rawValue] = StatisticGroup( name: "Overall Wins", p1Desc: "\(p1Wins)", p2Desc: "\(p2Wins)")
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
    
    func minTuple( _ optionalFirst: (String,Int)?, _ second: (String,Int) ) -> (String,Int) {
        if let first = optionalFirst {
            if first.1 < second.1 {
                return first
            } else {
                return second
            }
        } else {
            return second
        }
    }
    
    func updateCharacters(snapshot: DataSnapshot) {
        var popularP1 : (String,Int)?
        var popularP2 : (String,Int)?
        var winsP1: (String,Int)?
        var winsP2: (String,Int)?
        var ratioP1: (String,Int)?
        var ratioP2: (String,Int)?
        var badRatioP1: (String,Int)?
        var badRatioP2: (String,Int)?
        let minRatioBattles = 10
        
        if let characterMap = snapshot.value as? [String:Any] {
            for kv in characterMap {
                if let map = kv.value as? [String:Any],
                    let character = CharacterPref.initFromMap(fromMap: map, withId: kv.key) {
                    
                    if let p1Stat = character.p1Statistics {
                        popularP1 = maxTuple( popularP1, (character.name, p1Stat.qtyBattles))
                        debugPrint("p1Wins \(character.name) \(p1Stat.qtyWins)")
                        winsP1 = maxTuple( winsP1, (character.name, p1Stat.qtyWins))
                        
                        if p1Stat.qtyBattles > minRatioBattles {
                            let winPercent = (100*p1Stat.qtyWins)/p1Stat.qtyBattles
                            ratioP1 = maxTuple(ratioP1, (character.name, winPercent))
                            badRatioP1 = minTuple(badRatioP1, (character.name, winPercent))
                        }
                    }
                    
                    if let p2Stat = character.p2Statistics {
                        popularP2 = maxTuple( popularP2, (character.name, p2Stat.qtyBattles))
                        debugPrint("p2Wins \(character.name) \(p2Stat.qtyWins)")
                        winsP2 = maxTuple( winsP2, (character.name, p2Stat.qtyWins))
                        
                        if p2Stat.qtyBattles > minRatioBattles {
                            let winPercent = (100*p2Stat.qtyWins)/p2Stat.qtyBattles
                            ratioP2 = maxTuple(ratioP2, (character.name, winPercent))
                            badRatioP2 = minTuple(badRatioP2, (character.name, winPercent))
                        }
                    }
                }
            }
        }
        
        if let popP1 = popularP1,
            let popP2 = popularP2 {
            let p1Favourite = "\(popP1.0) (\(popP1.1))"
            let p2Favourite = "\(popP2.0) (\(popP2.1))"
            let grp = StatisticGroup( name: "Favourite Character", p1Desc: p1Favourite, p2Desc: p2Favourite )
            entries[StatIndices.PopularIdx.rawValue] = grp
            tableView.reloadData()
        }
        
        if let win1 = winsP1,
            let win2 = winsP2 {
            let p1Winner = "\(win1.0) (\(win1.1))"
            let p2Winner = "\(win2.0) (\(win2.1))"
            let grp = StatisticGroup( name: "Most Wins", p1Desc: p1Winner, p2Desc: p2Winner )
            entries[StatIndices.MostWins.rawValue] = grp
            tableView.reloadData()
        }
        
        if let ratio1 = ratioP1,
            let ratio2 = ratioP2 {
            let p1Ratio = "\(ratio1.0) (\(ratio1.1)%)"
            let p2Ratio = "\(ratio2.0) (\(ratio2.1)%)"
            let grp = StatisticGroup( name: "Best Win Ratio", p1Desc: p1Ratio, p2Desc: p2Ratio)
            entries[StatIndices.WinRatio.rawValue] = grp
            tableView.reloadData()
        }
        
        if let badRatio1 = badRatioP1,
            let badRatio2 = badRatioP2 {
            let p1Ratio = "\(badRatio1.0) (\(badRatio1.1)%)"
            let p2Ratio = "\(badRatio2.0) (\(badRatio2.1)%)"
            let grp = StatisticGroup( name: "Worst Win Ratio", p1Desc: p1Ratio, p2Desc: p2Ratio)
            entries[StatIndices.LoseRatio.rawValue] = grp
            tableView.reloadData()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        for _ in 0...5 {
                entries.append(nil)
        }
        
        let database = Database.database()
        let overallRef = overallStatisticsRef(database: database)
        overallRef?.observe(.value, with: { (snapshot) in
            self.updateOverall(snapshot: snapshot)
        })
        
        let charactersRef = userCharactersDir( database : database )
        charactersRef?.observe(.value, with: { (snapshot) in
            self.updateCharacters(snapshot: snapshot)
        })
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
