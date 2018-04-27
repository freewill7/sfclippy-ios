//
//  CharactersTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 19/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ArcRandomGenerator : RandomGenerator {
    func randomInteger(_ max: Int) -> Int {
        return Int(arc4random_uniform(UInt32(max)))
    }
}

class CharactersTableViewController: UITableViewController {
    var characters = [CharacterPref]()
    var filteredCharacters = [CharacterPref]()
    var playerId = 0
    var selectedName = ""
    var selectedId = ""
    var selector = SelectionMechanism( ArcRandomGenerator() )
    var editMode = false
    var observerPreferences : UInt?
    var refPreferences : DatabaseReference?
    let searchController = UISearchController(searchResultsController: nil)
    @IBOutlet weak var buttonEditCancel: UIBarButtonItem!
    
    @IBAction func clickEditCancel(_ sender: Any) {
        editMode = !editMode
        if editMode {
            buttonEditCancel.title = "Cancel"
            navigationController?.setToolbarHidden(false, animated: true)
        } else {
            buttonEditCancel.title = "Edit"
            navigationController?.setToolbarHidden(true, animated: true)
        }
        tableView.reloadData()
    }
    
    func comparePrefs( a : CharacterPref, b : CharacterPref, extractScore: (CharacterPref) -> Int ) -> Bool {
        var diff = extractScore(a) - extractScore(b)
        if ( 0 == diff ) {
            diff = b.name.compare(a.name).rawValue
        }
        return diff > 0
    }
    
    func populateCharacter( characterDir : DatabaseReference, characterName : String, p1Rating : Int, p2Rating : Int ) {
        
        let charPref = CharacterPref(name: characterName, p1Rating: p1Rating, p2Rating: p2Rating)
        characterDir.childByAutoId().setValue( charPref.toMap() )
    }
    
    func updateCharacter( characterDir : DatabaseReference, characterId: String, characterName : String, p1Rating : Int, p2Rating : Int ) {
        let ref = characterDir.child(characterId)
        ref.child(CharacterPref.keyName).setValue(characterName)
        ref.child(CharacterPref.keyP1Rating).setValue(p1Rating)
        ref.child(CharacterPref.keyP2Rating).setValue(p2Rating)
        
        // update cache
        for character in characters {
            if character.id == characterId {
                character.name = characterName
                character.p1Rating = p1Rating
                character.p2Rating = p2Rating
            }
        }
        tableView.reloadData()
    }
    
    func populateWithSample( characterDir: DatabaseReference ) {
        let originalCharacters = [ "Ryu", "Ken", "Chun-Li", "Zangief",
                                   "R.Mika", "Nash", "F.A.N.G.", "M.Bison",
                                   "Cammy", "Rashid", "Birdie", "Dhalsim",
                                   "Necalli", "Laura", "Karin", "Vega"]
        let season1 = [ "Guile", "Alex", "Balrog", "Ibuki", "Juri", "Urien"]
        let season2 = [ "Akuma", "Kolin", "Ed", "Birdie", "Menat", "Zeku"]
        
        originalCharacters.forEach( { (character : String) in populateCharacter(characterDir: characterDir, characterName: character, p1Rating: 1, p2Rating: 1) })
        season1.forEach( { (character : String) in populateCharacter(characterDir: characterDir, characterName: character, p1Rating: 1, p2Rating: 1) } )
        season2.forEach( { (character : String) in populateCharacter(characterDir: characterDir, characterName: character, p1Rating: 1, p2Rating: 1) } )
    }
    
