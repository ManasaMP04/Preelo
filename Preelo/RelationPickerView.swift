//
//  RelationPickerView.swift
//  Preelo
//
//  Created by Manasa MP on 02/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import DXPopover

fileprivate let height = 30

protocol RelationPickerViewDelegate: class {
    
    func relationPickerView(_ view: RelationPickerView, text: String)
}

class RelationPickerView: UIView {

    fileprivate let pickerData    = ["Father", "Mother", "Sister", "Brother", "Grandmother", "Grandfather", "Gaurdian"]
    fileprivate let pickerView    = UIPickerView()
    
    weak var delegate : RelationPickerViewDelegate?
    
    //MARK:- Init
    
    init() {
        
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

        pickerView.dataSource = self
        pickerView.delegate   = self
    }
}

//MARK:- UIPickerViewDelegate & UIPickerViewDataSource

extension RelationPickerView: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        
        return pickerData.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        
        return pickerData[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        delegate?.relationPickerView(self, text: pickerData[row])
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        
        return CGFloat(height)
    }
}
