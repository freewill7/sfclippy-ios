//
//  TextTableViewCell.swift
//  sfclippy
//
//  Created by William Lee on 23/05/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class TextTableViewCell: UITableViewCell {
    @IBOutlet weak var textField: UITextField!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