    func welcomeUser( characterDir : DatabaseReference ) {
        debugPrint("welcoming user")
        let message = "You haven't set up any characters yet." +
        "\n\nCharacters can be added individually through \"Edit\" or taken from a sample list"
        let alert = UIAlertController( title: "Welcome", message: message, preferredStyle: .alert)
        alert.addAction( UIAlertAction(title: NSLocalizedString("Use sample", comment: "Use sample"),
                                       style: .default,
                                       handler: { (_ : UIAlertAction) in
            debugPrint("populating with sample")
            self.populateWithSample(characterDir: characterDir)
        }))
        alert.addAction( UIAlertAction(title: NSLocalizedString("Skip", comment: "Populate myself"),
                                       style: .default,
                                       handler: { (_ : UIAlertAction) in
            debugPrint("skipping sample")
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    func handlePreferencesChange( snapshot: DataSnapshot ) {
        if ( snapshot.hasChildren() ) {
            debugPrint("already bootstrapped")
 
            var prefs = [CharacterPref]()
            for kv in snapshot.children {
                if let snap = kv as? DataSnapshot,
                    let value = snap.value as? [String:Any],
                    let pref = CharacterPref.initFromMap(fromMap: value, withId: snap.key) {
                    prefs.append(pref)
                }
            }
            
            var extractScore = { (pref : CharacterPref) -> Int in return pref.p1Rating }
            if self.playerId == 1 {
                extractScore = { (pref : CharacterPref) -> Int in return pref.p2Rating }
            }
            
            self.characters = prefs.sorted(by: { (prefa, prefb) -> Bool in
                return self.comparePrefs(a: prefa, b: prefb, extractScore: extractScore)
            })
            tableView.reloadData()
        } else {
            debugPrint("bootstrap required...")
            self.welcomeUser(characterDir: snapshot.ref);
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let database = Database.database()
        self.refPreferences = userCharactersDir(database: database)
        
        self.title = "Player \(playerId+1)"
        
        // Setup the search controller
        searchController.searchResultsUpdater = self
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = "Search characters"
        searchController.hidesNavigationBarDuringPresentation = false
        self.tableView.tableHeaderView = searchController.searchBar
        definesPresentationContext = true
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        navigationController?.setToolbarHidden(!editMode, animated: false)
        
        if let ref = refPreferences {
            observerPreferences = ref.observe(.value, with: handlePreferencesChange)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let ref = refPreferences,
            let obs = observerPreferences {
            ref.removeObserver(withHandle: obs)
        }
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
        return isFiltering() ? filteredCharacters.count : characters.count
    }

    func characterForIndex(_ path : IndexPath) -> CharacterPref {
        return isFiltering() ? filteredCharacters[path.row] : characters[path.row]
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let isP1 = (0==playerId)
        
        /*if editMode {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editCharacterCell", for: indexPath) as! EditCharactersTableViewCell
            cell.setCharacter( character: characters[indexPath.row], isP1: isP1 )
            return cell
        } */
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as! CharactersTableViewCell
        let character = characterForIndex(indexPath)
        cell.setCharacter( character: character, isP1: isP1, isEdit: editMode )
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        debugPrint("selected row at \(indexPath.row)")
        
        let character = characterForIndex(indexPath)
        if editMode {
            performSegue(withIdentifier: "editCharacter", sender: self)
        } else {
            if let id = character.id {
                self.selectedName = character.name
                self.selectedId = id
                
                if isFiltering() {
                    self.searchController.dismiss(animated: true, completion: {
                        self.performSegue(withIdentifier: "segueUnwindToBattle", sender: self)
                    })
                } else {
                    self.performSegue(withIdentifier: "segueUnwindToBattle", sender: self)
                }
            }
        }
    }
    
    @IBAction func selectRandom(_ sender: Any) {
        let elem = selector.randomCharacter(characters)
        if let index = characters.index(of: elem) {
            let path = IndexPath(row: index, section: 0)
            self.tableView.selectRow(at: path, animated: true, scrollPosition: .top)
        }
    }
    
    @IBAction func selectPreferred(_ sender: Any) {
        let elem = selector.preferredCharacter(characters, playerId: playerId)
        if let index = characters.index(of: elem) {
            let path = IndexPath(row: index, section: 0)
            self.tableView.selectRow(at: path, animated: true, scrollPosition: .top)
        }
    }

    @IBAction func unwindToCharacters(unwindSegue: UIStoryboardSegue) {
        debugPrint("unwound to characters")
        
        if let addChar = unwindSegue.source as? AddCharacterViewController {
            let database = Database.database()
            let optionalRef = userCharactersDir(database: database)
            
            if let ref = optionalRef {
                let name = addChar.characterName
                let p1Rating = addChar.p1Rating
                let p2Rating = addChar.p2Rating
                
                if let id = addChar.characterId {
                    debugPrint("updating \(id) \(name) \(p1Rating) \(p2Rating)")
                    updateCharacter( characterDir: ref, characterId: id, characterName: name, p1Rating: p1Rating, p2Rating: p2Rating)
                } else {
                    debugPrint("adding \(name) \(p1Rating) \(p2Rating)")
                    populateCharacter( characterDir : ref, characterName : name, p1Rating : p1Rating, p2Rating : p2Rating )
                }
            }
        }


    }
    
    func searchBarIsEmpty() -> Bool {
        // Returns true if the text is empty of nil
        return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterContentForSearchText(_ searchText: String, scope: String = "All" ) {
        filteredCharacters = characters.filter({ (prefa) -> Bool in
            return prefa.name.lowercased().contains(searchText.lowercased())
        })
        tableView.reloadData()
    }
    
    func isFiltering() -> Bool {
        return searchController.isActive && !searchBarIsEmpty()
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
        navigationController?.setToolbarHidden(true, animated: false)
        // Get the new view controller using segue.destinationViewController.
        if let dest = segue.destination as? AddCharacterViewController {
            if let indexPath = tableView.indexPathForSelectedRow {
                let character = characterForIndex(indexPath)
                dest.characterId = character.id
                dest.characterName = character.name
                dest.p1Rating = character.p1Rating
                dest.p2Rating = character.p2Rating
            }
        }
        // Pass the selected object to the new view controller.
    }

}

extension CharactersTableViewController : UISearchResultsUpdating {
    func updateSearchResults(for searchController: UISearchController) {
        filterContentForSearchText(searchController.searchBar.text!)
    }
}
