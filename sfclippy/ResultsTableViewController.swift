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
    var results = [BattleResult]()
    var characterLookup = [String:CharacterPref]()
    
    func observeAddResult( snapshot : DataSnapshot ) {
        if let map = snapshot.value as? [String:String],
            let result = BattleResult.initFromMap(fromMap: map) {
            results.append(result)
            tableView.reloadData()
        } else {
            debugPrint("failed to decode result",snapshot.value!)
        }
    }
    
    func observeAddCharacter( snapshot : DataSnapshot ) {
        if let map = snapshot.value as? [String:String],
            let character = CharacterPref.initFromMap(fromMap: map) {
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
            resultsRef?.observe(DataEventType.childAdded, with: { (snapshot : DataSnapshot) in
                self.observeAddResult(snapshot: snapshot)
            })
            
            let prefsRef = userCharactersRef(database: db)
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
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return results.count
    }

    func nameOrDefault( optPref: CharacterPref?, def : String ) -> String {
        if let pref = optPref {
            return pref.name
        } else {
            return def
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultsTableViewCell
        let result = results[indexPath.row]
        
        let p1Lookup = characterLookup[result.p1Id]
        let p2Lookup = characterLookup[result.p2Id]
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM dd"
        
        cell.labelDate.text =
            dateFormatter.string(from: result.date)
        cell.labelPlayer1.text = nameOrDefault( optPref:p1Lookup, def:"unknown")
        cell.labelPlayer2.text = nameOrDefault( optPref:p2Lookup, def:"unknown")
        if result.p1Won {
            cell.imageWinner.image = #imageLiteral(resourceName: "icon_36_p1")
        } else {
            cell.imageWinner.image = #imageLiteral(resourceName: "icon_36_p2")
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
