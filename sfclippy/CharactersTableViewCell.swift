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
    @IBOutlet weak var viewRating: RatingView!
    var imageEdit: UIImageView?
    var character : CharacterPref?
    var isP1Rating : Bool?
    
    func setCharacter( character : CharacterPref, isP1 : Bool ) {
        self.character = character
        self.isP1Rating = isP1
        labelName.text = character.name
        if isP1 {
            viewRating.rating = character.p1Rating
        } else {
            viewRating.rating = character.p2Rating
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
