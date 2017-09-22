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
import DXPopover

protocol ChatVCDelegate: class {
    
    func chatVCDelegateToRefresh(_ vc: ChatVC, isAuthRequest: Bool)
}
class ChatVC: UIViewController {
    
    enum Selection:Int {
        
        case camera = 0
        case gallery
    }
    
    @IBOutlet fileprivate weak var authRequestTitle     : UILabel!
    @IBOutlet fileprivate weak var customeNavigation    : CustomNavigationBar!
    @IBOutlet fileprivate weak var authorizationView    : UIView!
    @IBOutlet fileprivate weak var tableview            : UITableView!
    @IBOutlet fileprivate weak var scrollView           : UIScrollView!
    @IBOutlet fileprivate weak var toolbarView          : UIView!
    @IBOutlet fileprivate weak var requestAuthorizationViewHeight : NSLayoutConstraint!
    @IBOutlet fileprivate weak var requestAuthButton    : UIButton!
    @IBOutlet fileprivate weak var messageTF            : UITextField!
    @IBOutlet fileprivate weak var deauthorizeButton    : UIButton!
    @IBOutlet fileprivate weak var cameraButton         : UIButton!
    @IBOutlet fileprivate weak var galleryButton        : UIButton!
    @IBOutlet fileprivate weak var scrollviewBottom     : NSLayoutConstraint!
    
    fileprivate var messageList         = [RecentMessages]()
    fileprivate var activityIndicator   : UIActivityIndicatorView?
    fileprivate var footerActivityIndicator   : UIActivityIndicatorView?
    fileprivate var images              = [UIImage]()
    fileprivate var selection:Selection = .camera
    fileprivate var isPatient_DocFlow   = false
    fileprivate var parentOrDocId      = 0
    fileprivate var name                = ""
    fileprivate let popAnimator   = DXPopover()
    var dbManager       = DBManager.init(fileName: "chat.db")!
    fileprivate var authViewHeight = CGFloat(160)
    fileprivate var newMsgList = [RecentMessages]()
    
    var lastScrollOffsetY: CGFloat = 0
    fileprivate var cellToShowMenu: UITableViewCell?
    
    var channelDetail       : ChannelDetail!
    
    weak var delegate: ChatVCDelegate?
    
    fileprivate var scrollViewBottomInset : CGFloat! {
        
        didSet {
            
            var currentInset                = self.scrollView.contentInset
            currentInset.bottom             = scrollViewBottomInset
            self.scrollView.contentInset    = currentInset
        }
    }
    
