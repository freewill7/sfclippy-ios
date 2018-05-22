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

class ViewController: UIViewController, DragToSelectObserver, ButtonClickObserver {
    var database : Database?
    var p1Stat : String?
    var optP1Id : String?
    var optP1Name :String?
    var p2Stat : String?
    var optP2Id : String?
    var optP2Name : String?
    var initialCenter = CGPoint()
    var feedbackGenerator : UINotificationFeedbackGenerator? = nil
    var hadBattle = false
    var versusStat : String?
    var refPreferences : DatabaseReference?
    var observerPreferences : UInt?
    var preferences = [CharacterPref]()
    var selector = SelectionMechanism( ArcRandomGenerator() )
    
    @IBOutlet weak var btnHistorical: UIBarButtonItem!
    @IBOutlet weak var btnChooseP1: SfButtonWithDescription!
    @IBOutlet weak var btnChooseP2: SfButtonWithDescription!
    
    @IBOutlet weak var selectionView: DragToSelectView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        database = Database.database()

        refPreferences = userCharactersDir(database: database!)

        selectionView.enabled = false
        selectionView.isHidden = true
        selectionView.observer = self
        btnChooseP1.id = 101
        btnChooseP1.clickObserver = self
        btnChooseP2.id = 102
        btnChooseP2.clickObserver = self
        debugPrint("set click observer \(self)")
        
