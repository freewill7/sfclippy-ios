//
//  ConfirmViewController.swift
//  sfclippy
//
//  Created by William Lee on 07/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ConfirmViewController: UIViewController {
    @IBOutlet weak var labelExplanation: UILabel!
    @IBOutlet weak var textConfirm: UITextField!
    @IBOutlet weak var buttonDelete: UIButton!
    var confirmWord = ""
    var operation : SettingsOperation?
    
    let words = [ "edmond", "jimmy", "charlie", "william", "masters", "hoshi" ]
    
    func getExplanationText( ) -> String {
        return "Please confirm you wish to proceed by entering \"\(confirmWord)\" into the text field below"
    }
    
    @IBAction func textValueEdited(_ sender: Any) {
        if textConfirm.text == confirmWord {
            buttonDelete.isEnabled = true
            buttonDelete.setTitleColor(UIColor(named: "color_danger"), for: .normal)
        } else {
            buttonDelete.isEnabled = false
            buttonDelete.setTitleColor(UIColor.gray, for: .normal)        }
    }
    
    @IBAction func performAction(_ sender: Any) {
        debugPrint("selected delete")
        if ( SettingsOperation.DeleteEverything == operation ) {
            debugPrint("performing delete")
            if let userPath = userDir() {
                let database = Database.database()
                let userRef = database.reference(withPath: userPath)
                userRef.removeValue()
                debugPrint("unwind to settings")
                performSegue(withIdentifier: "segueUnwindToSettings", sender: self)
            }
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Choose the random word
        let idx = Int(arc4random_uniform(UInt32(words.count-1)))
        confirmWord = words[idx]
        labelExplanation.text = getExplanationText()
            
        // Do any additional setup after loading the view.
        buttonDelete.setTitle("Delete Everything", for: .normal)
        buttonDelete.isEnabled = false
        buttonDelete.setTitleColor(UIColor.gray, for: .normal)
        
        // Set the text confirm as default interaction
        textConfirm.becomeFirstResponder()
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
