//
//  DragToSelectView.swift
//  sfclippy
//
//  Created by William Lee on 02/12/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit

/**
 Protocol for observing events in a DragToSelectView.
 */
@objc protocol DragToSelectObserver {
    /**
     User selected the first option in the DragToSelectView.
     */
    func selectedFirstOption();
    
    /**
     User selected the second option in the DragToSelectView.
    */
    func selectedSecondOption();
}

/**
 View that allows a user to select an option by dragging a view to the option.
 */
@IBDesignable
class DragToSelectView: UIView {
    var initialCenter = CGPoint()
    //@IBOutlet weak var gesturePanWin: UIPanGestureRecognizer!
    @IBOutlet var contentView : UIView!
    @IBOutlet weak var viewMoveable: UIView!
    @IBOutlet weak var viewCustom: UIView!
    @IBOutlet var gesturePan: UIPanGestureRecognizer!
    @IBOutlet weak var labelMessage: UILabel!
    @IBOutlet weak var labelDescription: UILabel!
    @IBOutlet weak var imageAssistant: UIImageView!
    @IBOutlet var observer : DragToSelectObserver?
    
    var enabled : Bool = true {
        didSet {
            /*let alpha = (CGFloat) (enabled ? 1.0 : 0.1)
            self.moveableView.alpha = alpha WRL */
        }
    }
    
    /**
     The message to display in the draggable view.
    */
    @IBInspectable var message : String? {
        didSet {
            self.labelMessage.text = message
        }
    }
    
    /**
    More information to show in view.
    */
    @IBInspectable var subMessage : String? {
        didSet {
            self.labelDescription.text = subMessage
        }
    }
    
    /**
     The image to display in the draggable view.
     */
    @IBInspectable var image : UIImage? {
        didSet {
            self.imageAssistant.image = image
        }
    }
    
    private func commonInit( ) {
        let bundle = Bundle(for: DragToSelectView.self)
        bundle.loadNibNamed("DragToSelectView", owner: self, options: nil)
        addSubview(contentView)
        contentView.frame = self.bounds
        
        self.labelMessage.text = message
        self.labelMessage.textColor = self.backgroundColor
        self.labelDescription.textColor = self.backgroundColor
        self.imageAssistant.tintColor = self.backgroundColor
        self.viewMoveable.backgroundColor = self.tintColor

    }
    
    override init( frame : CGRect ) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    /*
    // Only override draw() if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func draw(_ rect: CGRect) {
        // Drawing code
    }
    */
    
    @IBAction func actionPan(_ sender: Any) {
        if !enabled {
            return
        }
        
        // Get the changes in the X and Y directions relative to
        // the superview's coordinate space
        let piece = gesturePan.view!
        let translation = gesturePan.translation(in: piece.superview)
        if gesturePan.state == .began {
            // Save the view's original position.
            self.initialCenter = piece.center
            
            // Instantiate feedback generator
            //self.feedbackGenerator = UINotificationFeedbackGenerator()
            //feedbackGenerator?.prepare()
        }
        // Update the position for the .began, .changed, and .ended states
        if gesturePan.state == .changed {
            // Add just the Y translation to the view's original position.
            let newCenter = CGPoint(x: initialCenter.x, y: initialCenter.y + translation.y)
            if newCenter.y < 0 {
                // feedback that selection has been made
                debugPrint("top")
                
                if #available(iOS 10,*) {
                //feedbackGenerator?.notificationOccurred(UINotificationFeedbackType.success)
                    //feedbackGenerator?.prepare()
                }
                
                // reset movement
                gesturePan.isEnabled = false
                gesturePan.isEnabled = true
                piece.center = initialCenter
                
                // record win
                if let obs = observer {
                    obs.selectedFirstOption()
                }
            } else if newCenter.y > piece.superview!.bounds.maxY {
                // feedback that selection has been made
                debugPrint("bottom")
                
                if #available(iOS 10,*) {
                    //feedbackGenerator?.notificationOccurred(UINotificationFeedbackType.success)
                    //feedbackGenerator?.prepare()
                }
                
                // reset movement
                gesturePan.isEnabled = false
                gesturePan.isEnabled = true
                piece.center = initialCenter
                
                // record win
                if let obs = observer {
                    obs.selectedSecondOption()
                }
            } else {
                piece.center = newCenter
            }
        } else if gesturePan.state == .ended || gesturePan.state == .cancelled {
            // On cancellation, return the piece to its original location.
            debugPrint("cancelled with velocity", gesturePan.velocity(in: piece.superview))
            piece.center = initialCenter
            //feedbackGenerator = nil
        }
    }

}
