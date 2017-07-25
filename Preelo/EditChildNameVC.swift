//
//  EditChildNameVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 14/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class EditChildNameVC: UIViewController {
    
    @IBOutlet weak var confirmChangeButton: UIButton!
    @IBOutlet weak var cancelButton: UIButton!
    @IBOutlet weak var childrenFirstName: FloatingTextField!
    @IBOutlet weak var childrenLastName: FloatingTextField!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var customNavigation: CustomNavigationBar!
    
    fileprivate var childDetail : Any?
    
    init (_ childDetail: Any) {
        
        self.childDetail = childDetail
        
        super.init(nibName: "EditChildNameVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    override func viewDidLoad() {
        
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func gestureIsTapped(_ sender: Any) {
        
        view.endEditing(true)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
    
        view.endEditing(true)
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func confirmChangesButtonTapped(_ sender: Any) {
        
        view.endEditing(true)
        
        if let vc = navigationController?.viewControllerWithClass(AccountSettingsVC.self) as?  AccountSettingsVC {
        
            vc.refresh()
        }
    }
}

extension EditChildNameVC{
    fileprivate func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
        
        customNavigation.setTitle("Edit Child Name")
        customNavigation.delegate = self
        childrenFirstName.textFieldDelegate = self
        childrenLastName.textFieldDelegate = self
        StaticContentFile.setFontForTF(childrenFirstName, autoCaps: false)
        StaticContentFile.setFontForTF(childrenLastName, autoCaps: false)
        StaticContentFile.setButtonFont(confirmChangeButton)
        StaticContentFile.setButtonFont(cancelButton, backgroundColorNeeed: false, shadowNeeded: false)
    }
    
}

//MARK:- KeyBoard delegate methods

extension EditChildNameVC {
    
    @objc fileprivate func keyboardWasShown(_ notification: Notification) {
        
        if let info = (notification as NSNotification).userInfo {
            
            let dictionary = info as NSDictionary
            
            let kbSize = (dictionary.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
            
            self.scrollViewBottomInset = kbSize.height + 10
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        self.scrollViewBottomInset = 0
    }
}

extension EditChildNameVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}

extension EditChildNameVC: PreeloTextFieldDelegate {




}





