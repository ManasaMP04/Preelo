//
//  AccountSettingsVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 12/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class AccountSettingsVC: UIViewController {

    enum Selection: Int {
        
        case personalInfo = 0
        case childrenListInfo
    }

    
    
    @IBOutlet weak var saveButton: UIButton!
    @IBOutlet weak var discardChangeButton: UIButton!
    @IBOutlet weak var personalInfoButton: UIButton!
    @IBOutlet weak var childrenInfoButton: UIButton!
    fileprivate var selection: Selection = .childrenListInfo

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
  StaticContentFile.setButtonFont(saveButton)
        StaticContentFile.setButtonFont(discardChangeButton, backgroundColorNeeed: false)
        
        
        
        
        
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


    @IBAction func PersonalBUttonAction(_ sender: Any) {
    self.personalButtonSelected(true)
    }
   
    @IBAction func childernListInfoButtonAction(_ sender: Any) {
        self.personalButtonSelected(false)

    }
    
    
    
    
    
    fileprivate func personalButtonSelected(_ status: Bool) {
        
        personalInfoButton.isSelected = status
        childrenInfoButton.isSelected       = !status
        selection = status ? .personalInfo : .childrenListInfo
        personalInfoButton.backgroundColor =  status ? UIColor.clear : UIColor.colorWithHex(0xE6FAFE)
        childrenInfoButton.backgroundColor = status ? UIColor.colorWithHex(0xE6FAFE) : UIColor.clear
        childrenInfoButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0xA7A9AC) : UIColor.colorWithHex(0x40AABB)
        personalInfoButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0x40AABB) : UIColor.colorWithHex(0xA7A9AC)
        childrenInfoButton.titleLabel?.font = status ? UIFont(name: "Ubuntu", size: 12)! : UIFont(name: "Ubuntu-Bold", size: 12)!
        personalInfoButton.titleLabel?.font = status ? UIFont(name: "Ubuntu-Bold", size: 12)! : UIFont(name: "Ubuntu", size: 12)!
        
           }






}









