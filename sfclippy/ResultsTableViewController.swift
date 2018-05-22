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
    
    var refResults : DatabaseReference?
    var observerResults : UInt?
    let searchController = UISearchController(searchResultsController: nil)
    
    var allResults = [BattleResult]()
    var allGroupedResults = [(key: String, value:[BattleResult])]()
    var filteredResults = [BattleResult]()
    var filteredGroupedResults = [(key: String, value:[BattleResult])]()
    
    @IBOutlet weak var barEditButton: UIBarButtonItem!
    
    static let matchAll = "All"
    static let matchP1 = "Player 1"
    static let matchP2 = "Player 2"
    
    func groupResults( _ results : [BattleResult] ) -> [(key: String, value: [BattleResult])] {
        var grouped = [String:[BattleResult]]()
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        for result in results {
            let key = dateFormatter.string(from: result.date)
            
            // add to group
            var group = grouped[key, default: [BattleResult]() ]
            group.append(result)
            
            // sort group descending
            group = group.sorted(by: { (resulta, resultb) -> Bool in
                return resulta.date > resultb.date
            })
            
            grouped[key] = group
        }
        
        var ret = [(key: String, value: [BattleResult])]()
        ret = grouped.sorted { (kv1, kv2) -> Bool in
            return kv1.key > kv2.key
        }
        
        return ret
    }
    
    func observeResults( snapshot : DataSnapshot ) {
        var all = [BattleResult]()
        for kv in snapshot.children {
            if let snap = kv as? DataSnapshot,
                let value = snap.value as? [String:Any],
                let result = BattleResult.initFromMap(fromMap: value, withId: snap.key) {
                    all.append(result)
            }
        }
    
        self.allResults = all
        self.allGroupedResults = groupResults(all)
    
        tableView.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.database = Database.database()
        self.refResults = userResultsDirRef(database: database!)
 
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.delegate = self
        searchController.searchBar.placeholder = "Search result"
        searchController.searchBar.scopeButtonTitles = [ResultsTableViewController.matchAll,
                                                        ResultsTableViewController.matchP1,
                                                        ResultsTableViewController.matchP2]
        searchController.searchBar.tintColor = UIColor(named: "color_white")

        navigationItem.searchController = searchController
        definesPresentationContext = true

        /*
        searchController.hidesNavigationBarDuringPresentation = false


        
        navigationItem.searchController = searchController

        definesPresentationContext = true
 */
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ref = refResults {
            observerResults = ref.observe(.value, with: observeResults)
            tableView.reloadData()
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let ref = refResults,
            let obs = observerResults {
            ref.removeObserver(withHandle: obs)
        }
        
        allResults.removeAll(keepingCapacity: false)
        allGroupedResults.removeAll(keepingCapacity: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return isFiltering() ? filteredGroupedResults.count : allGroupedResults.count
    }

    func getGroup( _ section : Int ) -> (key:String,value:[BattleResult]) {
        if isFiltering() {
            return filteredGroupedResults[section]
        } else {
            return allGroupedResults[section]
        }
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return getGroup(section).value.count
    }

    func nameOrDefault( optPref: CharacterPref?, def : String ) -> String {
        if let pref = optPref {
            return pref.name
        } else {
            return def
        }
    }
    
    func resultForIndex( _ indexPath: IndexPath ) -> BattleResult {
        return getGroup(indexPath.section).value[indexPath.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "resultCell", for: indexPath) as! ResultsTableViewCell
        let result = resultForIndex( indexPath )
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd"
        
        cell.labelCharacters.text = "\(result.p1Name) vs \(result.p2Name)"
        if result.p1Won {
            cell.imageWinner.image = #imageLiteral(resourceName: "icon_24_win1")
            cell.imageWinner.tintColor = UIColor(named: "color_primary")
        } else {
            cell.imageWinner.image = #imageLiteral(resourceName: "icon_24_win2")
            cell.imageWinner.tintColor = UIColor(named: "color_accent")
        }
        
        return cell
    }
    
    override func tableView(_ tableView : UITableView, titleForHeaderInSection section: Int) -> String? {
        return getGroup(section).key
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(named: "color_primary_1")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        if ( tableView.isEditing ) {
            debugPrint("editing item...")
            performSegue(withIdentifier: "showResult", sender: self)
        } else {
            debugPrint("selected... but not editing")
        }
    }
    
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return tableView.isEditing
    }

    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            // identify value to delete
            let section = indexPath.section
            let val = getGroup(section).value[indexPath.row]
            
            // delete from firebase
            if let db = database,
                let resultId = val.id,
                let ref = userResultsRecordRef(database: db, id: resultId ) {
                ref.removeValue()
            }
            
            // remove row
            if ( isFiltering() ) {
                filteredGroupedResults[section].value.remove(at: indexPath.row)
            } else {
                allGroupedResults[section].value.remove(at: indexPath.row)
            }
            
            // delete animation
            tableView.deleteRows(at: [indexPath], with: .fade)

            // regenerate statistics in background
            if let db = database,
                let ref = userResultsDirRef(database: db) {
                
                ref.observeSingleEvent(of: .value, with: { (snapshot) in
                    regenerateStatistics(database: db, snapshot: snapshot, p1CharId: val.p1Id, p2CharId: val.p2Id)
                })
            }

            // TODO  remove section... causes crash atm >:-(
            /* if resultsArr[section].value.count == 0 {
                resultsArr.remove(at: section)
                let section = IndexSet(integer: section)
                tableView.deleteSections(section, with: .fade)
            } */
            
        }
    }

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
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty of nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = matchAll ) {
        filteredResults = allResults.filter({ (result) -> Bool in
            let searchTerm = simplifyName(searchText)
            var match = false
            if scope == ResultsTableViewController.matchP1 || scope == ResultsTableViewController.matchAll {
                match = match || simplifyName(result.p1Name).contains(searchTerm)
            }
            if scope == ResultsTableViewController.matchP2 || scope == ResultsTableViewController.matchAll {
                match = match || simplifyName(result.p2Name).contains(searchTerm)
            }
            return match
        })
        filteredGroupedResults = groupResults(filteredResults)
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        if let dest = segue.destination as? ResultsDetailTableViewController,
            let indexPath = tableView.indexPathForSelectedRow {
            dest.referenceResult = resultForIndex(indexPath)
        }
    }

    @IBAction func clickBarButtonEdit(_ sender: Any) {
        tableView.setEditing(!tableView.isEditing, animated: true)
        if tableView.isEditing {
            barEditButton.title = "Cancel"
        } else {
            barEditButton.title = "Edit"
        }
    }
    
    @IBAction func unwindToResults(unwindSegue: UIStoryboardSegue) {
        debugPrint("unwound to results")
        
        // nothing to do  
    }
}

extension ResultsTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}

extension ResultsTableViewController : UISearchBarDelegate {
    // MARK: - UISearchBar Delegate
    func searchBar(_ searchBar: UISearchBar, selectedScopeButtonIndexDidChange selectedScope: Int) {
        filterContentForSearchText(searchBar.text!, scope: searchBar.scopeButtonTitles![selectedScope])
    }
}
