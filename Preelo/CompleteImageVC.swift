//
//  CompleteImageVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class CompleteImageVC: UIViewController {

    @IBOutlet fileprivate weak var numberOfImages    : UILabel!
    @IBOutlet fileprivate weak var collectionView    : UICollectionView!
    @IBOutlet fileprivate weak var customeNavigation : CustomNavigationBar!
    
    fileprivate var imageList = [String]()
    fileprivate var name = ""
    
    init (_ imageList: [String], name: String) {
        
        self.imageList = imageList
        self.name      = name
        super.init(nibName: "ChatVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

         collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
        customeNavigation.setTitle(name)
        customeNavigation.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
       
    }
}

extension CompleteImageVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension CompleteImageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as! ImageCell
        
        cell.showImage(imageList[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: StaticContentFile.screenWidth, height: StaticContentFile.screenHeight - 60)
    }
}