    init (_ channelDetail: ChannelDetail) {
        
        self.channelDetail = channelDetail
        self.isPatient_DocFlow = false
        name =  channelDetail.chatTitle
        
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    init (_ Id: Int, name: String) {
        
        self.parentOrDocId = Id
        self.isPatient_DocFlow = true
        self.name = name
        
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func awakeFromNib() {
        
        super.awakeFromNib()
        
        tableview.delegate = self
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
        tableview.scrollsToTop = true
        addMenuItem()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func changeAuthRequestToPending() {
        
        channelDetail.auth_status = "p"
        showTheAuthRequestButton()
        self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: true)
    }
    
    func refresh(_ msg: RecentMessages) {
        
        if checkWhetherMsgIsValid(msg) {
            
            var array = [RecentMessages]()
            array = self.messageList
            
            self.messageList.append(msg)
            
            if self.messageList.count > array.count {
                
                tableview.beginUpdates()
                
                tableview.insertRows(at: [IndexPath(row: array.count, section: 0)], with: .automatic)
                tableview.endUpdates()
                
                self.tableview.scrollToRow(at: IndexPath(row: array.count, section: 0), at: .top, animated: true)
            }
        }
    }
}

//MARK:- IBActions

extension ChatVC {
    
    @IBAction func tapGesture(_ sender: Any) {
        
        view.endEditing(true)
    }
    
    @IBAction func requestAuthorisationButtonTapped(_ sender: Any) {
        
        if StaticContentFile.isDoctorLogIn(), let _ = channelDetail, Reachability.forInternetConnection().isReachable() {
            
            callApiToAuthorize()
        } else if !StaticContentFile.isDoctorLogIn() {
            
            let vc = DisclaimerVC(channelDetail)
            navigationController?.pushViewController(vc, animated: true)
        } else if Reachability.forInternetConnection().isReachable() {
            
            self.view.showToast(message: "Please check the internet connection")
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        if let text = messageTF.text, text.characters.count > 0 {
            
            callAPIToSendText(text)
        }
    }
    
    @IBAction func galleryButtonTapped(_ sender: Any) {
        
        selection = .gallery
        
        selectImages()
    }
    
    @IBAction func cameraButtonTapped(_ sender: Any) {
        
        selection = .camera
        
        selectImages()
    }
    
    @IBAction func deauthorizeButtonTapped(_ sender: Any) {
        
        if Reachability.forInternetConnection().isReachable() {
            
            startAnimating()
            Alamofire.request(AuthorizationRequestListRouter.deAuthorize(channelDetail.patientId, channelDetail.parentId))
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    self.stopAnimating()
                    
                    if let result = response.result.value, result.status == "SUCCESS" {
                        
                        self.showAuthRequestTitle("This user is not authorised to send messages. Please click on the authorise button to allow the user to send messages")
                        self.requestAuthButton.setTitle("AUTHORIZE PARENT", for: .normal)
                        self.showAuthorizeButton(true)
                        
                        self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: false)
                    } else if let result = response.result.value {
                        
                        self.view.showToast(message: result.message)
                    } else {
                        
                        self.view.showToast(message: "Please try again later")
                    }}
        } else {
            
            self.view.showToast(message: "Please check the network connection")
        }
    }
    
    func showAuthorizeButton(_ show: Bool) {
        
        requestAuthorizationViewHeight.constant = show ? authViewHeight : 0
        authorizationView.isHidden = !show
        toolbarView.isUserInteractionEnabled = !show
        self.deauthorizeButton.isHidden = show
        self.channelDetail.auth_status =  show ? "f" : "t"
        StaticContentFile.updateChannelDetail(self.channelDetail, isAuthStatus: true, dbManager: dbManager, isLastMessage: false)
    }
}

//MARK:- Private Methods

extension ChatVC {
    
