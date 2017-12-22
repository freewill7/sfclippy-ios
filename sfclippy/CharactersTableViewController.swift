//
//  CharactersTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 19/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CharactersTableViewController: UITableViewController {
    var characters = [CharacterPref]()
    var playerId = 0
    var selectedName = ""
    var selectedId = ""
    
    func characterAdded( snapshot : DataSnapshot ) {
        if let map = snapshot.value as? [String:String],
            let charPref = CharacterPref.initFromMap(fromMap: map, withId: snapshot.key) {
            debugPrint("retrieved character",charPref,snapshot.key)
            characters.append( charPref )
            tableView.reloadData();
        }
    }
    
    func populateCharacter( characterDir : DatabaseReference, characterName : String ) {
        
        let charPref = CharacterPref(name: characterName, p1Rating: 1, p2Rating: 1)
        characterDir.childByAutoId().setValue( charPref.toMap() )
    }
    
    func populateWithSample( characterDir: DatabaseReference ) {
        let originalCharacters = [ "Ryu", "Ken", "Chun-Li", "Zangief",
                                   "R.Mika", "Nash", "F.A.N.G.", "M.Bison",
                                   "Cammy", "Rashid", "Birdie", "Dhalsim",
                                   "Necalli", "Laura", "Karin", "Vega"]
        let season1 = [ "Guile", "Alex", "Balrog", "Ibuki", "Juri", "Urien"]
        let season2 = [ "Akuma", "Kolin", "Ed", "Birdie", "Menat", "Zeku"]
        
        originalCharacters.forEach( { (character : String) in populateCharacter(characterDir: characterDir, characterName: character) })
        season1.forEach( { (character : String) in populateCharacter(characterDir: characterDir, characterName: character) } )
        season2.forEach( { (character : String) in populateCharacter(characterDir: characterDir, characterName: character) } )
    }
    
    func welcomeUser( characterDir : DatabaseReference ) {
        debugPrint("welcoming user")
        let message = "You haven't set up any characters yet." +
        "\n\nCharacters can be added individually with (+) or taken from a sample list"
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
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
        
        let database = Database.database()
        let ref = userCharactersDir(database: database)
        
        self.title = "Choose Character (p\(playerId))"
        
        // set up handler to allow for bootstrap
        debugPrint("checking to see if we need to bootstrap")
        ref?.observeSingleEvent(of: DataEventType.value, with: { (snapshot : DataSnapshot) in
            if ( snapshot.hasChildren() ) {
                debugPrint("already bootstrapped")
            } else {
                debugPrint("bootstrap required...")
                self.welcomeUser(characterDir: ref!);
            }
        })
        
        ref?.observe(DataEventType.childAdded, with: { (sn : DataSnapshot) -> Void in
            self.characterAdded(snapshot: sn)
            })
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
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
        return characters.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "characterCell", for: indexPath) as! CharactersTableViewCell
        
        // configure cell
        cell.setCharacter( character: characters[indexPath.row], isP1: (playerId == 0) )
        
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath ) {
        debugPrint("selected row at \(indexPath.row)")
        let character = characters[indexPath.row]
        if let id = character.id {
            self.selectedName = character.name
            self.selectedId = id
            performSegue(withIdentifier: "segueUnwindToBattle", sender: self)
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

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
