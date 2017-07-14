//
//  DeletAccountAlert.swift
//  Preelo
//
//  Created by vmoksha mobility on 13/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit


protocol DeletAccountDelegate:class{

    func tappedNoButton(_ deletAccountVC: DeletAccountAlert)
}


class DeletAccountAlert: UIViewController {

    @IBOutlet weak var yesButton: UIButton!
    @IBOutlet weak var noButton: UIButton!
   
    weak var delegate:DeletAccountDelegate?
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init (_ title: String) {
        super.init(nibName: "DeletAccountAlert", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
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
    @IBAction func yssButtonAction(_ sender: Any) {
   
    
    }

    @IBAction func noButtonAction(_ sender: Any) {
    delegate?.tappedNoButton(self)
    
    }






}