    fileprivate func callApiToAuthorize() {
        
        startAnimating()
        Alamofire.request(AuthorizationRequestListRouter.authorize(channelDetail.patientId, channelDetail.parentId))
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.showAuthorizeButton(false)
                    self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: false)
                } else if let result = response.result.value {
                    
                    self.view.showToast(message: result.message)
                } else {
                    
                    self.view.showToast(message: "Please try again later")
                }
        }
    }
    
    fileprivate func setup() {
        
        if let image = UIImage(named: "bgImg") {
            
            view.backgroundColor = UIColor.init(patternImage: image)
        }
        
        showTheAuthRequestButton()
        
        messageList.removeAll()
        
        createFooter ()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        messageTF.delegate = self
        
        StaticContentFile.setButtonFont(requestAuthButton, shadowNeeded: false)
        dbManager.delegate = self
        customeNavigation.setTitle(name)
        customeNavigation.delegate = self
        tableview.register(UINib(nibName: "FromMessageCell", bundle: nil), forCellReuseIdentifier: FromMessageCell.cellId)
        tableview.register(UINib(nibName: "ToMessageCell", bundle: nil), forCellReuseIdentifier: ToMessageCell.cellId)
        tableview.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImageListCell.cellId)
        
        tableview.estimatedRowHeight = 20
        tableview.rowHeight  = UITableViewAutomaticDimension
        
        self.messageList.removeAll()
        getDataFromSqlite()
        
        if Reachability.forInternetConnection().isReachable() {
            
            callApiToGetMessages()
        } else {
            
            self.tableview.reloadData()
            self.scrollToButtom()
        }
    }
    
    fileprivate func getDataFromSqlite() {
        
        var queryString = ""
        
        if messageList.count == 0 {
            
            queryString = String(format: "select  * from \(StaticContentFile.messageTableName) where channel_id = '\(channelDetail.channel_id)' ORDER BY message_id DESC LIMIT 20")
        } else if let msg = messageList.first {
            
            queryString = String(format: "select  * from \(StaticContentFile.messageTableName) where channel_id = '\(channelDetail.channel_id)' AND message_id < '\(msg.message_id)' ORDER BY message_id DESC LIMIT '\(messageList.count + 20)'")
        }
        
        dbManager.getDataForQuery(queryString)
    }
    
    fileprivate func checkWhetherMsgIsValid(_ msg: RecentMessages)  ->  Bool {
        
        let msgIndex = messageList.enumerated().filter {
            $0.element.message_id == msg.message_id
            }.map{$0.offset}
        
        return msgIndex.count == 0
    }
    
    fileprivate func showAuthRequestTitle(_ title: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style, NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x939598)]
        authRequestTitle.attributedText = NSAttributedString(string:title, attributes:attributes)
    }
    
    func showTheAuthRequestButton() {
        
        if !StaticContentFile.isDoctorLogIn(), channelDetail?.auth_status.lowercased() != "t" {
            
            toolbarView.isUserInteractionEnabled = false
            showAuthRequestTitle("You are not authorized to send messages. Please submit the Authorization Button to request authorization to send messages")
            requestAuthorizationViewHeight.constant = authViewHeight
            authorizationView.isHidden = false
            toolbarView.isUserInteractionEnabled = false
            cameraButton.setImage(UIImage(named: "Camera_Inactive"), for: .normal)
            galleryButton.setImage(UIImage(named: "Gallery-Icon"), for: .normal)
            
            let str = channelDetail.auth_status.lowercased() == "p" ? "AUTHORIZATION PENDING" : "REQUEST AUTHORIZATION"
            requestAuthButton.setTitle(str, for: .normal)
            requestAuthButton.isUserInteractionEnabled = channelDetail.auth_status.lowercased() != "p"
            
            if channelDetail.auth_status.lowercased() == "p" {
                
                requestAuthButton.backgroundColor = UIColor.lightGray
                requestAuthButton.layer.borderColor = UIColor.lightGray.cgColor
            } else {
                
                requestAuthButton.backgroundColor = UIColor.colorWithHex(0x3DB0BB)
                requestAuthButton.layer.borderColor = UIColor.colorWithHex(0x3DB0BB).cgColor
            }
        } else {
            
            toolbarView.isUserInteractionEnabled = true
            requestAuthorizationViewHeight.constant = channelDetail.auth_status.lowercased() != "t" ? authViewHeight : 0
            authorizationView.isHidden = channelDetail.auth_status.lowercased() == "t"
            
            if StaticContentFile.isDoctorLogIn(), channelDetail.auth_status.lowercased() != "t" {
                
                showAuthRequestTitle("This user is not authorised to send messages. Please click on the authorise button to allow the user to send messages")
                requestAuthButton.setTitle("AUTHORIZE PARENT", for: .normal)
            }
            
            deauthorizeButton.isHidden = !(StaticContentFile.isDoctorLogIn() && channelDetail.auth_status.lowercased() == "t")
            
            cameraButton.setImage(UIImage(named: "camera-Active"), for: .normal)
            galleryButton.setImage(UIImage(named: "Gallery-Icon Active"), for: .normal)
        }
    }
    
    fileprivate func scrollToButtom() {
        
        if self.messageList.count - 1 >= 0 {
            
            self.view.layoutIfNeeded()
            let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
            self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
            sleep(2)
        }
        
        self.stopAnimating()
    }
    
    fileprivate func createFooter () {
        
        let footer                          = UIView(frame: CGRect(x: 0, y: 0, width: StaticContentFile.screenWidth, height: 50))
        footerActivityIndicator                      = UIActivityIndicatorView(activityIndicatorStyle: .gray)
        
        footer.addSubview(footerActivityIndicator!)
        footerActivityIndicator?.center              = footer.center
        
        tableview.tableFooterView           = footer
    }
    
    fileprivate func selectImages() {
        
        images.removeAll()
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = selection == .camera ? .camera : .savedPhotosAlbum
        present(imagePicker, animated: true, completion: nil)
    }
    
    fileprivate func callAPIToSendText(_ text: String) {
        
        if Reachability.forInternetConnection().isReachable() {
            
            messageTF.text = ""
            Alamofire.request(SendTextMessageRouter.post(text))
                .responseObject { (response: DataResponse<SuccessStatus>) in
                    
                    if let result = response.result.value, result.status == "SUCCESS" {} else {
                        
                        self.view.showToast(message: "Send Message Failed")
                    } } .responseString { (string) in
                        
                        print(string)
            }
        } else {
            
            self.view.showToast(message: "Please check the internet connection")
        }
    }
    
    fileprivate func stopAnimating() {
        
        self.activityIndicator?.stopAnimating()
        self.footerActivityIndicator?.stopAnimating()
        self.view.isUserInteractionEnabled = true
    }
    
    fileprivate func startAnimating() {
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(self.view)
        self.view.isUserInteractionEnabled = false
        activityIndicator?.startAnimating()
    }
    
    func callApiToGetMessages() {
        
        startAnimating()
        
        Alamofire.request(SendTextMessageRouter.get(channelDetail))
            .responseArray(keyPath: "data") {(response: DataResponse<[RecentMessages]>) in
                
                self.view.layoutIfNeeded()
                
                if let result = response.result.value {
                    
                    for (i,msg) in result.enumerated() {
                        
                        if self.checkWhetherMsgIsValid(msg) { self.messageList.append(msg) }
                        StaticContentFile.insertRowIntoDB(msg, channelDetail: self.channelDetail, dbManager: self.dbManager)
                        
                        if i == result.count - 1 {
                            
                            self.channelDetail.unread_count = 0
                            self.channelDetail.lastMsgId = msg.message_id
                            self.channelDetail.lastMsg = msg.message_text
                             self.channelDetail.lastMsgDate = msg.message_date
                            StaticContentFile.updateChannelDetail(self.channelDetail, isAuthStatus: false, dbManager: self.dbManager, isLastMessage: true, isCount: true)
                            self.callapiToMarkedRead()
                        }
                    }
                    
                    if result.count == 0 {
                        
                        self.channelDetail.unread_count = 0
                        StaticContentFile.updateChannelDetail(self.channelDetail, isAuthStatus: false, dbManager: self.dbManager, isLastMessage: false, isCount: true)
                    }
                    
                    self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: false)
                    
                    self.tableview.reloadData()
                    self.scrollToButtom()
                } else {
                    
                    self.stopAnimating()
                    self.view.showToast(message: "Please try again something went wrong")
                }}
    }
    
    fileprivate func callapiToMarkedRead() {
        
        Alamofire.request(SendTextMessageRouter.post_msgRead(channelDetail.channel_id))
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.callapiToDeliver()
        }
    }
    
    fileprivate func callapiToDeliver() {
        
        Alamofire.request(SendTextMessageRouter.post_markdelivered())
            .responseObject { (response: DataResponse<SuccessStatus>) in}
    }
}

