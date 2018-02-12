//
//  EditCharacterTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 12/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class EditCharactersTableViewCell: UITableViewCell {
    var character : CharacterPref?

    @IBOutlet weak var labelName: UILabel!
    @IBOutlet weak var ratingControl: RatingView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        ratingControl.editable = false
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    func setCharacter( character : CharacterPref, isP1: Bool ) {
        self.character = character
        labelName.text = character.name
        if isP1 {
            ratingControl.rating = character.p1Rating
        } else {
            ratingControl.rating = character.p2Rating
        }
    }

}
