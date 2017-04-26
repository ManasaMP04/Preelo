//
//  ChatVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class ChatVC: UIViewController {
    
    @IBOutlet fileprivate weak var customeNavigation    : CustomNavigationBar!
    @IBOutlet fileprivate weak var authorizationView    : UIView!
    @IBOutlet fileprivate weak var tableview            : UITableView!
    @IBOutlet fileprivate weak var scrollView           : UIScrollView!
    @IBOutlet fileprivate weak var toolbarView          : UIView!
    @IBOutlet fileprivate weak var requestAuthorizationViewHeight : NSLayoutConstraint!
    @IBOutlet fileprivate weak var requestAuthButton    : UIButton!
    @IBOutlet fileprivate weak var messageTF            : UITextField!
    
    fileprivate var docList         : DoctorList!
    fileprivate var childrenDetail  : ChildrenDetail!
    fileprivate var messageList     = [Int]()
    fileprivate var activityIndicator   : UIActivityIndicatorView?
    
    init (_ docList: DoctorList, childrenDetail: ChildrenDetail) {
        
        self.docList = docList
        self.childrenDetail = childrenDetail
        
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func requestAuthorisationButtonTapped(_ sender: Any) {
        
        let vc = DisclaimerVC(docList, childrenDetail: childrenDetail)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        if let text = messageTF.text {
            
            callAPIToSendText(text)
        }
    }
}

//MARK:- Private Methods

extension ChatVC {
    
    fileprivate func callAPIToSendText(_ text: String) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(SendTextMessageRouter.post(text))
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.activityIndicator?.stopAnimating()
                if let _ = response.result.value {
                    
                    
                } else {
                    
                    self.view.showToast(message: "Send Message Failed")
                } } .responseString { (string) in
                    
                    print(string)
        }
    }
    
    fileprivate func setup() {
        
        requestAuthButton.titleLabel?.font = StaticContentFile.buttonFont
        
        if let nav = self.parent as? UINavigationController, let tab = nav.parent as? UITabBarController {
            
            tab.tabBar.isHidden = true
        }
        
        customeNavigation.setTitle(docList.doctor_firstname)
        customeNavigation.delegate = self
        tableview.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: ChatCell.cellId)
        
        if childrenDetail.authstatus {
            
            requestAuthorizationViewHeight.constant = 0
            authorizationView.isHidden = true
            toolbarView.isUserInteractionEnabled = true
        } else {
            
            requestAuthorizationViewHeight.constant = 182
            authorizationView.isHidden = false
            toolbarView.isUserInteractionEnabled = false
        }
    }
}

extension ChatVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.cellId, for: indexPath) as! ChatCell
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 40
    }
}
