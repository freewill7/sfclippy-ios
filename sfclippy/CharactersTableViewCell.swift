//
//  CharactersTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 19/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class CharactersTableViewCell: UITableViewCell, RatingObserver {
    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var viewRating: RatingView!
    var imageEdit: UIImageView?
    var character : CharacterPref?
    var isP1Rating : Bool?
    static let DAY = 24 * 60 * 60 as TimeInterval
    static let HOUR = 60 * 60 as TimeInterval
    
    func generateDescription( _ optStat: UsageStatistic? ) -> String {
        if let stat = optStat,
            let lastBattle = stat.lastBattle {
            
            let now = Date()
            let diff = now.timeIntervalSince(lastBattle)
            var timeDescription = ""
            if ( diff < CharactersTableViewCell.DAY ) {
                timeDescription = "today"
            } else {
                let days = Int(diff / CharactersTableViewCell.DAY)
                if ( 1 == days ) {
                    timeDescription = "yesterday"
                } else {
                    timeDescription = "\(days) days ago"
                }
            }
            
            return "used \(timeDescription), wins \(stat.qtyWins) / \(stat.qtyBattles)"
        } else {
            return "never used"
        }
    }
    
    func setCharacter( character : CharacterPref, isP1 : Bool ) {
        self.character = character
        self.isP1Rating = isP1
        labelName.text = character.name
        if isP1 {
            viewRating.rating = character.p1Rating
            labelDescription.text = generateDescription(character.p1Statistics)
        } else {
            viewRating.rating = character.p2Rating
            labelDescription.text = generateDescription(character.p2Statistics)
        }
    }
    
    func changeRating( _ sender : RatingView, nextVal: Int) {
        debugPrint("change rating to ",nextVal)
        let database = Database.database()
        if let char = character,
            let p1 = isP1Rating,
            let id = char.id {
            
            if p1 {
                char.p1Rating = nextVal
            } else {
                char.p2Rating = nextVal
            }
            
            let ref = userCharactersPref(database: database, characterId: id)
            ref?.setValue( char.toMap() )
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        viewRating.observer = self
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
