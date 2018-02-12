//
//  ViewController.swift
//  sfclippy
//
//  Created by William Lee on 16/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase
import AudioToolbox
import Toast_Swift

class ViewController: UIViewController, DragToSelectObserver {
    var database : Database?
    var p1Name : String?
    var optP1Id : String?
    var p2Name : String?
    var optP2Id : String?
    var initialCenter = CGPoint()
    var feedbackGenerator : UINotificationFeedbackGenerator? = nil
    var hadBattle = false
    
    @IBOutlet weak var btnChooseP1: UIButton!
    @IBOutlet weak var btnChooseP2: UIButton!
    
    @IBOutlet weak var selectionView: DragToSelectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        database = Database.database()
        selectionView.enabled = false
        selectionView.observer = self
        
        updateHint()
    }
    
    /*override func viewWillAppear(_ animated: Bool) {
        // show tab bar
        self.tabBarController?.tabBar.isHidden = false
    }*/

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if ( segue.identifier == "selectP1Character" ) {
            if let dest = segue.destination as? CharactersTableViewController {
                dest.playerId = 0
            }
        } else if ( segue.identifier == "selectP2Character" ) {
            if let dest = segue.destination as? CharactersTableViewController {
                dest.playerId = 1
            }
        }
    }
    
    func recordBattle( p1Won: Bool ) {
        if let db = database,
            let dir = userResultsRef(database: db),
            let p1Id = optP1Id,
            let p2Id = optP2Id {
            debugPrint("non null values")
            
            let result = BattleResult(date: Date(), p1Id: p1Id, p2Id: p2Id, p1Won: p1Won)

            let ref = dir.childByAutoId()
            ref.setValue(result.toMap())
            
            // feed back
            hadBattle = true
            updateHint()
            self.view.makeToast("Result recorded")
        } else {
            debugPrint("record battle called with empty values")
        }
    }
    
    /**
    Implementation for DragSelectObserver.
     */
    func selectedFirstOption() {
        debugPrint("selected top item")
        recordBattle(p1Won: true)
    }
    
    /**
    Implementation for DragSelectObserver.
     */
    func selectedSecondOption() {
        debugPrint("selected bottom item")
        recordBattle(p1Won: false)
    }
    
    func updateHint( ) {
        if p1Name == nil {
            btnChooseP1.setImage(#imageLiteral(resourceName: "sfclippy_48"), for: UIControlState.normal)
            btnChooseP1.setTitle("Choose a character for Player 1", for: UIControlState.normal)
        } else {
            btnChooseP1.setTitle(p1Name, for: UIControlState.normal)
            btnChooseP1.setImage(#imageLiteral(resourceName: "icon_48_p1"), for: UIControlState.normal)
        }
        
        if p2Name == nil {
            btnChooseP2.setImage(#imageLiteral(resourceName: "sfclippy_48"), for: UIControlState.normal)
            btnChooseP2.setTitle("Choose a character for Player 2", for: UIControlState.normal)
            //selectionView.message = "Zzz... (waiting for Player 1 selection)"
        } else {
            btnChooseP2.setTitle(p2Name, for: UIControlState.normal)
            btnChooseP2.setImage(#imageLiteral(resourceName: "icon_48_p2"), for: UIControlState.normal)
        }
        
        if nil != p1Name && nil != p2Name {
            selectionView.isHidden = false
            selectionView.enabled = true
            if ( hadBattle ) {
                selectionView.message = "Result recorded"
            } else {
                selectionView.message = "Drag me to the winner"
            }
        } else {
            selectionView.isHidden = true
            selectionView.enabled = false
        }
    }
    
    @IBAction func unwindToBattle(unwindSegue: UIStoryboardSegue) {
        debugPrint("unwound")
        
        // update settings
        if let tblController = unwindSegue.source as? CharactersTableViewController {
            if ( 0 == tblController.playerId ) {
                p1Name = tblController.selectedName
                optP1Id = tblController.selectedId
                btnChooseP1.setTitle(p1Name, for: UIControlState.normal)
            } else if ( 1 == tblController.playerId ) {
                p2Name = tblController.selectedName
                optP2Id = tblController.selectedId
                btnChooseP2.setTitle(p2Name, for: UIControlState.normal)
            }
            hadBattle = false
            updateHint()
        }
    }
}

