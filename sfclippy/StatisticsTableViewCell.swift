//
//  StatisticsTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 24/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class StatisticsTableViewCell: UITableViewCell {
    @IBOutlet weak var labelTitle: UILabel!
    @IBOutlet weak var imagePlayer: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
