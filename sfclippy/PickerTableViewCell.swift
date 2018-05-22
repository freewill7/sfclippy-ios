//
//  PickerTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 19/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class PickerTableViewCell: UITableViewCell {
    @IBOutlet weak var picker: UIPickerView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