extension ChatVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            let vc = SelectedImagesVC(selection == .camera, image: image)
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
            picker.dismiss(animated: true, completion: nil)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension ChatVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension ChatVC: UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messageList[indexPath.row]
        
        if message.message_type.lowercased() != "simple" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.cellId, for: indexPath) as! ImageListCell
            cell.delegate = self
            cell.showImages(message, name: channelDetail.chatLabelTitle)
            
            return cell
            
        }
        
        let str = message.senderId.lowercased()
        
        if str == "you" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FromMessageCell.cellId, for: indexPath) as! FromMessageCell
            cell.showMessage(message)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ToMessageCell.cellId, for: indexPath) as! ToMessageCell
            
            cell.showMessage(message, name: channelDetail.chatLabelTitle)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, shouldShowMenuForRowAt indexPath: IndexPath) -> Bool {
        
        cellToShowMenu = tableView.cellForRow(at: indexPath)
        return true
    }
    
    func tableView(_ tableView: UITableView, canPerformAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) -> Bool {
        
        return false
    }
    
    func tableView(_ tableView: UITableView, performAction action: Selector, forRowAt indexPath: IndexPath, withSender sender: Any?) {
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor.clear
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        
        let currentOffsetY = scrollView.contentOffset.y
        
        if  currentOffsetY < lastScrollOffsetY,
            scrollView == tableview,
            let indexs = tableview.indexPathsForVisibleRows,
            indexs.contains(IndexPath(row: 17, section: 0)) {
            
            fetchMoreData()
        }
        
        lastScrollOffsetY = scrollView.contentOffset.y
    }
    
    func scrollViewDidScrollToTop(_ scrollView: UIScrollView) {
        
        fetchMoreData()
    }
    
    fileprivate func fetchMoreData() {
        
        let sl = "SELECT COUNT(*) FROM '\(StaticContentFile.messageTableName)' where channel_id = '\(channelDetail.channel_id)'"
        
        let count = Int(dbManager.getNumberOfRecord(sl))
        
        if count != messageList.count {
            
            newMsgList.removeAll()
            getDataFromSqlite()
            
            var indexPaths = [IndexPath]()
            
            for (i, _) in newMsgList.enumerated() {
                
                indexPaths.append(IndexPath(row: i, section: 0))
            }
            
            if indexPaths.count > 0 {
                
                tableview.beginUpdates()
                tableview.insertRows(at: indexPaths, with: .none)
                tableview.endUpdates()
            }
        }
    }
    
    fileprivate func addMenuItem() {
        
        let menuItem = UIMenuItem.init(title: "Copy", action: #selector(copyItem))
        let menuVc = UIMenuController.shared
        menuVc.menuItems = [menuItem]
        menuVc.update()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(menuControllerWillShow(_:)), name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(menuControllerWillHide(_:)), name: NSNotification.Name.UIMenuControllerWillHideMenu, object: nil)
    }
    
    @objc fileprivate func copyItem() {
        
        if let cell = cellToShowMenu  as? FromMessageCell {
            
            UIPasteboard.general.string = cell.descriptionLabel.text
        } else if let cell = cellToShowMenu  as? ToMessageCell {
            
            UIPasteboard.general.string = cell.descriptionLabel.text
        }
    }
    
    @objc fileprivate func menuControllerWillShow(_ notification: NSNotification) {
        
        let menuVc = UIMenuController.shared
        
        var v1 = UIView()
        if let cell = cellToShowMenu as? FromMessageCell {
            
            v1 = cell.cardView
        } else if let cell = cellToShowMenu  as? ToMessageCell {
            
            v1 = cell.cardView
        }
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
        
        let size = menuVc.menuFrame.size
        var menuFrame = CGRect()
        menuFrame.origin.x = tableview.frame.origin.x
        menuFrame.size = size
        menuVc.setMenuVisible(false, animated: false)
        
        menuVc.setTargetRect(menuFrame, in: v1)
        menuVc.setMenuVisible(true, animated: true)
    }
    
    @objc fileprivate func menuControllerWillHide(_ notification: NSNotification) {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(menuControllerWillShow(_:)), name: NSNotification.Name.UIMenuControllerWillShowMenu, object: nil)
    }
}

