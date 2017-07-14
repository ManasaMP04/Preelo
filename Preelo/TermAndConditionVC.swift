//
//  TermAndConditionVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class TermAndConditionVC: UIViewController {

    
    @IBOutlet weak fileprivate var customNavigation: CustomNavigationBar!
    @IBOutlet weak var goBackButton: UIButton!
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    
        StaticContentFile.setButtonFont(goBackButton, backgroundColorNeeed: false)
        self.setup()
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


    fileprivate func setup(){
    
    customNavigation.setTitle("Terms and Conditions")
    
    }






}
