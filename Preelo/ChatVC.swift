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
    
    fileprivate var messageList         = [RecentMessages]()
    fileprivate var activityIndicator   : UIActivityIndicatorView?
    fileprivate var channelDetail       : ChannelDetail?
    
    init (_ channelDetail: ChannelDetail?) {
        
        self.channelDetail = channelDetail
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
        
        if let detail = channelDetail {
            
            let vc = DisclaimerVC(detail)
            navigationController?.pushViewController(vc, animated: true)
        }
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
        
        StaticContentFile.setButtonFont(requestAuthButton)
        
        if let nav = self.parent as? UINavigationController, let tab = nav.parent as? UITabBarController {
            
            tab.tabBar.isHidden = true
        }
        
        if let detail = channelDetail {
            
            StaticContentFile.isDoctorLogIn() ? customeNavigation.setTitle(detail.patientname) :  customeNavigation.setTitle(detail.doctorname)
            
            callApiToGetMessages(detail)
        }
        
        customeNavigation.delegate = self
        tableview.register(UINib(nibName: "FromMessageCell", bundle: nil), forCellReuseIdentifier: FromMessageCell.cellId)
        tableview.register(UINib(nibName: "ToMessageCell", bundle: nil), forCellReuseIdentifier: ToMessageCell.cellId)
         tableview.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImageListCell.cellId)
        
        requestAuthorizationViewHeight.constant = 0
        authorizationView.isHidden = true
        toolbarView.isUserInteractionEnabled = true
        
        if !StaticContentFile.isDoctorLogIn() {
            
            requestAuthorizationViewHeight.constant = 182
            authorizationView.isHidden = false
            toolbarView.isUserInteractionEnabled = false
        }
        
        tableview.estimatedRowHeight = 20
        tableview.rowHeight  = UITableViewAutomaticDimension
    }
    
    fileprivate func callApiToGetMessages(_ data: ChannelDetail) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(SendTextMessageRouter.get(data))
            .responseArray(keyPath: "data") {(response: DataResponse<[RecentMessages]>) in
                
                if let result = response.result.value {
                    
                    self.messageList = result
                    self.tableview.reloadData()
                    self.activityIndicator?.stopAnimating()
                } else {
                    
                    self.activityIndicator?.stopAnimating()
                    self.view.showToast(message: "Please try again something went wrong")
                }}
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
        
        let message = messageList[indexPath.row]
        
        if message.person == "you" {
        
             let cell = tableView.dequeueReusableCell(withIdentifier: FromMessageCell.cellId, for: indexPath) as! FromMessageCell
            cell.showMessage(message)
            
            return cell
        } else {
        
             let cell = tableView.dequeueReusableCell(withIdentifier: ToMessageCell.cellId, for: indexPath) as! ToMessageCell
            
            cell.showMessage(message)
            
            return cell
        }
    }
}

extension ChatVC: ImageListCellDelegate {
    
    func imageListCell(_ cell: ImageListCell, imageList: [String], index: Int) {
    
        let vc = CompleteImageVC(imageList)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}
