//
//  RelationPickerView.swift
//  Preelo
//
//  Created by Manasa MP on 02/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import DXPopover

fileprivate let height = 40

protocol RelationPickerViewDelegate: class {
    
    func relationPickerView(_ view: RelationPickerView, text: String)
}

class RelationPickerView: UIView {

    fileprivate var pickerData    = [String]()
    fileprivate let pickerView    = UITableView()
    
    weak var delegate : RelationPickerViewDelegate?
    
    //MARK:- Init
    
    init(_ pickerData: [String]) {
        
        self.pickerData = pickerData
        super.init(frame: CGRect(x: 0, y: 0, width: Int(StaticContentFile.screenWidth - 40), height: pickerData.count*height))
        
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        
        super.init(coder: aDecoder)
        
        setup()
    }
    
    fileprivate func setup() {
    
        self.addSubview(pickerView)
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        AutoLayoutHelper.addTrailingSpaceConstraintToView(pickerView, trailingSpace: 0)
        AutoLayoutHelper.addLeadingSpaceConstraintToView(pickerView, leadingSpace: 0)
        AutoLayoutHelper.addTopSpaceConstraintToView(pickerView, topSpace: 0)
        AutoLayoutHelper.addBottomSpaceConstraintToView(pickerView, bottomSpace: 0)
        pickerView.tableFooterView = UIView()
        pickerView.dataSource = self
        pickerView.delegate   = self
    }
}

//MARK:- UIPickerViewDelegate & UIPickerViewDataSource

extension RelationPickerView: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return pickerData.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        
        return CGFloat(height)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell.init(style: .default, reuseIdentifier: "cell")
        cell.textLabel?.text = pickerData[indexPath.row]
        cell.textLabel?.textAlignment = .center
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
         delegate?.relationPickerView(self, text: pickerData[indexPath.row])
    }
}
