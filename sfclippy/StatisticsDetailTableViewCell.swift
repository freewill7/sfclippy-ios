//
//  StatisticsDetailTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 29/04/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class StatisticsDetailTableViewCell: UITableViewCell {
    @IBOutlet weak var labelCharacter: UILabel!
    @IBOutlet weak var labelStatistic: UILabel!
    @IBOutlet weak var imageTrend: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
