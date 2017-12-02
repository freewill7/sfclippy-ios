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

class ViewController: UIViewController {
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
    @IBOutlet var gesturePanWin: UIPanGestureRecognizer!
    @IBOutlet weak var labelHint: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.database = Database.database()
        updateHint()
    }

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
        } else {
            debugPrint("record battle called with empty values")
        }
    }
    @IBAction func actionPan(_ sender: Any) {
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space
        let piece = gesturePanWin.view!
        let translation = gesturePanWin.translation(in: piece.superview)
        if gesturePanWin.state == .began {
            // Save the view's original position.
            self.initialCenter = piece.center
            
            // Instantiate feedback generator
            self.feedbackGenerator = UINotificationFeedbackGenerator()
            feedbackGenerator?.prepare()
        }
        // Update the position for the .began, .changed, and .ended states
        if gesturePanWin.state == .changed {
            // Add just the Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            if newCenter.y < 0 {
                // feedback that selection has been made
                debugPrint("top")
                
                if #available(iOS 10,*) {
                    feedbackGenerator?.notificationOccurred(UINotificationFeedbackType.success)
                    feedbackGenerator?.prepare()
                }
                
                // reset movement
                gesturePanWin.isEnabled = false
                gesturePanWin.isEnabled = true
                piece.center = initialCenter
                recordBattle(p1Won: true)
            } else if newCenter.y > piece.superview!.bounds.maxY {
                // feedback that selection has been made
                debugPrint("bottom")
                
                if #available(iOS 10,*) {
                    feedbackGenerator?.notificationOccurred(UINotificationFeedbackType.success)
                    feedbackGenerator?.prepare()
                }
                
                // reset movement
                gesturePanWin.isEnabled = false
                gesturePanWin.isEnabled = true
                piece.center = initialCenter
                recordBattle(p1Won: false)
            } else {
                piece.center = newCenter
            }
        } else if gesturePanWin.state == .ended || gesturePanWin.state == .cancelled {
            // On cancellation, return the piece to its original location.
            debugPrint("cancelled with velocity", gesturePanWin.velocity(in: piece.superview))
            piece.center = initialCenter
            feedbackGenerator = nil
        }
    }
    
    func updateHint( ) {
        if nil == p1Name {
            labelHint.text = "It looks like you're recording a battle!\n\nPlease select a character for Player 1";
        } else if ( nil == p2Name ) {
            labelHint.text = "Great!\n\nNow select a character for Player 2";
        } else if ( !hadBattle ) {
            labelHint.text = "Excellent!\n\nNow drag me to the winner of the battle";
        } else {
            labelHint.text = "Congratulations!\n\nDid you know interesting fact goes here";
        }
    }
    
    @IBAction func unwindToBattle(unwindSegue: UIStoryboardSegue) {
        debugPrint("unwound")
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