        refreshControls()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if let ref = refPreferences {
            observerPreferences = ref.observe(.value, with: handleCharactersChange)
        }
        
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if let ref = refPreferences,
            let obs = observerPreferences {
            ref.removeObserver(withHandle: obs)
        }
    }
    
    func refreshControls() {
        refreshButton(p1: true)
        refreshButton(p1: false)
        refreshSliderMessage()
        updateHint()
        
        if preferences.count > 0 {
            btnHistorical.isEnabled = true
        } else {
            btnHistorical.isEnabled = false
        }
    }
    
    func handleCharactersChange( _ snapshot : DataSnapshot ) {
        // if we have no characters then clear
        // current battle settings
        if snapshot.hasChildren() {
            debugPrint("handling characters change \(snapshot.childrenCount)")
            var prefs = [CharacterPref]()
            for kv in snapshot.children {
                if let snap = kv as? DataSnapshot,
                    let value = snap.value as? [String:Any],
                    let pref = CharacterPref.initFromMap(fromMap: value, withId: snap.key) {
                    prefs.append(pref)
                }
            }
            
            if let p1Id = optP1Id {
                let p1Chars = prefs.filter({ (pref) -> Bool in return (p1Id == pref.id) })
                if p1Chars.count > 0 {
                    selectCharacter1(pref: p1Chars[0])
                }
            }
            
            if let p2Id = optP2Id {
                let p2Chars = prefs.filter({ (pref) -> Bool in return (p2Id == pref.id) })
                if p2Chars.count > 0 {
                    selectCharacter2(pref: p2Chars[0])
                }
            }

            self.preferences = prefs
        } else {
            optP1Name = nil
            p1Stat = nil
            optP2Name = nil
            p2Stat = nil
            optP1Id = nil
            optP2Id = nil
            hadBattle = false
            versusStat = nil
        }
        
        refreshControls()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        // hide toolbar
        navigationController?.setToolbarHidden(true, animated: false)
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
    
    func updateStatWithBattle( snapshot: DataSnapshot, date: Date, won: Bool ) -> UsageStatistic {
        var stat = UsageStatistic()
        if let map = snapshot.value as? [String:Any],
            let prev = UsageStatistic.initFromMap(fromMap: map) {
            debugPrint("updating statistic \(snapshot.key)")
            stat = prev
        } else {
            debugPrint("initialising statistic from empty \(snapshot.key)")
        }
        stat = stat.addResult(won: won, date: date)
        snapshot.ref.setValue(stat.toMap())
        return stat
    }
    
    func updateStats( db: Database, date: Date, p1Id: String, p2Id: String, p1Won: Bool ) {
        let overallStat = overallStatisticsRef(database: db)
        overallStat?.observeSingleEvent(of: .value, with: { (snapshot) in
            _ = self.updateStatWithBattle( snapshot: snapshot, date: date, won: p1Won )
        })
        
        let p1CharStat = p1CharacterStatisticsRef(database: db, characterId: p1Id)
        p1CharStat?.observeSingleEvent(of: .value, with: { (snapshot) in
            _ = self.updateStatWithBattle(snapshot: snapshot, date: date, won: p1Won)
        })
        
        let p2CharStat = p2CharacterStatisticsRef(database: db, characterId: p2Id)
        p2CharStat?.observeSingleEvent(of: .value, with: { (snapshot) in
            _ = self.updateStatWithBattle(snapshot: snapshot, date: date, won: !p1Won)
        })
        
        let p1CharMap = p1VsStatisticsRef(database: db, p1Id: p1Id, p2Id: p2Id)
        p1CharMap?.observeSingleEvent(of: .value, with: { (snapshot) in
            let stat = self.updateStatWithBattle(snapshot: snapshot, date: date, won: p1Won)
            self.versusStat = self.generateVersusStat(statistic: stat)
            self.updateHint()
        })
        
        let p2CharMap = p2VsStatisticsRef(database: db, p2Id: p2Id, p1Id: p1Id)
        p2CharMap?.observeSingleEvent(of: .value, with: { (snapshot) in
            _ = self.updateStatWithBattle(snapshot: snapshot, date: date, won: !p1Won)
        })
    }
    
    func recordBattle( p1Won: Bool ) {
        if let db = database,
            let dir = userResultsDirRef(database: db),
            let p1Id = optP1Id,
            let p1Name = optP1Name,
            let p2Id = optP2Id,
            let p2Name = optP2Name {
            debugPrint("non null values")
            
            let date = Date()
            let result = BattleResult(date: date, p1Id: p1Id, p1Name: p1Name, p2Id: p2Id, p2Name: p2Name, p1Won: p1Won, id: nil)

            let ref = dir.childByAutoId()
            ref.setValue(result.toMap())

            updateStats( db: db, date: date, p1Id: p1Id, p2Id: p2Id, p1Won: p1Won )
            
            // feed back
            hadBattle = true
        } else {
            debugPrint("record battle called with empty values")
        }
    }
    
    /**
    Implementation for DragSelectObserver.
     */
    func selectedFirstOption() {
        debugPrint("selected top item")
        btnChooseP1.backgroundColor = UIColor.clear
        recordBattle(p1Won: true)
    }
    
    /**
    Implementation for DragSelectObserver.
     */
    func selectedSecondOption() {
        debugPrint("selected bottom item")
        btnChooseP2.backgroundColor = UIColor.clear
        recordBattle(p1Won: false)
    }
    
    /**
    Implementation for DragSelectObserver.
    */
    func movedTowards(option: Int, percent: Int) {
        let accent = UIColor(named: "color_accent")
        let adjusted = accent?.withAlphaComponent( 0.2 * CGFloat(Float(percent) / 100))
        if ( 0 == option ) {
            btnChooseP1.backgroundColor = adjusted
            btnChooseP2.backgroundColor = UIColor.clear
        } else if ( 1 == option ) {
            btnChooseP1.backgroundColor = UIColor.clear
            btnChooseP2.backgroundColor = adjusted
        }
    }
    
    /**
     Implementation for ButtonClickObserver.
    */
    func buttonClicked(sender: Any) {
        if btnChooseP1 == sender as? SfButtonWithDescription  {
            debugPrint("transition to P1 choice")
            performSegue(withIdentifier: "selectP1Character", sender: self)
        } else if btnChooseP2 == sender as? SfButtonWithDescription {
            debugPrint("transition to P2 choice")
            performSegue(withIdentifier: "selectP2Character", sender: self)
        } else {
            debugPrint("button click event from unknown")
        }
    }
    
    func refreshButton( p1: Bool ) {
        let button = p1 ? btnChooseP1 : btnChooseP2
        
        let optName = p1 ? optP1Name : optP2Name
        let optStat = p1 ? p1Stat : p2Stat
        let image = p1 ? #imageLiteral(resourceName: "icon_48_p1") : #imageLiteral(resourceName: "icon_48_p2")
        let optPlayerName = p1 ? "P1" : "P2"
        
        if let name = optName {
            button?.message = name
            button?.subMessage = optStat
            button?.image = image
        } else {
            button?.message = "Choose \(optPlayerName) character"
            button?.subMessage = nil
            button?.image = #imageLiteral(resourceName: "sfclippy_48")
        }
    }
    
    func refreshSliderMessage() {
        if nil != optP1Name && nil != optP2Name {
            selectionView.isHidden = false
            selectionView.enabled = true
            let message = hadBattle ? "Result recorded" : "Drag me to the winner"
            if let stat = versusStat {
                selectionView.message = message
                selectionView.subMessage = stat
            } else {
                selectionView.message = message
                selectionView.subMessage = nil
            }
        } else {
            selectionView.isHidden = true
            selectionView.enabled = false
        }
    }
    
    func generateStat( statistic: UsageStatistic ) -> String {
        let winPercent = (statistic.qtyWins * 100) / statistic.qtyBattles
        return  "wins \(winPercent)% of battles"
    }
    
    func generateStat( snapshot : DataSnapshot ) -> String? {
        if let map = snapshot.value as? [String:Any],
            let stat = UsageStatistic.initFromMap(fromMap: map) {
            return generateStat( statistic: stat )
        }
        return nil
    }
    
    func generateVersusStat( statistic: UsageStatistic ) -> String {
        return "Player 1 wins matchup \(statistic.qtyWins) / \(statistic.qtyBattles) times"
    }
    
    func fetchVersusStat( snapshot : DataSnapshot ) {
        debugPrint("processing versus stat")
        if let map = snapshot.value as? [String:Any],
            let stat = UsageStatistic.initFromMap(fromMap: map) {
            versusStat = generateVersusStat(statistic: stat)
        } else {
            versusStat = nil
        }
        refreshSliderMessage()
    }
    
    func updateHint( ) {
        if let id1 = optP1Id,
            let id2 = optP2Id {
            debugPrint("fetching battle stat")
            p1VsStatisticsRef(database: database!, p1Id: id1, p2Id: id2)?.observeSingleEvent(of: .value, with: { (snapshot) in
                self.fetchVersusStat( snapshot: snapshot )
            })
        }
    }
    
    func fetchP1Stat( snapshot: DataSnapshot ) {
        debugPrint("processing p1Stat")
        p1Stat = generateStat(snapshot: snapshot)
        refreshButton(p1: true)
    }
    
    func fetchP2Stat( snapshot : DataSnapshot ) {
        debugPrint("processing p2Stat")
        p2Stat = generateStat(snapshot: snapshot)
        refreshButton(p1: false)
    }
    
    @IBAction func chooseHistorical(_ sender: Any) {
        
        let p1Choice = selector.leastRecentlyUsed(preferences, playerId: 0)
        let p2Choice = selector.leastRecentlyUsed(preferences, playerId: 1)

        selectCharacter1(pref: p1Choice)
        selectCharacter2(pref: p2Choice)
        
        updateHint()
        
        refreshControls()
    }
    
    func selectCharacter1( pref : CharacterPref ) {
        optP1Name = pref.name
        if let stat = pref.p1Statistics {
            p1Stat = generateStat(statistic: stat)
        } else {
            p1Stat = ""
        }
        optP1Id = pref.id
    }
    
    func selectCharacter2( pref : CharacterPref ) {
        optP2Name = pref.name
        if let stat = pref.p2Statistics {
            p2Stat = generateStat(statistic: stat)
        } else {
            p2Stat = ""
        }
        optP2Id = pref.id
    }
    
    @IBAction func unwindToBattle(unwindSegue: UIStoryboardSegue) {
        debugPrint("unwound")
        
        // update settings
        if let tblController = unwindSegue.source as? CharactersTableViewController {
            if let selected = tblController.selected {
                if ( 0 == tblController.playerId ) {
                    selectCharacter1(pref: selected)
                } else if ( 1 == tblController.playerId ) {
                    selectCharacter2(pref: selected)
                }
                hadBattle = false
                updateHint()
            }
        }
    }
}

