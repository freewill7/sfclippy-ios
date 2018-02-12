//
//  RatingView.swift
//  sfclippy
//
//  Created by William Lee on 17/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit

@objc protocol RatingObserver {
    func changeRating( _ sender: RatingView, nextVal : Int )
}

@IBDesignable
class RatingView: UIStackView {
    @IBOutlet var observer : RatingObserver?
    var emptyStar : UIImage?
    var filledStar : UIImage?
    
    var buttons = [UIButton]()
    var rating : Int = 1 {
        didSet {
            for (index,element) in buttons.enumerated() {
                if index < rating {
                    element.setImage(filledStar, for: .normal)
                } else {
                    element.setImage(emptyStar, for: .normal)
                }
            }
        }
    }
    
    var editable = true
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @objc
    func ratingButtonTapped(button: UIButton) {
        debugPrint("rating button pressed")
        if editable {
            if let index = buttons.index(of: button) {
                debugPrint("selected button \(index)")
                rating = index+1
                
                if let obs = observer {
                    obs.changeRating( self, nextVal: rating)
                }
            }
        }
    }
    
    private func buttonsInit( ) {
        self.distribution = UIStackViewDistribution.fillEqually
        self.alignment = UIStackViewAlignment.fill
        
        let myBundle = Bundle(for: type(of: self))
        emptyStar = UIImage( named: "star_border_24", in: myBundle, compatibleWith: self.traitCollection)
        filledStar = UIImage( named: "star_24", in: myBundle, compatibleWith: self.traitCollection)
        
        // Create the button
        for _ in 0...4 {
            let button = UIButton()
            
            button.setImage(emptyStar, for: UIControlState.normal)
            button.addTarget(self, action: #selector(RatingView.ratingButtonTapped(button:)), for: .touchUpInside)
        
            // Add constraints
            button.translatesAutoresizingMaskIntoConstraints = false
            //button.imageView?.contentMode = UIViewContentMode.scaleAspectFill
            //button.contentEdgeInsets = UIEdgeInsets( top:4, left:4, bottom:4, right:4 );
            // button.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            //    equalToConstant: self.bounds.height).isActive = true
            //button.widthAnchor.constraint(equalTo: self.widthAnchor, multiplier: 0.2).isActive = true
        
            // Add the button to the stack
            addArrangedSubview(button)
            buttons.append(button)
        }
        
        /*
        for _ in 0...4 {
            let button = UIButton()
            button.translatesAutoresizingMaskIntoConstraints = false
            //button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            //button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.setImage(#imageLiteral(resourceName: "star_border_24"), for: UIControlState.normal)
            self.addArrangedSubview(button)
            buttons.append(button)
        }
 */

    }

    override init( frame : CGRect ) {
        super.init(frame: frame)
        buttonsInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        buttonsInit()
    }

}
