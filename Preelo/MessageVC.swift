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
import SocketIO
import ObjectMapper

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
    @IBOutlet weak var cardView: UIView!
    
    fileprivate var selection: Selection = .authentication
    fileprivate var activityIndicator    : UIActivityIndicatorView?
    fileprivate var pullToRefreshControl : UIRefreshControl!
    
    fileprivate let defaults  = UserDefaults.standard
    fileprivate var selectedChannelId = 0
    fileprivate var list = [Any]()
    let dbManager       = DBManager.init(fileName: "chat.db")!
    fileprivate var isChannelCall  = false
    fileprivate var updateChannel = false
    fileprivate var updateChannelDetail: ChannelDetail?
    fileprivate var selectedChannel: ChannelDetail?
    
    static let sharedInstance = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageVC") as! MessageVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        
        handleSocketConnection()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        if let nav = self.parent as? UINavigationController,
            let tab = nav.parent as? TabBarVC {
            
            tab.tabBar.isHidden = false
            tab.changeTheItem()
        }
    }
    
    fileprivate func handleSocketConnection() {
        
        SocketIOManager.sharedInstance.connectToServer(completionHandler: { (userList, success, eventName: String) -> Void in
            
            DispatchQueue.main.async(execute: { () -> Void in
                
                if let data = userList,
                    (eventName == StaticContentFile.socketMsgEventName ||  eventName == StaticContentFile.socketImageEventName) {
                    
                    self.saveChannelDataFromSocket(data)
                } else if let data = userList, (eventName == StaticContentFile.socketAuthorizeEventName ||  eventName == StaticContentFile.socketAuthRequestEventName) {
                    
                    self.handleNotificationForAuthRequest(data, isForAuthorize: eventName == StaticContentFile.socketAuthorizeEventName)
                } else if eventName == "error" {
                    
                    self.showAlert()
                }
            })
        })
    }
    
    @IBAction func authorizationButtonTapped(_ sender: Any) {
        
        authorizationButtonSelected(true)
    }
    
    @IBAction func messageButtonTapped(_ sender: Any) {
        
        authorizationButtonSelected(false)
    }
    
    fileprivate func authorizationButtonSelected(_ status: Bool) {
        
        authorizationRequest?.isSelected = status
        messagesButton?.isSelected       = !status
        selection = status ? .authentication : .message
        authorizationRequest?.backgroundColor =  status ? UIColor.white : UIColor.colorWithHex(0xE6FAFE)
        messagesButton?.backgroundColor = status ? UIColor.colorWithHex(0xE6FAFE) : UIColor.white
        messagesButton?.titleLabel?.textColor = status ? UIColor.colorWithHex(0xA7A9AC) : UIColor.colorWithHex(0x40AABB)
        authorizationRequest?.titleLabel?.textColor = status ? UIColor.colorWithHex(0x40AABB) : UIColor.colorWithHex(0xA7A9AC)
        messagesButton?.titleLabel?.font = status ? UIFont(name: "Ubuntu", size: 12)! : UIFont(name: "Ubuntu-Bold", size: 12)!
        authorizationRequest?.titleLabel?.font = status ? UIFont(name: "Ubuntu-Bold", size: 12)! : UIFont(name: "Ubuntu", size: 12)!
        
        list.removeAll()
        
        if let data = StaticContentFile.getAuthRequest() {
            
            notificationCount?.text = "\(data.authRequest.count)"
            notificationCount?.isHidden = data.authRequest.count == 0
        }
        
        if status, let request = StaticContentFile.getAuthRequest() {
            
            list = request.authRequest
        } else if !status {
            
            getChannel()
        }
        
        tableview?.reloadData()
    }
}

//MARK:- private methods

extension MessageVC {
    
    fileprivate func setup() {
        
        dbManager.delegate = self
        
        cardView?.addShadowWithColor(UIColor.colorWithHex(0x23B5B9) , offset: CGSize.zero, opacity: 0.3, radius: 4)
        self.navigationController?.navigationBar.isHidden = true
        addPullToRefreshView()
        authorizationButtonSelected(false)
        notificationCount.layer.cornerRadius = 10.5
        notificationCount.clipsToBounds      = true
        
        StaticContentFile.isDoctorLogIn() ? customNavigationBar.setTitle("Welcome Doctor", backButtonImageName: "Menu") : customNavigationBar.setTitle(String(format: "Welcome %@", StaticContentFile.getName()), backButtonImageName: "Menu")
        customNavigationBar.delegate = self
        
        tableview.register(UINib(nibName: "ChatCell", bundle: nil), forCellReuseIdentifier: ChatCell.cellId)
        
        tableview.tableFooterView = UIView()
    }
    
