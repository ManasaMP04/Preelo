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
    
    fileprivate var imageList = [RecentMessages]()
    fileprivate var name = ""
    
    init (_ imageList: [RecentMessages], name: String) {
        
        self.imageList = imageList
        self.name      = name
        super.init(nibName: "CompleteImageVC", bundle: nil)
    }
    
    required init?(coder aDecoder:NSCoder) {
        super.init(coder: aDecoder)
    
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

         collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
        customeNavigation.setTitle(name)
        customeNavigation.delegate = self
        numberOfImages.text         = "\(1) of \(imageList.count)"
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
        
        cell.showImage(imageList[indexPath.row], showFullImage: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: StaticContentFile.screenWidth, height: StaticContentFile.screenHeight - 100)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        
        let selectedIndex = (indexPath as NSIndexPath).row
        numberOfImages.text         = "\(selectedIndex + 1) of \(imageList.count)"
    }
}