extension ChatVC: ImageListCellDelegate {
    
    func imageListCell(_ cell: ImageListCell, imageList: [RecentMessages], index: Int) {
        
        let vc = CompleteImageVC(imageList, name: channelDetail.patientname)
        self.navigationController?.pushViewController(vc, animated: true)
    }
}

//MARK:- KeyBoard delegate methods

extension ChatVC {
    
    @objc fileprivate func keyboardWasShown(_ notification: Notification) {
        
        self.view.layoutIfNeeded()
        if let keyboardFrame: NSValue = notification.userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue,
            let curve = notification.userInfo?[UIKeyboardAnimationCurveUserInfoKey] as? Int,
            let animationCurve = UIViewAnimationCurve(rawValue: curve),
            let animation = notification.userInfo?[UIKeyboardAnimationDurationUserInfoKey] as? TimeInterval {
            
            UIView.beginAnimations(nil, context: nil)
            UIView.setAnimationDuration(animation)
            UIView.setAnimationCurve(animationCurve)
            UIView.setAnimationBeginsFromCurrentState(true)
            
            let keyboardRectangle = keyboardFrame.cgRectValue
            let keyboardHeight = keyboardRectangle.height
            
            self.scrollView.contentOffset = CGPoint(x: 0, y: keyboardHeight)
            
            UIView.commitAnimations()
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        self.scrollView.frame = self.scrollView.frame.offsetBy(dx: 0.0, dy: 0)
    }
}

//MARK:- TextFieldDelegate

extension ChatVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
        return true
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        
        return true
    }
}

