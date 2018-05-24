//
//  CharactersDetailTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 23/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CharactersDetailTableViewController: UITableViewController, RatingObserver {
    
    let sectionName = 0
    let sectionP1Rating = 1
    let sectionP2Rating = 2
    
    @IBOutlet weak var buttonSave: UIBarButtonItem!
    
    var referenceCharacter : CharacterPref?
    var modifiedCharacter : CharacterPref? {
        didSet {
            let nonEmptyCharacter = ("" != modifiedCharacter?.name)
            if nil == referenceCharacter {
                buttonSave.isEnabled = nonEmptyCharacter
            } else {
                buttonSave.isEnabled = (referenceCharacter != modifiedCharacter) && nonEmptyCharacter
            }
        }
    }
    
    var nameCell : TextTableViewCell?
    var p1RatingCell : RatingTableViewCell?
    var p2RatingCell : RatingTableViewCell?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        if let ref = referenceCharacter {
            navigationController?.title = "Add Character"
            modifiedCharacter = ref
        } else {
            navigationController?.title = "Edit Character"
            modifiedCharacter = CharacterPref(name: "", p1Rating: 1, p2Rating: 1)
        }
        
        nameCell = tableView.dequeueReusableCell(withIdentifier: "cellTextField") as? TextTableViewCell
        nameCell?.textField.text = modifiedCharacter?.name
        nameCell?.textField.addTarget(self, action: #selector(textFieldChanged), for: UIControlEvents.editingChanged)
        
        p1RatingCell = tableView.dequeueReusableCell(withIdentifier: "cellRating") as? RatingTableViewCell
        p1RatingCell!.ratingView.editable = true
        p1RatingCell!.ratingView.rating = modifiedCharacter!.p1Rating
        p1RatingCell!.ratingView.observer = self
        p1RatingCell!.tintColor = UIColor(named: "color_primary_1")
        
        p2RatingCell = tableView.dequeueReusableCell(withIdentifier: "cellRating") as? RatingTableViewCell
        p2RatingCell!.ratingView.editable = true
        p2RatingCell!.ratingView.rating = modifiedCharacter!.p2Rating
        p2RatingCell!.ratingView.observer = self
        p2RatingCell!.tintColor = UIColor(named: "color_primary_1")

        // if we're a creating a new character take the user straight to text entry
        if ( nil == referenceCharacter ) {
            nameCell?.textField.becomeFirstResponder()

        }
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
        return 3
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(named: "color_primary_1")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    override func tableView(_ tableView : UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case sectionName:
            return "Name"
        case sectionP1Rating:
            return "P1 Rating"
        case sectionP2Rating:
            return "P2 Rating"
        default:
            return nil
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch(indexPath.section){
        case sectionName:
            return nameCell!
        case sectionP1Rating:
            return p1RatingCell!
        case sectionP2Rating:
            return p2RatingCell!
        default:
            return nameCell!
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
    
    @IBAction func textFieldChanged(_ sender : Any) {
        modifiedCharacter = modifiedCharacter?.changeName(nameCell!.textField.text!)
    }
    
    @IBAction func saveChanges(_ sender : Any) {
        let toSave = modifiedCharacter?.toMap()
        let db = Database.database()
        if let id = modifiedCharacter?.id {
            // update existing character in database
            if let ref = userCharactersPref( database : db, characterId : id ) {
                ref.setValue(toSave)
            }
            
            if referenceCharacter?.name != modifiedCharacter?.name {
                // rename results based on new character name
                if let ref = userResultsDirRef(database: db) {
                    ref.observe(.value) { (snapshot) in
                        renameResults(database: db, snapshot: snapshot, pref: self.modifiedCharacter!)
                    }
                }
            
            }
        } else {
            // create new character
            let dir = userCharactersDir(database: db)
            let ref = dir?.childByAutoId()
            ref?.setValue(toSave)
        }
        
        self.performSegue(withIdentifier: "segueUnwindToCharacters", sender: self)
    }
    
    // MARK: RatingObserver
    func changeRating(_ sender: RatingView, nextVal: Int) {
        switch sender {
        case p1RatingCell!.ratingView:
            modifiedCharacter = modifiedCharacter?.changeP1Rating(nextVal)
        case p1RatingCell!.ratingView:
            modifiedCharacter = modifiedCharacter?.changeP2Rating(nextVal)
        default:
            debugPrint("unrecognised ratingview")
        }
    }
}
