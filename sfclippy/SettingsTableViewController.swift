//
//  SettingsTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 19/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

enum Options
{
    case RegenerateStatistics
};

class SettingsTableViewController: UITableViewController {
    
    let database = Database.database()
    let options = [ (Options.RegenerateStatistics, "Regenerate Statistics") ]
    var regeneratingStats = false

    override func viewDidLoad() {
        super.viewDidLoad()

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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        debugPrint("count is \(options.count)")
        return options.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "settingsCell", for: indexPath)
        if let settings = cell as? SettingsTableViewCell {
            settings.labelSetting.text = options[indexPath.row].1
            if regeneratingStats {
                debugPrint("disabling setting")
                settings.labelSetting.textColor = UIColor.gray
            } else {
                debugPrint("enabling setting")
                settings.labelSetting.textColor = UIColor(named: "color_primary_1")
            }
        }

        return cell
    }

    func updateStatisticsMap( map: inout [String:UsageStatistic], key: String, won: Bool, date: Date ) {
        let statistic = map[key, default: UsageStatistic()]
        statistic.addResult(won: won, date:date)
        map[key] = statistic
    }
    
    func updateStatisticsMapMap( map: inout [String:[String:UsageStatistic]], key1: String, key2: String, won: Bool, date: Date) {
        var statsMap = map[key1, default: [String:UsageStatistic]()]
        updateStatisticsMap(map: &statsMap, key: key2, won: won, date: date)
        map[key1] = statsMap
    }
    
    func regenerateStatistics(snapshot : DataSnapshot) {
        debugPrint("regenerate stats called")
        
        let overall = UsageStatistic()
        var p1CharOverall = [String:UsageStatistic]()
        var p2CharOverall = [String:UsageStatistic]()
        var p1CharMap = [String:[String:UsageStatistic]]()
        var p2CharMap = [String:[String:UsageStatistic]]()
        
        // generate statistics
        if let results = snapshot.value as? [String:[String:Any]] {
            for pair in results {
                if let result = BattleResult.initFromMap(fromMap: pair.value) {
                    let date = result.date
                    let p1Id = result.p1Id
                    let p2Id = result.p2Id
                    let p1Won = result.p1Won
                    
                    overall.addResult(won: p1Won, date: date)
                    
                    updateStatisticsMap(map: &p1CharOverall, key: p1Id, won: p1Won, date: date)
                    updateStatisticsMap(map: &p2CharOverall, key: p2Id, won: !p1Won, date: date)
                    
                    updateStatisticsMapMap(map: &p1CharMap, key1: p1Id, key2: p2Id, won: p1Won, date: date)
                    updateStatisticsMapMap(map: &p2CharMap, key1: p2Id, key2: p1Id, won: !p1Won, date: date)
                }
            }
        }
        
        // store statistics
        if let refOverall = overallStatisticsRef(database: database) {
            refOverall.setValue(overall.toMap())
        }
        
        for kv in p1CharOverall {
            if let ref = p1CharacterStatisticsRef(database: database, characterId: kv.key) {
                ref.setValue(kv.value.toMap())
            }
        }
        
        for kv in p2CharOverall {
            if let ref = p2CharacterStatisticsRef(database: database, characterId: kv.key) {
                ref.setValue(kv.value.toMap())
            }
        }
        
        for kkv in p1CharMap {
            for kv in kkv.value {
                if let ref = p1VsStatisticsRef(database: database, p1Id: kkv.key, p2Id: kv.key) {
                    ref.setValue(kv.value.toMap())
                }
            }
        }
        
        for kkv in p2CharMap {
            for kv in kkv.value {
                if let ref = p2VsStatisticsRef(database: database, p2Id: kkv.key, p1Id: kv.key) {
                    ref.setValue(kv.value.toMap())
                }
            }
        }
        
        debugPrint("results = \(overall.qtyWins) / \(overall.qtyBattles)")
        regeneratingStats = false
        tableView.reloadData()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        debugPrint("selected row at \(indexPath.row)")
        
        let setting = options[indexPath.row]
        switch ( setting.0 ) {
        case .RegenerateStatistics:
            //
            if !regeneratingStats {
                debugPrint("regenerate stats requested")
                regeneratingStats = true
                tableView.reloadData()

                let resultsRef = userResultsRef(database: database)
                resultsRef?.queryOrdered(byChild: BattleResult.keyDate).observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    self.regenerateStatistics(snapshot: snapshot)
                    })
            }
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
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
