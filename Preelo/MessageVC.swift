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
    
    static let sharedInstance = MessageVC()
    fileprivate let defaults  = UserDefaults.standard
    var webSocket = [SocketIOClient]()
    
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
        
        authorizationRequest.isSelected = status
        messagesButton.isSelected       = !status
        selection = status ? .authentication : .message
        authorizationRequest.backgroundColor =  status ? UIColor.white : UIColor.colorWithHex(0xE6FAFE)
        messagesButton.backgroundColor = status ? UIColor.colorWithHex(0xE6FAFE) : UIColor.white
        messagesButton.titleLabel?.textColor = status ? UIColor.colorWithHex(0xA7A9AC) : UIColor.colorWithHex(0x40AABB)
        authorizationRequest.titleLabel?.textColor = status ? UIColor.colorWithHex(0x40AABB) : UIColor.colorWithHex(0xA7A9AC)
        messagesButton.titleLabel?.font = status ? UIFont(name: "Ubuntu", size: 12)! : UIFont(name: "Ubuntu-Bold", size: 12)!
        authorizationRequest.titleLabel?.font = status ? UIFont(name: "Ubuntu-Bold", size: 12)! : UIFont(name: "Ubuntu", size: 12)!
        
        list.removeAll()
        
        if let _ = StaticContentFile.getAuthRequest() {
            
            notificationCount.text = "\(list.count)"
            notificationCount.isHidden = list.count == 0
        }
        
        if status, let request = StaticContentFile.getAuthRequest() {
            
            list = request.authRequest
        } else if !status {
            
            list = StaticContentFile.getChannel()
        }
        
        tableview.reloadData()
    }
}

//MARK:- private methods

extension MessageVC {
    
    fileprivate func setup() {
        
        NotificationCenter.default.addObserver(self, selector: #selector(self.handleNotification), name: Notification.Name("NotificationIdentifier"), object: nil)
        
        cardView.addShadowWithColor(UIColor.colorWithHex(0x23B5B9) , offset: CGSize.zero, opacity: 0.3, radius: 4)
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
                    chatVC.delegate = self
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
            
            return 158
        }
        
        return 90
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

extension MessageVC: ChatVCDelegate {
    
    func chatVCDelegateToRefresh(_ vc: ChatVC) {
        
        authorizationButtonSelected(false)
    }
    
    func chatVCDelegateToCallApi(_ vc: ChatVC) {
        
        self.callChannelAPI()
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
    
        self.list = StaticContentFile.getChannel()
        self.tableview?.reloadData()
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
                
                let recentMsg = RecentMessages(msgType, text: message, image: nil, senderId: "", timeInterval: Date().stringWithDateFormat("yyyy-M-dd'T'HH:mm:ss.A"))
                recentMsg.message_id = msgId
                channel.recent_message = [recentMsg]
            } else if let message = event["message"] as? String,
                let image = event["image_url"] as? String {
                
                let recentMsg = RecentMessages(msgType, text: message, image: image, senderId: "", timeInterval: Date().stringWithDateFormat("yyyy-M-dd'T'HH:mm:ss.A"))
                recentMsg.message_id = msgId
                channel.recent_message = [recentMsg]
            }
            
            StaticContentFile.saveMessage(channel)
        }
    }
}

