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
    @IBOutlet weak var tableViewHeight: NSLayoutConstraint!
    @IBOutlet weak var deauthorizeButton: UIButton!
    @IBOutlet weak var cameraButton: UIButton!
    @IBOutlet weak var galleryButton: UIButton!
    
    fileprivate var messageList         = [RecentMessages]()
    fileprivate var activityIndicator   : UIActivityIndicatorView?
    fileprivate var footerActivityIndicator   : UIActivityIndicatorView?
    fileprivate var images              = [UIImage]()
    fileprivate var selection:Selection = .camera
    fileprivate var isPatient_DocFlow   = false
    fileprivate var parentOrDocId      = 0
    fileprivate var name                = ""
    
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
        name =  StaticContentFile.isDoctorLogIn() ? "\(channelDetail.parentname) - \(channelDetail.relationship)" : channelDetail.doctorname
        
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
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    func changeAuthRequestToPending() {
        
        channelDetail.auth_status = "p"
        showTheAuthRequestButton()
        StaticContentFile.updateChannelDetail(channelDetail)
        self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: true)
    }
}

//MARK:- IBActions

extension ChatVC {
    
    @IBAction func tapGesture(_ sender: Any) {
        
        view.endEditing(true)
    }
    
    @IBAction func requestAuthorisationButtonTapped(_ sender: Any) {
        
        if StaticContentFile.isDoctorLogIn(), let _ = channelDetail {
            
            callApiToAuthorize()
        } else {
            
            let vc = DisclaimerVC(channelDetail)
            navigationController?.pushViewController(vc, animated: true)
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
        
        self.view.isUserInteractionEnabled = false
        self.activityIndicator?.startAnimating()
        Alamofire.request(AuthorizationRequestListRouter.deAuthorize(channelDetail.patientId, channelDetail.parentId))
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    self.showAuthorizeButton(true)
                    self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: false)
                } else if let result = response.result.value {
                    
                    self.view.showToast(message: result.message)
                } else {
                    
                    self.view.showToast(message: "Please try again later")
                }}
    }
    
    fileprivate func showAuthorizeButton(_ show: Bool) {
        
        self.requestAuthorizationViewHeight.constant =  show ? 150 : 0
        self.tableViewHeight.constant = StaticContentFile.screenHeight - 170 - self.requestAuthorizationViewHeight.constant
        self.deauthorizeButton.isHidden = !show
        self.authorizationView.isHidden = show
        self.channelDetail.auth_status =  show ? "f" : "t"
        StaticContentFile.updateChannelDetail(self.channelDetail)
    }
}

//MARK:- Private Methods

extension ChatVC {
    
    fileprivate func callApiToAuthorize() {
        
        self.activityIndicator?.startAnimating()
        Alamofire.request(AuthorizationRequestListRouter.authorize(channelDetail.patientId, channelDetail.parentId))
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                self.view.isUserInteractionEnabled = true
                self.activityIndicator?.stopAnimating()
                
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
        
        deauthorizeButton.isHidden = true
        messageList.removeAll()
        
        activityIndicator = UIActivityIndicatorView.activityIndicatorToView(self.view)
        createFooter ()
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        messageTF.delegate = self
        
        StaticContentFile.setButtonFont(requestAuthButton)
        
        showTheAuthRequestButton()
        customeNavigation.setTitle(name)
        customeNavigation.delegate = self
        tableview.register(UINib(nibName: "FromMessageCell", bundle: nil), forCellReuseIdentifier: FromMessageCell.cellId)
        tableview.register(UINib(nibName: "ToMessageCell", bundle: nil), forCellReuseIdentifier: ToMessageCell.cellId)
        tableview.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImageListCell.cellId)
        
        tableview.estimatedRowHeight = 20
        tableview.rowHeight  = UITableViewAutomaticDimension
        
