//
//  FeedBackSupportVC.swift
//  Preelo
//
//  Created by vmoksha mobility on 13/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire

class FeedBackSupportVC: UIViewController {

    @IBOutlet weak fileprivate var customNavigationBar: CustomNavigationBar!
    
    @IBOutlet fileprivate weak var sendButton: UIButton!
    @IBOutlet fileprivate weak var subject: FloatingTextField!
    @IBOutlet fileprivate weak var message: FloatingTextField!
    
    fileprivate var activityIndicator    : UIActivityIndicatorView?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func gestureTapped(_ sender: Any) {
        
        self.view.endEditing(true)
    }
    
    @IBAction func sendButtonAction(_ sender: Any) {
        
        callApi()
    }
    
    fileprivate func callApi() {
        
        if let subject = self.subject.text,
            let message = self.message.text, Reachability.forInternetConnection().isReachable() {
            
            activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
            activityIndicator?.startAnimating()
            self.view.isUserInteractionEnabled = false
            
            Alamofire.request(SettingRouter.post_feedbackSupport(subject, message))
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    self.view.isUserInteractionEnabled = true
                    self.activityIndicator?.stopAnimating()
                    
                    if let result = response.result.value, result.status == "SUCCESS"  {
                        
                        self.subject.text = nil
                        self.message.text = nil
                        self.view.showToast(message: result.message)
                    } else {
                        
                        self.view.showToast(message: "Failed to send the feedback")
                    }
            }
        } else if !Reachability.forInternetConnection().isReachable() {
        
             self.view.showToast(message: "Please check the internet connection")
        } else {
            
            self.view.showToast(message: "Please enter the required field")
        }
    }
    
    fileprivate func setup(){
        
        subject.selectAll(self)
        message.selectAll(self)
        subject.copy(self)
        message.copy(self)
        
        subject.isCompleteBoarder = true
        message.isCompleteBoarder = true
        subject.textFieldDelegate = self
        subject.validateForInputType(.generic, andNotifyDelegate: self)
        message.validateForInputType(.generic, andNotifyDelegate: self)
        message.textFieldDelegate = self
        StaticContentFile.setButtonFont(sendButton, backgroundColorNeeed: false, shadowNeeded: false)
        sendButton.layer.borderColor = UIColor.lightGray.cgColor
        customNavigationBar.setTitle("Feedback Support")
        customNavigationBar.delegate = self
        sendButton.backgroundColor = UIColor.lightGray
        sendButton.isUserInteractionEnabled = false
    }
}

extension FeedBackSupportVC: UIGestureRecognizerDelegate {
    
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        
        if let v1 = touch.view, v1 is UIButton {
            
            return false
        }
        return true
    }
}


extension FeedBackSupportVC:CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.navigationController?.popViewController(animated: true)
    }
}

//MARK:- TextFieldDelegate

extension FeedBackSupportVC : PreeloTextFieldDelegate {
    
    func textFieldReturned(_ textField: PreeloTextField) {
        
        if subject.isFirstResponder {
            
            subject.becomeFirstResponder()
        } else if subject.isFirstResponder {
            
            message.becomeFirstResponder()
        } else if message.isFirstResponder {
            
            self.view.endEditing(true)
            callApi()
        }
    }
    
    func textFieldEditingChanged(_ textField: PreeloTextField) {
    
        if let sub = subject.text, sub.characters.count > 0 ,
            let msg = message.text, msg.characters.count > 0 {
            
            sendButton.backgroundColor = UIColor.colorWithHex(0x3DB0BB)
            sendButton.layer.borderColor = UIColor.colorWithHex(0x3DB0BB).cgColor
            sendButton.isUserInteractionEnabled = true
        } else {
            
            sendButton.backgroundColor = UIColor.lightGray
            sendButton.isUserInteractionEnabled = false
            sendButton.layer.borderColor = UIColor.lightGray.cgColor
        }
    }
}


