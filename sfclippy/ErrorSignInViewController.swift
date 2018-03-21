//
//  ErrorSignInViewController.swift
//  sfclippy
//
//  Created by William Lee on 15/03/2018.
//  Copyright © 2018 William Lee. All rights reserved.
//

import UIKit
import GoogleSignIn

class ErrorSignInViewController: UIViewController, GIDSignInUIDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        GIDSignIn.sharedInstance().uiDelegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    @IBAction func signInAgain(_ sender: Any) {
        dismiss(animated: true, completion: nil)
        //performSegue(withIdentifier: "segueUnwindToSignIn", sender: self)
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
