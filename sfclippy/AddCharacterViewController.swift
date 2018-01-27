//
//  AddCharacterViewController.swift
//  sfclippy
//
//  Created by William Lee on 27/01/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class AddCharacterViewController: UIViewController, RatingObserver {
    @IBOutlet weak var textCharacter: UITextField!
    @IBOutlet weak var ratingViewP1: RatingView!
    @IBOutlet weak var ratingViewP2: RatingView!
    @IBOutlet weak var btnSave: UIBarButtonItem!
    var characterName : String = ""
    var p1Rating : Int = 1
    var p2Rating : Int = 1
    
    @IBAction func textEntryEdited(_ sender: Any) {
        if let txt = textCharacter.text {
            btnSave.isEnabled = !txt.isEmpty
            characterName = txt
        }
    }
    
    func changeRating( _ sender: RatingView, nextVal : Int ) {
        if sender == ratingViewP1 {
            p1Rating = nextVal
        } else if sender == ratingViewP2 {
            p2Rating = nextVal
        }
    }

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        ratingViewP1.rating = p1Rating
        ratingViewP1.observer = self
        ratingViewP2.rating = p2Rating
        ratingViewP2.observer = self
        btnSave.isEnabled = false
        textCharacter.becomeFirstResponder()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
