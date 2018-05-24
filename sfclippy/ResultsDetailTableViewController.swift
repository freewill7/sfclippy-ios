//
//  ResultsDetailTableViewController.swift
//  sfclippy
//
//  Created by William Lee on 19/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ResultsDetailTableViewController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    let sectionChar1 = 0
    let sectionChar2 = 1
    let sectionDate = 2
    let sectionWinner = 3
    var dateExpanded = false
    var winnerExpanded = false
    var p1Expanded = false
    var p2Expanded = false
    
    var cellPlayer1 : ButtonTableViewCell?
    var cellPlayer1Picker : PickerTableViewCell?
    var cellPlayer2 : ButtonTableViewCell?
    var cellPlayer2Picker : PickerTableViewCell?
    var cellDateButton : ButtonTableViewCell?
    var cellDatePicker : DatePickerTableViewCell?
    var cellWinner : ButtonTableViewCell?
    var cellWinnerPicker : PickerTableViewCell?
    
    var observerPreferences : UInt?
    var refPreferences : DatabaseReference?
    
    var characters = [CharacterPref]()
    var referenceResult : BattleResult?
    var updatingResult : BattleResult?  {
        didSet {
            toolbarSaveButton.isEnabled = !(referenceResult == updatingResult)
        }
    }
    
    @IBOutlet weak var toolbarSaveButton: UIBarButtonItem!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // copy the user provided result
        updatingResult = referenceResult
        
        let database = Database.database()
        self.refPreferences = userCharactersDir(database: database)
        
        cellPlayer1 = tableView.dequeueReusableCell(withIdentifier: "cellButton") as? ButtonTableViewCell
        cellPlayer1!.button.addTarget(self, action: #selector(p1ButtonClicked(_:)), for: .touchUpInside)
        cellPlayer1Picker = tableView.dequeueReusableCell(withIdentifier: "cellPicker") as? PickerTableViewCell
        cellPlayer1Picker!.picker.dataSource = self
        cellPlayer1Picker!.picker.delegate = self

        cellPlayer2 = tableView.dequeueReusableCell(withIdentifier: "cellButton") as? ButtonTableViewCell
        cellPlayer2!.button.addTarget(self, action: #selector(p2ButtonClicked(_:)), for: .touchUpInside)
        cellPlayer2Picker = tableView.dequeueReusableCell(withIdentifier: "cellPicker") as? PickerTableViewCell
        cellPlayer2Picker!.picker.dataSource = self
        cellPlayer2Picker!.picker.delegate = self
        
        cellDateButton = tableView.dequeueReusableCell(withIdentifier: "cellButton") as? ButtonTableViewCell
        cellDateButton!.button.addTarget(self, action: #selector(dateButtonClicked(_:)), for: .touchUpInside)
        cellDatePicker = tableView.dequeueReusableCell(withIdentifier: "cellDatePicker") as? DatePickerTableViewCell
        cellDatePicker?.datePicker.addTarget(self, action: #selector(dateValueChanged(_:)), for: .valueChanged)
        
        cellWinner = tableView.dequeueReusableCell(withIdentifier: "cellButton") as? ButtonTableViewCell
        cellWinner!.button.addTarget(self, action: #selector(winnerButtonClicked(_:)), for: .touchUpInside)

        cellWinnerPicker = tableView.dequeueReusableCell(withIdentifier: "cellPicker") as? PickerTableViewCell
        cellWinnerPicker!.picker.dataSource = self
        cellWinnerPicker!.picker.delegate = self
        
        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem
    }

    func handlePreferencesChange( snapshot: DataSnapshot ) {
        var prefs = [CharacterPref]()
        for kv in snapshot.children {
            if let snap = kv as? DataSnapshot,
                let value = snap.value as? [String:Any],
                let pref = CharacterPref.initFromMap(fromMap: value, withId: snap.key) {
                prefs.append(pref)
            }
        }
        
        self.characters = prefs.sorted(by: { (prefa, prefb) -> Bool in
            return prefa.name < prefb.name
        })

        tableView.reloadData()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ref = refPreferences {
            observerPreferences = ref.observe(.value, with: handlePreferencesChange)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        if let ref = refPreferences,
            let obs = observerPreferences {
            ref.removeObserver(withHandle: obs)
        }
        
        super.viewDidDisappear(animated)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 4
    }
    
    override func tableView(_ tableView: UITableView, willDisplayHeaderView view: UIView, forSection section: Int){
        view.tintColor = UIColor(named: "color_primary_1")
        let header = view as! UITableViewHeaderFooterView
        header.textLabel?.textColor = UIColor.white
    }
    
    
    override func tableView(_ tableView : UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case sectionChar1:
            return "Player 1"
        case sectionChar2:
            return "Player 2"
        case sectionDate:
            return "Date"
        case sectionWinner:
            return "Winner"
        default:
            return nil
        }
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        if sectionChar1 == section {
            return p1Expanded ? 2 : 1
        } else if sectionChar2 == section {
            return p2Expanded ? 2 : 1
        } else if sectionDate == section {
            return dateExpanded ? 2 : 1
        } else if sectionWinner == section {
            return winnerExpanded ? 2 : 1
        } else {
            return 1
        }
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        switch ( indexPath.section ) {
        case sectionChar1:
            if ( 0 == indexPath.row ) {
                cellPlayer1!.button.setTitle(updatingResult?.p1Name, for: .normal)
                return cellPlayer1!
            } else {
                let desiredRow = characters.index { (pref) -> Bool in
                    return pref.name == updatingResult?.p1Name
                }
                if let row = desiredRow {
                    cellPlayer1Picker!.picker.selectRow(row, inComponent: 0, animated: false)
                }
                return cellPlayer1Picker!
            }
        case sectionChar2:
            if ( 0 == indexPath.row ) {
                cellPlayer2!.button.setTitle(updatingResult?.p2Name, for: .normal)
                return cellPlayer2!
            } else {
                let desiredRow = characters.index { (pref) -> Bool in
                    return pref.name == updatingResult?.p2Name
                }
                if let row = desiredRow {
                    cellPlayer2Picker!.picker.selectRow(row, inComponent: 0, animated: false)
                }
                return cellPlayer2Picker!
            }
        case sectionDate:
            if ( 0 == indexPath.row ) {
                let date = getUserFormatter().string(from: updatingResult!.date)
                cellDateButton!.button.setTitle(date, for: .normal)
                return cellDateButton!
            } else {
                cellDatePicker!.datePicker.date = updatingResult!.date
                return cellDatePicker!
            }
        case sectionWinner:
            if ( 0 == indexPath.row ) {
                let title = updatingResult!.p1Won ? "Player 1" : "Player 2"
                cellWinner!.button.setTitle(title, for: .normal)
                return cellWinner!
            } else {
                let desiredRow = updatingResult!.p1Won ? 0 : 1
                cellWinnerPicker!.picker.selectRow(desiredRow, inComponent: 0, animated: false)
                return cellWinnerPicker!
            }
        default:
            // shouldn't happen
            return cellPlayer1!
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
    
    @IBAction func saveButtonClicked(_ sender: Any) {
        let database = Database.database()
        let ref = userResultsRecordRef( database : database, id: referenceResult!.id! )
        ref?.setValue( updatingResult?.toMap() )
        referenceResult = updatingResult
        
        // regenerate statistics
        // TODO make this more efficient- only update statistics for previous and newly selected characters
        refPreferences?.observeSingleEvent(of: .value, with: { (snapshot) in
            regenerateStatistics(database: database, snapshot: snapshot )
        }, withCancel: nil)
        
        // return to parent
        self.performSegue(withIdentifier: "segueUnwindToResults", sender: self)

    }
    
    @IBAction func dateButtonClicked(_ sender: Any) {
        dateExpanded = !dateExpanded
        tableView.reloadData()
    }
    
    @IBAction func winnerButtonClicked(_ sender: Any) {
        winnerExpanded = !winnerExpanded
        tableView.reloadData()
    }
    
    @IBAction func p1ButtonClicked(_ sender : Any) {
        p1Expanded = !p1Expanded
        tableView.reloadData()
    }
    
    @IBAction func p2ButtonClicked(_ sender : Any) {
        p2Expanded = !p2Expanded
        tableView.reloadData()
    }
    
    @IBAction func dateValueChanged(_ sender : Any) {
        let nextDate = cellDatePicker!.datePicker.date
        updatingResult = updatingResult?.updateDate( nextDate )
        tableView.reloadData()
    }
    
    // MARK: - UIPickerViewDataSource
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch pickerView {
        case cellWinnerPicker!.picker:
            return 2
        case cellPlayer1Picker!.picker, cellPlayer2Picker!.picker:
            return characters.count
        default:
            return 0
        }
    }
    
    // MARK: - UIPickerViewDelegate
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        switch pickerView {
        case cellWinnerPicker!.picker:
            return (0 == row) ? "Player 1" : "Player 2"
        case cellPlayer1Picker!.picker, cellPlayer2Picker!.picker:
            return characters[row].name
        default:
            return nil
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        switch pickerView {
        case cellWinnerPicker!.picker:
            updatingResult = updatingResult?.updateWinner( p1Win: (0 == row) )
            tableView.reloadData()
        case cellPlayer1Picker!.picker:
            let pref = characters[row]
            updatingResult = updatingResult?.updateP1Char( pref )
            tableView.reloadData()
        case cellPlayer2Picker!.picker:
            let pref = characters[row]
            updatingResult = updatingResult?.updateP2Char( pref )
            tableView.reloadData()
        default:
            debugPrint("unknown picker")
        }
    }
    
}
