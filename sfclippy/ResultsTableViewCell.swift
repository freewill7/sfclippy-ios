//
//  ResultsTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 02/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit

class ResultsTableViewCell: UITableViewCell {
    @IBOutlet weak var labelCharacters: UILabel!
    @IBOutlet weak var imageWinner: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
