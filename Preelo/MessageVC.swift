//
//  MessageVC.swift
//  Preelo
//
//  Created by Manasa MP on 12/03/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import AlamofireObjectMapper
import Alamofire

class MessageVC: UIViewController {
    
    enum Selection: Int {
        
        case message = 0
        case authentication
    }
    
    @IBOutlet fileprivate weak var notificationCount    : UILabel!
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var messagesButton       : UIButton!
    @IBOutlet fileprivate weak var authorizationRequest : UIButton!
    @IBOutlet fileprivate weak var tableview            : UITableView!
    
    fileprivate var selection: Selection = .authentication
    fileprivate var activityIndicator    : UIActivityIndicatorView?
    
    fileprivate var list = [Any]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        if let nav = self.parent as? UINavigationController, let tab = nav.parent as? UITabBarController {
            
            tab.tabBar.isHidden = false
        }
    }
    
    func showMessageList(_ doctorList: DoctorList) {
        
        if selection == .message {
            
            authorizationRequest.isSelected = false
            messagesButton.isSelected = true
            messagesButton.backgroundColor = UIColor.colorWithHex(0x3CCACC, alpha: 0.15)
            authorizationRequest.backgroundColor = UIColor.white
        } else {
            
            authorizationRequest.isSelected = true
            messagesButton.isSelected = false
            authorizationRequest.backgroundColor = UIColor.colorWithHex(0x3CCACC, alpha: 0.15)
            messagesButton.backgroundColor = UIColor.white
        }
    }
    
    @IBAction func authorizationButtonTapped(_ sender: Any) {
        
        authorizationButtonSelected(true)
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        
         authorizationButtonSelected(false)
    }
    
    fileprivate func authorizationButtonSelected(_ status: Bool) {
    
        authorizationRequest.isSelected = status
        messagesButton.isSelected       = !status
        selection = status ? .authentication : .message
        authorizationRequest.backgroundColor =  status ? UIColor.colorWithHex(0xE6FAFE) : UIColor.clear
        messagesButton.backgroundColor = status ? UIColor.clear : UIColor.colorWithHex(0xE6FAFE)
        messagesButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0x40AABB) : UIColor.colorWithHex(0xA7A9AC)
        authorizationRequest.titleLabel?.textColor = status ? UIColor.colorWithHex(0xA7A9AC) : UIColor.colorWithHex(0x40AABB)
    }
}

//MARK:- private methods

extension MessageVC {
    
    fileprivate func setup() {
        
         authorizationButtonSelected(true)
        
        StaticContentFile.isDoctorLogIn() ? customNavigationBar.setTitle("Welcome Doctor", backButtonImageName: "Menu") : customNavigationBar.setTitle(String(format: "Welcome %@", StaticContentFile.getName()), backButtonImageName: "Menu")
        customNavigationBar.delegate = self
        
        tableview.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: ChatCell.cellId)
        
        tableview.tableFooterView = UIView()
        tableview.estimatedRowHeight = 30
        tableview.rowHeight = UITableViewAutomaticDimension
        notificationCount.layer.cornerRadius = 10
        notificationCount.backgroundColor = UIColor.colorWithHex(0x3CCACC)
        notificationCount.isHidden = true
        
        if StaticContentFile.isDoctorLogIn() {
            
            callAPI()
        }
    }
    
    fileprivate func callAPI() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(AuthorizationRequestListRouter.get())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list = result.authRequest
                    self.tableview.reloadData()
                    
                    self.hideOrShowNotificationCount()
                }}
    }
    
    fileprivate func hideOrShowNotificationCount() {
        
        if list.count > 0 {
            
            self.notificationCount.isHidden = false
            notificationCount.text = "\(list.count)"
        } else {
            
            self.notificationCount.isHidden = true
        }
    }
    
    fileprivate func callAPIForAcceptAuth(_ request: URLRequestConvertible, indexPath: IndexPath) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(request)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list.remove(at: indexPath.row)
                    self.hideOrShowNotificationCount()
                    self.tableview.deleteRows(at: [indexPath], with: .automatic)
                }}
    }
}

//MARK:- CustomNavigationBarDelegate

extension MessageVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        if let slideOutVC = storyboard?.instantiateViewController(withIdentifier: "SlideOutVC") {
            navigationController?.pushViewController(slideOutVC, animated: true)
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension MessageVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ChatCell.cellId, for: indexPath) as! ChatCell
        cell.delegate = self
        
        if let auth = list[indexPath.row] as? DocAuthorizationRequest {
            
            cell.showData(auth.firstname, discription: String(format: "Patient %@ %@ has sent You an authorization request", auth.firstname, auth.lastname), time: "", image: "")
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension MessageVC: ChatCellDelegate {
    
    func chatCell(_ cell: ChatCell, isAuthAccepted: Bool) {
        
        if let indexPath = tableview.indexPath(for: cell), let data = list[indexPath.row] as? DocAuthorizationRequest {
            
            isAuthAccepted ? callAPIForAcceptAuth( AuthorizationRequestListRouter.approveAuth_post(data.patientid, data.parentid), indexPath: indexPath) : callAPIForAcceptAuth( AuthorizationRequestListRouter.rejectAuth_post(data.patientid, data.parentid), indexPath: indexPath)
        }
    }
}
