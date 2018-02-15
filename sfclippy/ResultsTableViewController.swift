//
//  ResultsTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 01/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ResultsTableViewController: UITableViewController {
    var database : Database?
    var results = [String:[BattleResult]]()
    // array representation to allow sorting
    var resultsArr = [(key: String,value: [BattleResult])]()
    var characterLookup = [String:CharacterPref]()
    
    func addToResults( _ res : BattleResult ) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        let key = dateFormatter.string(from: res.date)
        
        // append to results for that date (and sort descending)
        var val = results[ key, default: [BattleResult]() ]
        val.append(res)
        val = val.sorted(by: { (resulta, resultb) -> Bool in
            return resulta.date > resultb.date
        })
        
        // update map and sort cached version
        results[key] = val
        resultsArr = results.sorted { (kv1, kv2) -> Bool in
            return kv1.key > kv2.key
        }
    }
    
    func observeAddResult( snapshot : DataSnapshot ) {
        if let map = snapshot.value as? [String:Any],
            let result = BattleResult.initFromMap(fromMap: map) {
            addToResults(result)
            tableView.reloadData()
        } else {
            debugPrint("failed to decode result",snapshot.value!)
        }
    }
    
    func observeAddCharacter( snapshot : DataSnapshot ) {
        if let map = snapshot.value as? [String:Any],
            let character = CharacterPref.initFromMap(fromMap: map, withId: snapshot.key) {
            characterLookup[snapshot.key] = character
            tableView.reloadData()
        } else {
            debugPrint("failed to decode character",snapshot.value!)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.database = Database.database()
        if let db = database {
            let resultsRef = userResultsRef(database: db)
            resultsRef?.queryOrdered(byChild: BattleResult.keyDate).observe(DataEventType.childAdded, with: { (snapshot : DataSnapshot) in
                self.observeAddResult(snapshot: snapshot)
            })
            
            let prefsRef = userCharactersDir(database: db)
            prefsRef?.observe(DataEventType.childAdded, with: { (snapshot : DataSnapshot) in
                self.observeAddCharacter(snapshot: snapshot)
            })
        }
 
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        //return 1
        return results.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultsArr[section].value.count
    }

    func nameOrDefault( optPref: CharacterPref?, def : String ) -> String {
        if let pref = optPref {
            return pref.name
        } else {
            return def
        }
    }
    
    func resultForIndex( _ indexPath: IndexPath ) -> BattleResult {
        return resultsArr[indexPath.section].value[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultsTableViewCell
        let result = resultForIndex( indexPath )
        
        let p1Lookup = characterLookup[result.p1Id]
        let p2Lookup = characterLookup[result.p2Id]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        let p1Name = nameOrDefault( optPref:p1Lookup, def:"unknown")
        let p2Name = nameOrDefault( optPref:p2Lookup, def:"unknown")
        cell.labelCharacters.text = "\(p1Name) vs \(p2Name)"
        if result.p1Won {
            cell.imageWinner.image = #imageLiteral(resourceName: "icon_24_win1")
        } else {
            cell.imageWinner.image = #imageLiteral(resourceName: "icon_24_win2")
        }
        
        return cell
    }
    
    override func tableView(_ tableView : UITableView, titleForHeaderInSection section: Int) -> String? {
        return resultsArr[section].key
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        performSegue(withIdentifier: "showResult", sender: self)
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
        if let dest = segue.destination as? ResultViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            dest.characterMap = characterLookup
            dest.result = resultForIndex(indexPath)
        }
    }

}
