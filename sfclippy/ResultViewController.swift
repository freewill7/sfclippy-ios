//
//  ResultViewController.swift
//  sfclippy
//
//  Created by William Lee on 15/02/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit

class ResultViewController: UIViewController {
    @IBOutlet weak var dateButton: UIButton!
    @IBOutlet weak var datePicker: UIDatePicker!
    @IBOutlet weak var labelP1: UILabel!
    @IBOutlet weak var labelP2: UILabel!
    @IBOutlet weak var labelWinner: UILabel!
    
    var result : BattleResult?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "YYYY-MM-dd HH:mm"
        
        if let res = result {
            datePicker.date = res.date
            labelP1.text = res.p1Name
            labelP2.text = res.p2Name
            labelWinner.text = res.p1Won ? "Player 1" : "Player 2"
        }

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func dateButtonClicked(_ sender: Any) {
        datePicker.isHidden = !datePicker.isHidden
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
