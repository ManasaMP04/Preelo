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
    var webSocket = [SocketIOClient]()
    fileprivate var selectedChannelId = 0
    fileprivate var list = [Any]()
    let dbManager       = DBManager.init(fileName: "chat.db")!
    
    static let sharedInstance = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "MessageVC") as! MessageVC
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        
        super.viewWillAppear(true)
        
        if let navation = self.parent as? UINavigationController,
            let tab = navation.self.parent as? TabBarVC {
            tab.changeTheItem()
        }
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
            tableview?.reloadData()
        } else if !status {
            
            getChannel()
        }
    }
}

//MARK:- private methods

extension MessageVC {
    
    fileprivate func setup() {
        
         dbManager.delegate = self
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification), name: Notification.Name("NotificationIdentifier"), object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotificationForAuthRequest), name: Notification.Name("AuthNotificationIdentifier"), object: nil)
        
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
    
    fileprivate func callAPIForAcceptAuth(_ request: URLRequestConvertible, indexPath: IndexPath, data: DocAuthorizationRequest) {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        self.view.isUserInteractionEnabled = false
        
        Alamofire.request(request)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    StaticContentFile.updateAuthRequest(data)
                    self.list.remove(at: indexPath.row)
                    self.notificationCount.isHidden = self.list.count == 0
                    self.notificationCount.text = "\(self.list.count)"
                    self.tableview.deleteRows(at: [indexPath], with: .automatic)
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
        
        self.view.isUserInteractionEnabled = false
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
        activityIndicator?.startAnimating()
        
        Alamofire.request(urlRequest)
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    let channelData = data
                    channelData.auth_status = result.auth_status
                    StaticContentFile.updateChannelDetail(channelData, isAuthStatus: true, dbManager: self.dbManager)
                    
                    let chatVC = ChatVC(channelData)
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
            callAPIToSelectDocOrPatient(data)
        }else if selection == .message, let data = list[indexPath.row] as? ChannelDetail, !Reachability.forInternetConnection().isReachable() {
            
            let chatVC = ChatVC(data)
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
            
            self.callChannelAPI()
        } else if Reachability.forInternetConnection().isReachable() {
            
            StaticContentFile.isDoctorLogIn() ? self.callAPIToGetAuthRequest() : self.callAPIToGetPatientAuthRequest()
        } else if !Reachability.forInternetConnection().isReachable() {
            
            self.pullToRefreshControl?.endRefreshing()
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
                
                self.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list = result.data
                    self.tableview?.reloadData()
                    
                    for detail in result.data {
                        
                        StaticContentFile.insertRowIntoDB(channelDetail: detail, dbManager: self.dbManager)
                    }
                }}
    }
    
    fileprivate func getChannel() {
        
        list.removeAll()
        
        let queryString = String(format: "select  * from \(StaticContentFile.channelTableName)")
        
        dbManager.getDataForQuery(queryString)
    }
    
    fileprivate func callAPIToGetAuthRequest() {
        
        let plistStorageManager = PlistManager()
        plistStorageManager.deleteObject(forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
        Alamofire.request(AuthorizationRequestListRouter.get())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list = result.authRequest
                    self.notificationCount.text = "\(self.list.count)"
                    self.notificationCount.isHidden = self.list.count == 0
                    self.tableview.reloadData()
                    StaticContentFile.saveAuthRequest(result)
                }else if let result = response.result.value {
                    
                    self.view.showToast(message:  result.message)
                } else {
                    
                    self.view.showToast(message:  "please try again later")
                }}
    }
    
    fileprivate func callAPIToGetPatientAuthRequest() {
        
        let plistStorageManager = PlistManager()
        plistStorageManager.deleteObject(forKey: "\(StaticContentFile.getId())", inFile: .authRequest)
        Alamofire.request(AuthorizationRequestListRouter.get_patient_AuthRequest())
            .responseObject { (response: DataResponse<AuthorizeRequest>) in
                
                self.stopAnimating()
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.list = result.authRequest
                    self.tableview.reloadData()
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
        detail.lastMsgId = Int(sqlite3_column_int(statement, 12))
        detail.chatTitle = String(cString: sqlite3_column_text(statement, 13))
        detail.chatLabelTitle = String(cString: sqlite3_column_text(statement, 14))
        
        list.append(detail)
        
        tableview?.reloadData()
    }
}

extension MessageVC: ChatVCDelegate {
    
    func chatVCDelegateToRefresh(_ vc: ChatVC, isAuthRequest: Bool) {
        
        if isAuthRequest, !StaticContentFile.isDoctorLogIn() {
            
            self.view.isUserInteractionEnabled = false
            self.activityIndicator?.startAnimating()
            callAPIToGetPatientAuthRequest()
        } else {
            
            authorizationButtonSelected(isAuthRequest)
        }
    }
}

//MARK:- Establishment of Socket

extension MessageVC {
    
