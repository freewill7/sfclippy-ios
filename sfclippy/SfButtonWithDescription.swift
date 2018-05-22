//
//  SfButtonWithDescription.swift
//  sfclippy
//
//  Created by William Lee on 02/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

/**
 Protocol for observing events in a DragToSelectView.
 */
@objc protocol ButtonClickObserver {
    /**
     A button was clicked.
     */
    func buttonClicked( sender : Any );
}

@IBDesignable
class SfButtonWithDescription: UIView {
    @IBOutlet var contentView: UIView!
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var labelMain: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    var id = 0
    @IBOutlet var clickObserver: ButtonClickObserver?
    
    /**
     The message to display in the draggable view.
     */
    @IBInspectable var message : String? {
        didSet {
            self.labelMain.text = message
        }
    }
    
    /**
     The description to display in the draggable view.
     */
    @IBInspectable var subMessage: String? {
        didSet {
            self.labelDescription.text = subMessage
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            if let col = backgroundColor,
                let content = self.contentView {
                content.backgroundColor = col
            }
        }
    }
    
    /**
     The description to display in the draggable view.
     */
    @IBInspectable var image: UIImage? {
        didSet {
            self.imageView.image = image
        }
    }
    
    @IBAction func selectAction(_ sender: Any) {
        if let obs = clickObserver {
            debugPrint("calling observer")
            obs.buttonClicked(sender: self)
        }
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */

    private func commonInit( ) {
        debugPrint("SfButtonWithDescription\(id) common init")
        let bundle = Bundle(for: SfButtonWithDescription.self)
        bundle.loadNibNamed("SfButtonWithDescription", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        contentView.backgroundColor = self.backgroundColor
        self.imageView.tintColor = self.tintColor
        self.labelMain.textColor = self.tintColor
        self.labelDescription.textColor = self.tintColor
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