        self.view.isUserInteractionEnabled = false
        activityIndicator?.startAnimating()
        callApiToGetMessages()
    }
    
    func refresh(_ scrollDirectlyToBottom: Bool = false) {
        
        if  !isPatient_DocFlow {
            
            if channelDetail.lastMsgId == -1 {
                
                self.view.isUserInteractionEnabled = false
                activityIndicator?.startAnimating()
                callApiToGetMessages()
            } else if channelDetail.unread_count > 0 {
                
                self.messageList = channelDetail.recent_message
                
                if scrollDirectlyToBottom {
                    
                    callApiToGetMessages()
                    self.messageList.removeLast()
                } else {
                    
                    self.tableview.reloadData()
                    scrollToButtom()
                    footerActivityIndicator?.startAnimating()
                    callApiToGetMessages()
                    self.messageList.removeLast()
                }
            } else {
                
                self.messageList = channelDetail.recent_message
                self.tableview.reloadData()
                self.view.layoutIfNeeded()
                scrollToButtom()
            }
        }
        
        showTheAuthRequestButton()
    }
    
    fileprivate func showAuthRequestTitle(_ title: String) {
        
        let style = NSMutableParagraphStyle()
        style.lineSpacing = 5
        let attributes = [NSParagraphStyleAttributeName : style, NSFontAttributeName : UIFont(name: "Ubuntu-Light", size: 15)!, NSForegroundColorAttributeName: UIColor.colorWithHex(0x939598)]
        authRequestTitle.attributedText = NSAttributedString(string:title, attributes:attributes)
    }
    
    fileprivate func showTheAuthRequestButton() {
        
        if !StaticContentFile.isDoctorLogIn(), channelDetail.auth_status.lowercased() != "t" {
            
            showAuthRequestTitle("You are not authorized to send messages. Please submit the Authorization Button to request authorization to send messages")
            requestAuthorizationViewHeight.constant = 150
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
            }
        } else {
            
            requestAuthorizationViewHeight.constant = channelDetail.auth_status.lowercased() != "t" ? 144 : 0
            authorizationView.isHidden = channelDetail.auth_status.lowercased() == "t"
            
            if StaticContentFile.isDoctorLogIn(), channelDetail.auth_status.lowercased() != "t" {
                
                showAuthRequestTitle("This user is not authorised to send messages. Please click on the authorise button to allow the user to send messages")
                requestAuthButton.setTitle("AUTHORIZE PARENT", for: .normal)
            }
            
            deauthorizeButton.isHidden = !(StaticContentFile.isDoctorLogIn() && channelDetail.auth_status.lowercased() == "t")
            
            cameraButton.setImage(UIImage(named: "camera-Active"), for: .normal)
            galleryButton.setImage(UIImage(named: "Gallery-Icon Active"), for: .normal)
        }
        
        tableViewHeight.constant = StaticContentFile.screenHeight - 170 - requestAuthorizationViewHeight.constant
    }
    
    fileprivate func scrollToButtom() {
        
        self.view.layoutIfNeeded()
        let indexPath = IndexPath(row: self.messageList.count - 1, section: 0)
        self.tableview.scrollToRow(at: indexPath, at: .bottom, animated: true)
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
        
        messageTF.text = ""
        self.view.endEditing(true)
        Alamofire.request(SendTextMessageRouter.post(text))
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                if let result = response.result.value, result.status == "SUCCESS" {} else {
                    
                    self.view.showToast(message: "Send Message Failed")
                } } .responseString { (string) in
                    
                    print(string)
        }
    }
    
    fileprivate func callApiToGetMessages() {
        
        Alamofire.request(SendTextMessageRouter.get(channelDetail))
            .responseArray(keyPath: "data") {(response: DataResponse<[RecentMessages]>) in
                
                self.activityIndicator?.stopAnimating()
                self.footerActivityIndicator?.stopAnimating()
                self.view.isUserInteractionEnabled = true
                
                if let result = response.result.value {
                    
                    self.callapiToMarkedRead()
                    
                    for msg in result {
                        
                        StaticContentFile.saveMessage(msg, channelDetail: self.channelDetail)
                        self.channelDetail.lastMsgId = msg.message_id
                    }
                    self.messageList.removeAll()
                    if let data = StaticContentFile.getChannelDetail(self.channelDetail) {
                        
                        self.messageList = data.recent_message
                    }
                    
                    self.tableview.reloadData()
                    self.delegate?.chatVCDelegateToRefresh(self, isAuthRequest: false)
                    self.scrollToButtom()
                } else {
                    
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

extension ChatVC: UITableViewDelegate, UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return messageList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let message = messageList[indexPath.row]
        
        if message.message_type.lowercased() != "simple" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.cellId, for: indexPath) as! ImageListCell
            cell.delegate = self
            cell.showImages(message, name: name)
            
            return cell
            
        }
        
        let str = message.senderId.lowercased()
        
        if str == "you" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FromMessageCell.cellId, for: indexPath) as! FromMessageCell
            cell.showMessage(message)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ToMessageCell.cellId, for: indexPath) as! ToMessageCell
            
            cell.showMessage(message, name: name)
            
            return cell
        }
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        
        cell.backgroundColor = UIColor.colorWithHex(0xFAFAFA)
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
        
        if let info = (notification as NSNotification).userInfo {
            
            let dictionary = info as NSDictionary
            
            let kbSize = (dictionary.object(forKey: UIKeyboardFrameBeginUserInfoKey)! as AnyObject).cgRectValue.size
            
            tableViewHeight.constant = StaticContentFile.screenHeight - kbSize.height
            
            if messageList.count > 0 {
                
                tableview.scrollToRow(at: IndexPath(row: messageList.count-1, section: 0), at: .bottom, animated: true)
                
                view.layoutIfNeeded()
            }
            
            self.scrollViewBottomInset = kbSize.height - 40
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        tableViewHeight.constant = StaticContentFile.screenHeight - 170 - requestAuthorizationViewHeight.constant
        
        self.scrollViewBottomInset = -40
    }
}

//MARK:- TextFieldDelegate

extension ChatVC : UITextFieldDelegate {
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        
        view.endEditing(true)
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
        
        self.activityIndicator?.startAnimating()
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
                            
                            self.activityIndicator?.stopAnimating()
                        }
                        if let JSON = response.result.value {
                            print("JSON: \(JSON)")
                        }
                    } case .failure(let error):
                        
                        self.activityIndicator?.stopAnimating()
                        print(error)
                }
            })
        }
    }
}


