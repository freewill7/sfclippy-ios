//
//  SfHeadingView.swift
//  sfclippy
//
//  Created by William Lee on 18/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

@IBDesignable
class SfHeadingView: UIView {
    @IBOutlet weak var labelMain: UILabel!
    @IBOutlet var contentView: UIView!
    
    /**
     The message to display in the draggable view.
     */
    @IBInspectable var message : String? {
        didSet {
            self.labelMain.text = message
        }
    }
    
    @IBInspectable var fontColor : UIColor? {
        didSet {
            self.labelMain.textColor = fontColor
        }
    }
    
    private func commonInit( ) {
        let bundle = Bundle(for: SfHeadingView.self)
        bundle.loadNibNamed("SfHeadingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        contentView.backgroundColor = self.backgroundColor
    }
    
    override init( frame : CGRect ) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

}
