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
    
    enum Selection:Int {
        
        case camera = 0
        case gallery
    }
    
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
    fileprivate var channelDetail       : ChannelDetail!
    fileprivate var images              = [UIImage]()
    fileprivate var selection:Selection = .camera
    fileprivate var isPatient_DocFlow   = false
    fileprivate var patientOrDocId      = 0
    fileprivate var name                = ""
    
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
        name =  StaticContentFile.isDoctorLogIn() ? channelDetail.patientname : channelDetail.doctorname
        
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    init (_ Id: Int, name: String) {
        
        self.patientOrDocId = Id
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
}

//MARK:- IBActions

extension ChatVC {
    
    @IBAction func tapGesture(_ sender: Any) {
        
        view.endEditing(true)
    }
    
    @IBAction func requestAuthorisationButtonTapped(_ sender: Any) {
        
        let vc = DisclaimerVC(channelDetail)
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        if let text = messageTF.text, text.characters.count > 0 {
            
            let recentMessage = RecentMessages("text", text: text, senderId: StaticContentFile.getId())
            messageList.append(recentMessage)
            tableview.reloadData()
            
            var id = patientOrDocId
            
            if !isPatient_DocFlow {
                
                id = StaticContentFile.isDoctorLogIn() ? channelDetail.patientId : channelDetail.doctorId
            }
            
            StaticContentFile.saveMessage(recentMessage, id: id)
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
}

//MARK:- Private Methods

extension ChatVC {
    
    fileprivate func setup() {
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWasShown(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self,
                                               selector: #selector(keyboardWillHide(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        messageTF.delegate = self
        
        StaticContentFile.setButtonFont(requestAuthButton)
        
        requestAuthorizationViewHeight.constant = 0
        authorizationView.isHidden = true
        toolbarView.isUserInteractionEnabled = true
        
        customeNavigation.setTitle(name)
        
        if  !isPatient_DocFlow {
            
            self.messageList = channelDetail.recent_message
            
            if let recentMessage = channelDetail.recent_message.last, (channelDetail.unread_count > 0 || channelDetail.isFirstTime) {
                
                callApiToGetMessages(recentMessage.message_id)
            }
        }
        
        self.tableview.reloadData()
        
        if !StaticContentFile.isDoctorLogIn(), !channelDetail.auth_status {
            
            requestAuthorizationViewHeight.constant = 144
            authorizationView.isHidden = false
            //toolbarView.isUserInteractionEnabled = false
        }
        
        customeNavigation.delegate = self
        tableview.register(UINib(nibName: "FromMessageCell", bundle: nil), forCellReuseIdentifier: FromMessageCell.cellId)
        tableview.register(UINib(nibName: "ToMessageCell", bundle: nil), forCellReuseIdentifier: ToMessageCell.cellId)
        tableview.register(UINib(nibName: "ImageListCell", bundle: nil), forCellReuseIdentifier: ImageListCell.cellId)
        
        tableview.estimatedRowHeight = 20
        tableview.rowHeight  = UITableViewAutomaticDimension
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
                
                if let _ = response.result.value {
                    
                } else {
                    
                    self.view.showToast(message: "Send Message Failed")
                } } .responseString { (string) in
                    
                    print(string)
        }
    }
    
    fileprivate func callApiToGetMessages(_ messageId: Int) {
        
        Alamofire.request(SendTextMessageRouter.get(channelDetail, messageId))
            .responseArray(keyPath: "data") {(response: DataResponse<[RecentMessages]>) in
                
                let plistStorageManager = PlistManager()
                
                plistStorageManager.deleteObject(forKey: "\(self.channelDetail.channel_id)", inFile: .message)
                
                if let result = response.result.value {
                    
                    self.callapiToMarkedRead()
                    self.messageList = result
                    
                    for msg in result {
                        
                        StaticContentFile.saveMessage(msg, id: self.channelDetail.patientId)
                    }
                    
                    self.tableview.reloadData()
                    self.activityIndicator?.stopAnimating()
                    
                    if let vc = self.navigationController?.viewControllerWithClass(MessageVC.self) as? MessageVC {
                        
                        vc.refresh()
                    }
                } else {
                    
                    self.activityIndicator?.stopAnimating()
                    self.view.showToast(message: "Please try again something went wrong")
                }}
    }
    
    fileprivate func callapiToMarkedRead() {
        
        Alamofire.request(SendTextMessageRouter.post_msgRead(channelDetail.channel_id))
            .responseObject { (response: DataResponse<SuccessStatus>) in
                
                if let result = response.result.value, result.status == "SUCCESS" {
                    
                    
                }}
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
        
        if message.message_type == "IMAGE" {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ImageListCell.cellId, for: indexPath) as! ImageListCell
            cell.delegate = self
            cell.showImages(message)
            
            return cell
            
        }
        
        if message.senderId == StaticContentFile.getId() {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: FromMessageCell.cellId, for: indexPath) as! FromMessageCell
            cell.showMessage(message)
            
            return cell
        } else {
            
            let cell = tableView.dequeueReusableCell(withIdentifier: ToMessageCell.cellId, for: indexPath) as! ToMessageCell
            
            cell.showMessage(message, name: name)
            
            return cell
        }
    }
}

extension ChatVC: ImageListCellDelegate {
    
    func imageListCell(_ cell: ImageListCell, imageList: [UIImage], index: Int) {
        
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
            
            self.scrollViewBottomInset = kbSize.height + 10
        }
    }
    
    @objc fileprivate func keyboardWillHide(_ notification: Notification) {
        
        self.scrollViewBottomInset = 0
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

        let recentMessage = RecentMessages("IMAGE", text: "Photos", senderId: StaticContentFile.getId())
        recentMessage.image_url = imageList
        messageList.append(recentMessage)
        tableview.reloadData()
        
        var id = patientOrDocId
        
        if !isPatient_DocFlow {
            
            id = StaticContentFile.isDoctorLogIn() ? channelDetail.patientId : channelDetail.doctorId
        }
        
        StaticContentFile.saveMessage(recentMessage, id: id)
        tableview.reloadData()
    }
    
    //MARK:- upload image
    
    func uploadImage () {
        
        var url = URL(string: NetworkURL.baseUrl)!
        
        url = url.appendingPathComponent(NetworkURL.sendText)
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
        urlRequest.setValue("Authorization", forHTTPHeaderField: StaticContentFile.getToken())
        
        Alamofire.upload(multipartFormData: { MultipartFormData in
            
            for image in self.images {
                
                if let imgData = UIImageJPEGRepresentation(image, 0.2) {
                    
                    MultipartFormData.append(imgData, withName: "image", fileName: "image", mimeType: "image/jpg")
                }
            }
        },with: urlRequest,encodingCompletion: { encodingResult in
            
            switch encodingResult {
                
            case .success(let upload, _, _):
                
                upload.responseJSON { response in
                    
                    if let info = response.result.value as? Dictionary<String, AnyObject> {
                        
                        if let links = info["links"] as? Dictionary<String, AnyObject> {
                            
                            if let imgLink = links["image_link"] as? String {
                                print("LINK: \(imgLink)")
                            }
                        }
                    }
                    
                } case .failure(let error):
                    print(error)
            }
        })
    }
}


