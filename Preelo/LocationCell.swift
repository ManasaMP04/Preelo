//
//  LocationCell.swift
//  Preelo
//
//  Created by Manasa MP on 03/09/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class LocationCell: UITableViewCell {
    
    @IBOutlet fileprivate weak var tableviewHeight      : NSLayoutConstraint!
    @IBOutlet fileprivate weak var tableview            : UITableView!
    
    fileprivate var locationDetail = [Address]()
    static let cellId = "LocationCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        tableview.delegate = self
        tableview.dataSource = self
        tableview.register(UINib(nibName: "ParentDetailCell", bundle: nil), forCellReuseIdentifier: ParentDetailCell.cellId)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        
    }
    
    func showLocation(_ locationDetail : [Address]) {
        
        self.locationDetail.removeAll()
        tableview.reloadData()
        self.locationDetail = locationDetail
        tableview.reloadData()
        self.layoutIfNeeded()
        tableviewHeight.constant = tableview.contentSize.height
    }
}

//MARK:- UITableViewDelegate, UITableViewDataSource

extension LocationCell: UITableViewDelegate, UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int  {
        
        return locationDetail.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        let detail = locationDetail[section]
        
        return detail.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: ParentDetailCell.cellId, for: indexPath) as! ParentDetailCell
        
        let detail = locationDetail[indexPath.section]
        
        if  indexPath.row == 0 {
            
            let address = "\(detail.address1) \n \(detail.address2) \(detail.city) \(detail.state) - \(detail.zip) "
            cell.showParentName(address , showImage: false, showEdit: false, image: nil, showLocation: false, font: UIFont(name: "Ubuntu-Medium", size: 12)!, color: UIColor.colorWithHex(0x414042), showInitial: true, showSeparator: indexPath.row+1 == detail.count, separatorLeadingSpace: 68)
        } else if indexPath.row <= detail.phone.count {
            
            let phone = detail.phone [indexPath.row - 1]
            cell.showParentName(phone, showImage: false, showEdit: true, image: "phone", showLocation: false, font: UIFont(name: "Ubuntu-Light", size: 14)!, color: UIColor.colorWithHex(0x414042), showInitial: true, showSeparator: indexPath.row+1 == detail.count, separatorLeadingSpace: 68)
        } else {
            
            cell.showParentName(detail.fax, showImage: false, showEdit: false, image: nil, showLocation: false, font: UIFont(name: "Ubuntu-Light", size: 14)!, color: UIColor.colorWithHex(0x414042), showInitial: true, showSeparator: indexPath.row+1 == detail.count, separatorLeadingSpace: 70)
        }
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return 50
    }
}