    func startAnimating() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        self.view.isUserInteractionEnabled = false
    }
    
    fileprivate func callAPIForAcceptAuth(_ request: URLRequestConvertible, indexPath: IndexPath, data: DocAuthorizationRequest) {
        
        startAnimating()
        
        Alamofire.request(request)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    StaticContentFile.updateAuthRequest(data)
                    self.notificationCount.isHidden = result.authRequest.count == 0
                    self.notificationCount.text = "\(result.authRequest.count)"
                } else if let result = response.result.value {
                    
                    self.view.showToast(message:  result.message)
                } else {
                    
                    self.view.showToast(message:  "please try again later")
                }}
    }
    
    fileprivate func callAPIToSelectDocOrPatient(_ data: ChannelDetail) {
        
        if Reachability.forInternetConnection().isReachable() {
            
            StaticContentFile.isDoctorLogIn() ? callAPIToSelect(SelectRouter.patient_select_post(data.patientId, data.parentId, data.doctor_user_id), data: data) : callAPIToSelect(SelectRouter.doc_select_post(data.patientId, data.doctorId, data.doctor_user_id), data: data)
        }
    }
    
    fileprivate func callAPIToSelect(_ urlRequest: URLRequestConvertible, data: ChannelDetail) {
        
        startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let channelData = data
                    channelData.auth_status = result.auth_status
                    StaticContentFile.updateChannelDetail(channelData, isAuthStatus: true, dbManager: self.dbManager,isLastMessage: false)
                    
                    let chatVC = ChatVC(channelData)
                    chatVC.hidesBottomBarWhenPushed = true
                    chatVC.delegate = self
                    self.navigationController?.pushViewController(chatVC, animated: true)
                } else if let result = response.result.value {
                    
                    self.view.showToast(message:  result.message)
                } else {
                    
                    self.view.showToast(message:  "please try again later")
                }
        }
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
        
        cell.showData(list[indexPath.row], isdeclineRequestViewShow: selection == .authentication )
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        if selection == .authentication {
            
            return 145
        }
        
        return 100
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if selection == .message, let data = list[indexPath.row] as? ChannelDetail, Reachability.forInternetConnection().isReachable()  {
            
            selectedChannelId = data.channel_id
            selectedChannel   = data
            callAPIToSelectDocOrPatient(data)
        }else if selection == .message, let data = list[indexPath.row] as? ChannelDetail, !Reachability.forInternetConnection().isReachable() {
            
            let chatVC = ChatVC(data)
            selectedChannelId = data.channel_id
            selectedChannel   = data
            chatVC.delegate = self
            self.navigationController?.pushViewController(chatVC, animated: true)
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension MessageVC: ChatCellDelegate {
    
    func chatCell(_ cell: ChatCell, isAuthAccepted: Bool) {
        
        if let indexPath = tableview.indexPath(for: cell), let data = list[indexPath.row] as? DocAuthorizationRequest {
            
            if isAuthAccepted, Reachability.forInternetConnection().isReachable()  {
                
                callAPIForAcceptAuth( AuthorizationRequestListRouter.approveAuth_post(data.patientid, data.parentid), indexPath: indexPath, data: data)
            } else if Reachability.forInternetConnection().isReachable() {
                
                StaticContentFile.isDoctorLogIn() ? callAPIForAcceptAuth( AuthorizationRequestListRouter.rejectAuth_post(data.patientid, data.parentid), indexPath: indexPath, data: data) : callAPIForAcceptAuth( AuthorizationRequestListRouter.cancel_AuthRequest(data.patientid, data.doctorid), indexPath: indexPath, data: data)
            }
        }
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension MessageVC{
    
    fileprivate func addPullToRefreshView() {
        
        pullToRefreshControl = UIRefreshControl()
        pullToRefreshControl.attributedTitle = NSAttributedString(string: NSLocalizedString("Sync detail", comment:"Advice"))
        pullToRefreshControl.addTarget(self, action: #selector(refresh(_:)), for: UIControlEvents.valueChanged)
        tableview?.addSubview(pullToRefreshControl)
    }
    
    @objc fileprivate func refresh(_ sender: UIRefreshControl?) {
        
        if selection == .message, Reachability.forInternetConnection().isReachable() {
            
            startAnimating()
            self.callChannelAPI()
        } else if Reachability.forInternetConnection().isReachable() {
            
            StaticContentFile.isDoctorLogIn() ? self.callAPIToGetAuthRequest() : self.callAPIToGetPatientAuthRequest()
        } else if !Reachability.forInternetConnection().isReachable() {
            
            self.stopAnimating()
            authorizationButtonSelected(selection == .message)
        }
    }
    
    fileprivate func stopAnimating() {
        
        self.pullToRefreshControl?.endRefreshing()
        self.activityIndicator?.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    func callChannelAPI() {
        
        StaticContentFile.clearDbTableWithId(dbManager: self.dbManager)
        
        Alamofire.request(AuthorizationRequestListRouter.channel_get())
            .responseObject {(response: DataResponse<ChannelObject>) in
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    if self.selection == .message {
                        
                        self.list = result.data
                        self.tableview?.reloadData()
                    }
                    
                    for detail in result.data {
                        
                        StaticContentFile.insertRowIntoDB(channelDetail: detail, dbManager: self.dbManager)
                    }
                }
                
                self.stopAnimating()
        }
    }
    
    fileprivate func getChannel() {
        
        if selection == .message {
            
            list.removeAll()
        }
        
        let queryString = String(format: "select  * from '\(StaticContentFile.channelTableName)' where userId = '\(StaticContentFile.getId())'")
        
        dbManager.getDataForQuery(queryString)
    }
    
    func callAPIToGetAuthRequest() {
        
        let plistStorageManager = PlistManager()
        plistStorageManager.deleteObject(forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
        Alamofire.request(AuthorizationRequestListRouter.get())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    if self.selection == .authentication {
                        
                        self.list = result.authRequest
                        self.tableview?.reloadData()
                    }
                    
                    self.notificationCount.text = "\(result.authRequest.count)"
                    self.notificationCount.isHidden = result.authRequest.count == 0
                    StaticContentFile.saveAuthRequest(result)
                }else if let result = response.result.value {
                    
                    self.view.showToast(message:  result.message)
                } else {
                    
                    self.view.showToast(message:  "please try again later")
                }}
    }
    
    func callAPIToGetPatientAuthRequest() {
        
        let plistStorageManager = PlistManager()
        plistStorageManager.deleteObject(forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
        Alamofire.request(AuthorizationRequestListRouter.get_patient_AuthRequest())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.notificationCount?.text = "\(result.authRequest.count)"
                    self.notificationCount?.isHidden = result.authRequest.count == 0
                    
                    if self.selection == .authentication {
                        
                        self.list = result.authRequest
                        self.tableview?.reloadData()
                    }
                    
                    StaticContentFile.saveAuthRequest(result)
                }else if let result = response.result.value {
                    
                    self.view.showToast(message:  result.message)
                } else {
                    
                    self.view.showToast(message:  "please try again later")
                }}
    }
}

extension MessageVC: DBManagerDelegate {
    
    func dbManager(_ statement: OpaquePointer!) {
        
        if !updateChannel {
            
            let detail = ChannelDetail()
            
            detail.channel_id = Int(sqlite3_column_int(statement, 0))
            detail.relationship = String(cString: sqlite3_column_text(statement, 1))
            detail.patientname = String(cString: sqlite3_column_text(statement, 2))
            detail.doctorname = String(cString: sqlite3_column_text(statement, 3))
            detail.parentname = String(cString: sqlite3_column_text(statement, 4))
            detail.doctor_initials = String(cString: sqlite3_column_text(statement, 5))
            detail.unread_count = Int(sqlite3_column_int(statement, 6))
            detail.doctorId = Int(sqlite3_column_int(statement, 7))
            detail.parentId = Int(sqlite3_column_int(statement, 8))
            detail.patientId = Int(sqlite3_column_int(statement, 9))
            detail.auth_status = String(cString: sqlite3_column_text(statement, 10))
            detail.doctor_user_id = Int(sqlite3_column_int(statement, 11))
            detail.lastMsg = String(cString: sqlite3_column_text(statement, 12))
            detail.chatTitle = String(cString: sqlite3_column_text(statement, 13))
            detail.chatLabelTitle = String(cString: sqlite3_column_text(statement, 14))
            detail.lastMsgId = Int(sqlite3_column_int(statement, 15))
            
            if selection == .message {
                
                list.append(detail)
            }
        } else if updateChannel {
            
            updateChannel = false
            
            let detail = ChannelDetail()
            
            detail.channel_id = Int(sqlite3_column_int(statement, 0))
            detail.unread_count = Int(sqlite3_column_int(statement, 1))
            detail.unread_count = detail.unread_count + 1
            
            updateChannelDetail = detail
        }
    }
}

extension MessageVC: ChatVCDelegate {
    
    func chatVCDelegateToRefresh(_ vc: ChatVC, isAuthRequest: Bool) {
        
        if isAuthRequest, !StaticContentFile.isDoctorLogIn() {
            
            startAnimating()
            callAPIToGetPatientAuthRequest()
        } else {
            
            authorizationButtonSelected(isAuthRequest)
        }
    }
}

//MARK:- Establishment of Socket

extension MessageVC {
    
    @objc fileprivate func handleNotificationForAuthRequest(_ data: [String: Any], isForAuthorize: Bool) {
        
        self.saveAuthStatusFromSocket(data, isForAuthorize: isForAuthorize)
    }
    
    func handleRemoteNotification () {
        
        if let vc = self.navigationController?.viewControllerWithClass(ChatVC.self) as? ChatVC, let details = list as? [ChannelDetail] {
            
            for data in details {
                
                if data.channel_id == selectedChannelId {
                    
                    vc.channelDetail = data
                    vc.callApiToGetMessages()
                    return
                }
            }
        } else {
            
            startAnimating()
            self.callChannelAPI()
            StaticContentFile.isDoctorLogIn() ? self.callAPIToGetAuthRequest() : self.callAPIToGetPatientAuthRequest()
        }
    }
    
    fileprivate func showAlert() {
        
        let refreshAlert = UIAlertController(title: "Error", message: "Sorry, there seems to be an issue with the connection!", preferredStyle: .alert)
        
        refreshAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: { (action: UIAlertAction!) in
            
            refreshAlert.dismiss(animated: true, completion: nil)
        }))
        
        present(refreshAlert, animated: true, completion: nil)
    }
    
    fileprivate func saveChannelDataFromSocket(_ event: [String: Any]) {
        
        if let id = event["channel_id"] as? Int,
            let name = event["channel_name"] as? String,
            let msgType = event["message_type"] as? String,
            let msgId = event["message_id"] as? Int,
            let email = event["email"] as? String ,
            let loginEmail = StaticContentFile.getUserProfile()?.email,
            let message = event["message"] as? String {
            
            let channel = ChannelDetail()
            channel.channel_id = id
            channel.channel_name = name
            channel.unread_count = 1
            channel.lastMsgId = msgId
            channel.lastMsg = message
            
            if let auth = event["auth_status"] as? String {
                
                channel.auth_status = auth
            }
            
            let sender = (email == loginEmail) ? "you" : "not you"
            
            if msgType == "simple" {
                
                let recentMsg = RecentMessages(msgType, text: message, image: nil, senderId: sender, timeInterval: Date().stringWithDateFormat("yyyy-M-dd'T'HH:mm:ss.A"))
                recentMsg.message_id = msgId
                channel.recent_message = [recentMsg]
                
                insertintoChannel(channel, recentMsg: recentMsg)
                
                StaticContentFile.insertRowIntoDB(recentMsg, channelDetail: channel, dbManager: self.dbManager)
            } else if msgType == "image", let image = event["image_url"] as? String {
                
                channel.lastMsg = "Image"
                let recentMsg = RecentMessages(msgType, text: "Image", image: image, senderId: sender, timeInterval: Date().stringWithDateFormat("yyyy-M-dd'T'HH:mm:ss.A"))
                recentMsg.message_id = msgId
                channel.recent_message = [recentMsg]
                
                insertintoChannel(channel, recentMsg: recentMsg)
                StaticContentFile.insertRowIntoDB(recentMsg, channelDetail: channel, dbManager: self.dbManager)
            }
        }
    }
    
    fileprivate func insertintoChannel(_ channel: ChannelDetail, recentMsg: RecentMessages) {
        
        if let details = list as? [ChannelDetail] {
            
            let indexes = details.enumerated().filter {
                $0.element.channel_id == channel.channel_id
                }.map{$0.offset}
            
            for index in indexes {
                
                let detail = details[index]
                detail.lastMsg = recentMsg.message_text
                detail.lastMsgId = recentMsg.message_id
                detail.recent_message = [recentMsg]
                detail.unread_count =  detail.unread_count + 1
                
                self.list = details
                
                if let vc = self.navigationController?.viewControllerWithClass(ChatVC.self) as? ChatVC {
                    
                    if channel.channel_id == selectedChannelId {
                        
                        detail.unread_count = 0
                        
                        vc.channelDetail = detail
                        vc.refresh(recentMsg)
                        
                        StaticContentFile.updateChannelDetail(detail, isAuthStatus: false, dbManager: dbManager, isLastMessage: false)
                    }
                } else {
                    
                    StaticContentFile.updateChannelDetail(channel, isAuthStatus: false, dbManager: dbManager, isLastMessage: true)
                    
                    updateChannel = true
                    
                    let queryString = String(format: "select channel_id,unread_count from '\(StaticContentFile.channelTableName)' where channel_id = '\(channel.channel_id)'")
                    
                    dbManager.getDataForQuery(queryString)
                    
                    if let detail = updateChannelDetail {
                        
                        StaticContentFile.updateChannelDetail(detail, isAuthStatus: false, dbManager: dbManager, isLastMessage: false)
                    }
                }
            }
            
            tableview?.reloadData()
        }
    }
    
    fileprivate func saveAuthStatusFromSocket(_ event: [String: Any], isForAuthorize: Bool) {
        
        if let doctorid = event["doctorid"] as? Int,
            let patientid = event["patientid"] as? Int,
            let parentid = event["parentid"] as? Int {
            
            let authRequest = AuthorizeRequest()
            let auth = DocAuthorizationRequest()
            
            auth.patientid         = patientid
            auth.doctorid          = doctorid
            auth.parentid          = parentid
            
            StaticContentFile.updateAuthRequest(auth)
            
            self.view.layoutIfNeeded()
            
            if let authStatus = event["auth_status"] as? String, isForAuthorize {
                
                if selection == .authentication,
                    let details = list as? [DocAuthorizationRequest] {
                    
                    authRequest.authRequest = [auth]
                    
                    let indexes = details.enumerated().filter {
                        $0.element.patientid == patientid && $0.element.doctorid == doctorid && $0.element.parentid == parentid
                        }.map{$0.offset}
                    
                    for index in indexes {
                        
                        self.list.remove(at: index)
                    }
                    
                    tableview?.reloadData()
                }
                
                if let vc = self.navigationController?.viewControllerWithClass(ChatVC.self) as? ChatVC,
                    let channel = selectedChannel,
                    auth.patientid  == channel.patientId,
                    auth.doctorid == channel.doctorId {
                    
                    vc.channelDetail.auth_status = authStatus
                    vc.showTheAuthRequestButton()
                }
            } else if let firstname = event["firstname"] as? String,
                let lastname = event["lastname"] as? String,
                let relationship = event["relationship"] as? String,
                let title = event["title"] as? String,
                let subtitle = event["subtitle"] as? String,
                let family_id = event["family_id"] as? Int {
                
                auth.firstname = firstname
                auth.lastname = lastname
                auth.relationship      = relationship
                auth.parentid          = parentid
                auth.title             = title
                auth.subtitle          = subtitle
                
                auth.family_id         = family_id
                authRequest.authRequest = [auth]
                
                
                StaticContentFile.saveAuthRequest(authRequest)
                
                if selection == .authentication,
                    let _ = list as? [DocAuthorizationRequest] {
                    
                    self.list.append(auth)
                    tableview?.reloadData()
                }
            }
            
            if let txt = self.notificationCount.text,
                let count = Int(txt), isForAuthorize {
                
                self.notificationCount.text = "\(count-1)"
                self.notificationCount.isHidden = count-1 == 0
            } else if !isForAuthorize,
                let txt = self.notificationCount.text,
                let count = Int(txt) {
                
                self.notificationCount.isHidden = false
                self.notificationCount.text = "\(count+1)"
            }
        }
    }
}