//MARK:- SelectedImagesVCDelegate

extension ChatVC : SelectedImagesVCDelegate {
    
    func sendButtonTapped(_ vc: SelectedImagesVC, imageList: [UIImage]) {
        
        self.images = imageList
        uploadImage ()
        tableview.reloadData()
    }
    
    //MARK:- upload image
    
    func uploadImage () {
        
        if Reachability.forInternetConnection().isReachable() {
            
            startAnimating()
            for (index,image) in images.enumerated() {
                
                var url = URL(string: NetworkURL.baseUrl)!
                
                url = url.appendingPathComponent(NetworkURL.sendImage)
                var urlRequest = URLRequest(url: url)
                urlRequest.httpMethod = "POST"
                
                let parameters = ["token": StaticContentFile.getToken(),
                                  "message_text": "Photos"]
                
                do {
                    urlRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                } catch {
                    print(error)
                }
                
                urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue(StaticContentFile.getToken(), forHTTPHeaderField: "authorization")
                
                Alamofire.upload(multipartFormData: { MultipartFormData in
                    
                    if let imgData = UIImageJPEGRepresentation(image, 0.5) {
                        
                        MultipartFormData.append(imgData, withName: "image", fileName: "image", mimeType: "image/jpg")
                    }
                },with: urlRequest,encodingCompletion: { encodingResult in
                    
                    switch encodingResult {
                        
                    case .success(let upload, _, _):
                        
                        upload.responseString { response in
                            
                            if index == self.images.count - 1 {
                                
                                self.stopAnimating()
                            }
                            if let JSON = response.result.value {
                                print("JSON: \(JSON)")
                            }
                        } case .failure(let error):
                            
                            if index == self.images.count - 1 {
                                
                                self.stopAnimating()
                            }
                            
                            print(error)
                    }
                })
            }} else {
            
            self.view.showToast(message: "Please check the internet connection")
        }
    }
}

extension ChatVC: DBManagerDelegate {
    
    func dbManager(_ statement: OpaquePointer!) {
        
        let message = RecentMessages()
        message.message_type = String(cString: sqlite3_column_text(statement, 1))
        message.message_text = String(cString: sqlite3_column_text(statement, 2))
        message.message_date = String(cString: sqlite3_column_text(statement, 3))
        message.image_url = String(cString: sqlite3_column_text(statement, 4))
        message.thumb_Url = String(cString: sqlite3_column_text(statement, 5))
        message.message_id = Int(sqlite3_column_int(statement, 6))
        message.senderId = String(cString: sqlite3_column_text(statement, 7))
        
        self.messageList.insert(message, at: 0)
        
        newMsgList.insert(message, at: 0)
    }
}



