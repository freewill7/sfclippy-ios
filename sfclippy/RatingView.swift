//
//  RatingView.swift
//  sfclippy
//
//  Created by William Lee on 17/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit

@objc protocol RatingObserver {
    func changeRating( nextVal : Int )
}

@IBDesignable
class RatingView: UIStackView {
    @IBOutlet var contentView: UIView!
    @IBOutlet var observer : RatingObserver?
    
    var buttons = [UIButton]()
    var rating : Int = 1 {
        didSet {
            for (index,element) in buttons.enumerated() {
                if index < rating {
                    element.setImage(#imageLiteral(resourceName: "star_24"), for: .normal)
                } else {
                    element.setImage(#imageLiteral(resourceName: "star_border_24"), for: .normal)
                }
            }
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
        let bundle = Bundle(for: RatingView.self)
        bundle.loadNibNamed("RatingView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
    }
    
    @objc
    func ratingButtonTapped(button: UIButton) {
        debugPrint("rating button pressed")
        if let index = buttons.index(of: button) {
            debugPrint("selected button \(index)")
            rating = index+1
            
            if let obs = observer {
                obs.changeRating(nextVal: rating)
            }
        }
    }
    
    private func buttonsInit( ) {
        
        for _ in 0...4 {
            let button = UIButton()
            button.setImage(#imageLiteral(resourceName: "star_border_24"), for: UIControlState.normal)
            button.addTarget(self, action: #selector(RatingView.ratingButtonTapped(button:)), for: .touchUpInside)
            addArrangedSubview(button)
            buttons.append(button)
        }
        /* button.setImage(#imageLiteral(resourceName: "star_border_24"), for: UIControlState.normal)
         */
        /*
        for _ in 0...5 {
            let button = UIButton()
            button.setTitle("hullo", for: UIControlState.normal)
            button.translatesAutoresizingMaskIntoConstraints = false
            button.heightAnchor.constraint(equalToConstant: 44.0).isActive = true
            button.widthAnchor.constraint(equalToConstant: 44.0).isActive = true
            addArrangedSubview(button)
        }
 */
    }
    
    override init( frame : CGRect ) {
        super.init(frame: frame)
        commonInit()
        buttonsInit()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
        buttonsInit()
    }

}