    func establishConnection() {
        
        if let servers = defaults.value(forKey: "socketServers") as? [[String: Any]] {
            
            for dict in servers {
                
                if let url = dict["address"] as? String,
                    let UrlForSocket = URL(string: url + "/") {
                    
                    let skt = SocketIOClient( socketURL: UrlForSocket, config: [.connectParams(["token": StaticContentFile.getToken()])])
                    
                    webSocket.append(skt)
                    
                    skt.onAny({ (event) in
                        
                        if event.event == "error" {
                            
                            self.showAlert()
                        } else  if (event.event == "chat message" || event.event == "image"),
                            let data = event.items as? [[String: Any]] {
                            
                            for dict in data {
                                
                                self.saveChannelDataFromSocket(dict)
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name("NotificationIdentifier"), object: nil, userInfo: nil)
                        } else  if event.event == "auth request" ,
                            let data = event.items as? [[String: Any]] {
                            
                            for dict in data {
                                
                                self.saveAuthStatusFromSocket(dict, isForAuthorize: false)
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name("AuthNotificationIdentifier"), object: nil, userInfo: nil)
                        } else  if event.event == "authorized message" ,
                            let data = event.items as? [[String: Any]] {
                            
                            for dict in data {
                                
                                self.saveAuthStatusFromSocket(dict, isForAuthorize: true)
                            }
                            
                            NotificationCenter.default.post(name: Notification.Name("AuthNotificationIdentifier"), object: nil, userInfo: nil)
                        }
                    })
                    skt.connect()
                }
            }
        }
    }
    
    func closeConnection() {
        
        for skt in webSocket {
            
            skt.disconnect()
        }
    }
    
    @objc fileprivate func handleNotification() {
        
        if selection == .message {
            
            getChannel()
            
            if let vc = self.navigationController?.viewControllerWithClass(ChatVC.self) as? ChatVC, let details = list as? [ChannelDetail] {
                
                for data in details {
                    
                    if data.channel_id == selectedChannelId {
                        
                        vc.channelDetail = data
                        vc.refresh()
                        return
                    }}}
        }
    }
    
    @objc fileprivate func handleNotificationForAuthRequest() {
        
        if selection == .authentication, let authRequest = StaticContentFile.getAuthRequest() {
            
            self.list = authRequest.authRequest
            self.tableview?.reloadData()
        }
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
            
            activityIndicator = UIActivityIndicatorView.activityIndicatorToView(view)
            self.activityIndicator?.startAnimating()
            self.view.isUserInteractionEnabled = false
            callChannelAPI()
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
            let msgId = event["message_id"] as? Int {
            
            let channel = ChannelDetail()
            channel.channel_id = id
            channel.channel_name = name
            channel.unread_count = 1
            
            if msgType == "simple",
                let message = event["message"] as? String {
                
                channel.lastMsg = message
                
                if let auth = event["auth_status"] as? String {
                
                    channel.auth_status = auth
                }
                
                StaticContentFile.updateChannelDetail(channel, isAuthStatus: false, dbManager: dbManager )
                let recentMsg = RecentMessages(msgType, text: message, image: nil, senderId: "", timeInterval: Date().stringWithDateFormat("yyyy-M-dd'T'HH:mm:ss.A"))
                recentMsg.message_id = msgId
                channel.recent_message = [recentMsg]
                StaticContentFile.insertRowIntoDB(recentMsg, channelDetail: channel, dbManager: self.dbManager)
            } else if let message = event["message"] as? String,
                let image = event["image_url"] as? String {
                
                channel.lastMsg = message
                StaticContentFile.updateChannelDetail(channel, isAuthStatus: false, dbManager: dbManager)
                
                let recentMsg = RecentMessages(msgType, text: message, image: image, senderId: "", timeInterval: Date().stringWithDateFormat("yyyy-M-dd'T'HH:mm:ss.A"))
                recentMsg.message_id = msgId
                channel.recent_message = [recentMsg]
                StaticContentFile.insertRowIntoDB(recentMsg, channelDetail: channel, dbManager: self.dbManager)
            }
        }
    }
    
    fileprivate func saveAuthStatusFromSocket(_ event: [String: Any], isForAuthorize: Bool) {
        
        if let firstname = event["firstname"] as? String,
            let lastname = event["lastname"] as? String,
            let relationship = event["relationship"] as? String,
            let doctorid = event["doctorid"] as? Int,
            let patientid = event["patientid"] as? Int,
            let title = event["title"] as? String,
            let subtitle = event["subtitle"] as? String,
            let parentid = event["parentid"] as? Int,
            let family_id = event["family_id"] as? Int,
            let doctor_firstname = event["doctor_firstname"] as? String,
            let doctor_lastname = event["doctor_lastname"] as? String {
            
            let authRequest = AuthorizeRequest()
            let auth = DocAuthorizationRequest()
            
            auth.firstname = firstname
            auth.lastname = lastname
            auth.relationship      = relationship
            auth.patientid         = patientid
            auth.parentid          = parentid
            auth.title             = title
            auth.subtitle          = subtitle
            
            auth.family_id         = family_id
            auth.doctorid          = doctorid
            auth.doctor_firstname  = doctor_firstname
            auth.doctor_lastname   = doctor_lastname
            
            authRequest.authRequest = [auth]
            
            if isForAuthorize {
                
                StaticContentFile.updateAuthRequest(auth)
            } else{
                
                StaticContentFile.saveAuthRequest(authRequest)
            }
        }
    }
}

