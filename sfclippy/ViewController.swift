//
//  ViewController.swift
//  sfclippy
//
//  Created by William Lee on 16/11/2017.
//  Copyright © 2017 William Lee. All rights reserved.
//

import UIKit
import FirebaseDatabase

class ViewController: UIViewController {
    var database : Database?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.database = Database.database()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordP1Win(_ sender: Any) {
        let ref = database?.reference(withPath: "test")
        let child = ref?.childByAutoId()
        let result : [String: String] = [
            "p1" : "Ryu",
            "p2" : "Ken",
            "winner" : "p1"]
        child?.updateChildValues(result)
    }
    
    @IBAction func recordP2Win(_ sender: Any) {
    }
}

