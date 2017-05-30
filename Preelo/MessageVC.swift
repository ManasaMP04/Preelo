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
    fileprivate var pullToRefreshControl : UIRefreshControl!
    
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
        
        if let tab = self.parent as? TabBarVC {
            
            tab.changeTheItem()
        }
    }
    
    func refresh() {
        
        authorizationButtonSelected(false)
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
        authorizationRequest.backgroundColor =  status ? UIColor.clear : UIColor.colorWithHex(0xE6FAFE)
        messagesButton.backgroundColor = status ? UIColor.colorWithHex(0xE6FAFE) : UIColor.clear
        messagesButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0xA7A9AC) : UIColor.colorWithHex(0x40AABB)
        authorizationRequest.titleLabel?.textColor = status ? UIColor.colorWithHex(0x40AABB) : UIColor.colorWithHex(0xA7A9AC)
        
        list.removeAll()
        if status, let request = StaticContentFile.getAuthRequest() {
            
            list = request.authRequest
            notificationCount.text = "\(list.count)"
            notificationCount.isHidden = list.count == 0
        } else if !status {
            
            list = StaticContentFile.getChannel()
        }
        
        tableview.reloadData()
    }
}

//MARK:- private methods

extension MessageVC {
    
    fileprivate func setup() {
        
        addPullToRefreshView()
        authorizationButtonSelected(false)
        notificationCount.layer.cornerRadius = 10.5
        notificationCount.clipsToBounds      = true
        
        StaticContentFile.isDoctorLogIn() ? customNavigationBar.setTitle("Welcome Doctor", backButtonImageName: "Menu") : customNavigationBar.setTitle(String(format: "Welcome %@", StaticContentFile.getName()), backButtonImageName: "Menu")
        customNavigationBar.delegate = self
        
        tableview.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: ChatCell.cellId)
        
        tableview.tableFooterView = UIView()
    }
    
    fileprivate func callAPIForAcceptAuth(_ request: URLRequestConvertible, indexPath: IndexPath, data: DocAuthorizationRequest) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(request)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                StaticContentFile.updateAuthRequest(data)
                self.activityIndicator?.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list.remove(at: indexPath.row)
                    self.notificationCount.isHidden = self.list.count == 0
                    self.notificationCount.text = "\(self.list.count)"
                    self.tableview.deleteRows(at: [indexPath], with: .automatic)
                }}
    }
    
    fileprivate func callAPIToSelectDocOrPatient(_ data: ChannelDetail) {
        
        StaticContentFile.isDoctorLogIn() ? callAPIToSelect(SelectRouter.patient_select_post(data.patientId, data.parentId, data.doctor_user_id), data: data) : callAPIToSelect(SelectRouter.doc_select_post(data.patientId, data.doctorId, data.doctor_user_id), data: data)
    }
    
    fileprivate func callAPIToSelect(_ urlRequest: URLRequestConvertible, data: ChannelDetail) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let chatVC = ChatVC(data)
                    self.navigationController?.pushViewController(chatVC, animated: true)
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
        
        let status = selection == .authentication && StaticContentFile.isDoctorLogIn()
        
        cell.showData(list[indexPath.row], isdeclineRequestViewShow: status)
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if StaticContentFile.isDoctorLogIn() && selection == .authentication {
            
            return 125
        }
        
        return 80
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selection == .message, let data = list[indexPath.row] as? ChannelDetail {
            
            callAPIToSelectDocOrPatient(data)
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension MessageVC: ChatCellDelegate {
    
    func chatCell(_ cell: ChatCell, isAuthAccepted: Bool) {
        
        if let indexPath = tableview.indexPath(for: cell), let data = list[indexPath.row] as? DocAuthorizationRequest {
            
            isAuthAccepted ? callAPIForAcceptAuth( AuthorizationRequestListRouter.approveAuth_post(data.patientid, data.parentid), indexPath: indexPath, data: data) : callAPIForAcceptAuth( AuthorizationRequestListRouter.rejectAuth_post(data.patientid, data.parentid), indexPath: indexPath, data: data)
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension MessageVC{
    
    fileprivate func addPullToRefreshView() {
        
        pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Sync detail", comment:"Advice"))
        pullToRefreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        tableview.addSubview(pullToRefreshControl!)
    }
    
    func refresh(_ sender: UIRefreshControl) {
        
        if selection == .message {
            
            self.callChannelAPI()
        } else {
            self.callAPIToGetAuthRequest()
        }
    }
    
    fileprivate func callChannelAPI() {
        
        Alamofire.request(AuthorizationRequestListRouter.channel_get())
            .responseObject {(response: DataResponse<ChannelObject>) in
                
                self.pullToRefreshControl?.endRefreshing()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list = result.data
                    self.tableview.reloadData()
                    for detail in result.data {
                        
                        StaticContentFile.saveMessage(detail)
                    }
                    
                }}
    }
    
    fileprivate func callAPIToGetAuthRequest() {
        
        Alamofire.request(AuthorizationRequestListRouter.get())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.pullToRefreshControl?.endRefreshing()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list = result.authRequest
                    self.tableview.reloadData()
                    StaticContentFile.saveAuthRequest(result)
                }}
    }
}

