//
//  SettingsTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 19/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

enum SettingsOperation {
    case RegenerateStatistics
    case DeleteEverything
};

enum SettingsOperationType {
    case Harmless
    case Destructive
}

class SettingsTableViewController: UITableViewController {
    
    let database = Database.database()
    let options = [ (SettingsOperation.RegenerateStatistics, "Regenerate Statistics", SettingsOperationType.Harmless),
                    (SettingsOperation.DeleteEverything, "Delete Everything", SettingsOperationType.Destructive) ]
    var regeneratingStats = false
    var operation : SettingsOperation?

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
            // update label
            settings.labelSetting.text = options[indexPath.row].1
            
            // update color
            if .Destructive == options[indexPath.row].2 {
                settings.labelSetting.textColor = UIColor.red
            } else {
                settings.labelSetting.textColor = UIColor(named: "color_primary_1")
            }
        } else {
            debugPrint("mystery cell")
        }

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        debugPrint("selected row at \(indexPath.row)")
        
        let setting = options[indexPath.row]
        self.operation = setting.0
        switch ( setting.0 ) {
        case .RegenerateStatistics:
            //
            if !regeneratingStats {
                debugPrint("regenerate stats requested")
                regeneratingStats = true
                tableView.reloadData()

                let resultsRef = userResultsDirRef(database: database)
                resultsRef?.queryOrdered(byChild: BattleResult.keyDate).observeSingleEvent(of: .value, with: {
                    (snapshot) in
                    regenerateStatistics(database: self.database, snapshot: snapshot)
                    self.regeneratingStats = false
                    self.tableView.reloadData()
                    })
            }
        case .DeleteEverything:
            //
            debugPrint("deleteEverything clicked")
            performSegue(withIdentifier: "confirmAction", sender: self)
            //deleteEverything()
        }
        
        tableView.deselectRow(at: indexPath, animated: false)
    }
    
    @IBAction func unwindToSettings(unwindSegue: UIStoryboardSegue) {
        debugPrint("unwound to characters")
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
        if let dst = segue.destination as? ConfirmViewController {
            dst.operation = operation
        }
        // Pass the selected object to the new view controller.
    }


}
