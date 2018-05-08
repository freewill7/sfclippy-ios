//
//  StatisticsDetailTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 29/04/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class StatisticsDetailTableViewController: UITableViewController {
    var optIsP1 : Bool?
    var compare : StatisticsCompare?
    var stats = [CharacterPref]()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        debugPrint("loaded detail table view controller")
        if let comp = compare {
            stats = stats.sorted(by: { (prefa, prefb) -> Bool in
                return comp.isGreater(prefa, prefb)
            })
            
            navigationItem.title = comp.getDescription()
            
            debugPrint("row count originally \(stats.count)")
            tableView.reloadData()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return stats.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "statisticsDetailCell", for: indexPath)
        if let detail = cell as? StatisticsDetailTableViewCell,
            let comp = compare {
            let pref = stats[indexPath.row]
            detail.labelCharacter.text = pref.name
            detail.labelStatistic.text = comp.getFormattedValue(pref: pref)
            
            if let isP1 = optIsP1 {
                let trend = identifyCharacterTrend(pref: pref, isP1: isP1, today: Date(timeIntervalSinceNow: 0))
                if trend == StatisticsTrend.TrendingUp {
                    detail.imageTrend.image = #imageLiteral(resourceName: "icon_24_trending_up")
                    detail.imageTrend.tintColor = UIColor(named: "color_primary")
                } else if trend == StatisticsTrend.TrendingDown {
                    detail.imageTrend.image = #imageLiteral(resourceName: "icon_24_trending_down")
                    detail.imageTrend.tintColor = UIColor(named: "color_accent")
                } else {
                    detail.imageTrend.image = #imageLiteral(resourceName: "icon_24_trending_flat")
                    detail.imageTrend.tintColor = UIColor.black
                }
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
