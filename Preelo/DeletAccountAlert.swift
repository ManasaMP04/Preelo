//
//  DeletAccountAlert.swift
//  Preelo
//
//  Created by vmoksha mobility on 13/07/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import Alamofire

protocol DeletAccountAlertDelegate: class {
    
    func tappedYesButton(_ vc: DeletAccountAlert, index:Int?)
}

class DeletAccountAlert: UIViewController {
    
    @IBOutlet fileprivate weak var yesButton            : UIButton!
    @IBOutlet fileprivate weak var noButton             : UIButton!
    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet weak var notificationDetail: UILabel!
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var notificationTitle: UILabel!
    
    fileprivate var titleValue = ""
    fileprivate var descriptionString: NSAttributedString?
    fileprivate var notificationString = ""
    fileprivate var image = ""
    fileprivate var index : Int?
    
    weak var delegate : DeletAccountAlertDelegate?
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
    init (_ title: String, description: NSAttributedString, notificationTitle: String, image: String, index: Int? = nil) {
        
        self.titleValue = title
        self.descriptionString = description
        self.notificationString = notificationTitle
        self.image = image
        self.index = index
        
        super.init(nibName: "DeletAccountAlert", bundle: nil)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.setup()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    
    @IBAction func yssButtonAction(_ sender: Any) {
        
        delegate?.tappedYesButton(self, index: index)
    }
    
    @IBAction func noButtonAction(_ sender: Any) {
        
        self.dismiss(animated: true, completion: nil)
    }
}


extension DeletAccountAlert{
    
    fileprivate func setup() {
        
        StaticContentFile.setButtonFont(yesButton, backgroundColorNeeed: true, borderNeeded: false, shadowNeeded:  false)
        StaticContentFile.setButtonFont(noButton, backgroundColorNeeed: false, borderNeeded: true, shadowNeeded:  false)
        
        yesButton.layer.cornerRadius = yesButton.frame.height / 1.9
        noButton.layer.cornerRadius  = noButton.frame.height / 1.9
        customNavigationBar.setTitle(titleValue)
        self.notificationTitle.text = notificationString
        notificationDetail.attributedText = descriptionString
        imageView.image = UIImage(named: image)
        customNavigationBar.delegate = self
    }
}

extension DeletAccountAlert: CustomNavigationBarDelegate  {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar){
        
        self.dismiss(animated: true, completion: nil)
    }
}




