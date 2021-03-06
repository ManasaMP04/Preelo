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
    @IBOutlet weak var saveImage: UIButton!
    
    fileprivate var imageList = [RecentMessages]()
    fileprivate var name = ""
    fileprivate var selectedIndex = 0
    
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
        
        StaticContentFile.setButtonFont(saveImage, shadowNeeded: false)
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
        customeNavigation.setTitle(name)
        customeNavigation.delegate = self
        numberOfImages.text         = "\(1) of \(imageList.count)"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func saveImageButtonTapped(_ sender: Any) {
        
        let msg = imageList[selectedIndex]
        
        if let imageUrl = URL(string: msg.image_url) {
            
            let imageView = UIImageView()
            imageView.sd_setImage(with:imageUrl) { (img, error, cacheType, url) in
                
                if let image = img {
                    
                    CustomPhotoAlbum.sharedInstance.save(image: image)
                    self.view.showToast(message: "Saved Successfully")
                }
            }}
    }
}

extension CompleteImageVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension CompleteImageVC : ImageCellDelegate {
    
    func imageCell(_ cell: ImageCell, enabled: Bool) {
        
        if !enabled {
            
            self.view.showToast(message: "Something went wrong. We are unable to display this image at this time. Please contact system administrator")
        }
        
        saveImage.isUserInteractionEnabled = enabled
    }
}

extension CompleteImageVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as! ImageCell
        cell.delegate = self
        cell.showImage(imageList[indexPath.row], showFullImage: true)
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: StaticContentFile.screenWidth, height: StaticContentFile.screenHeight - 100)
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        
        guard let indexPath = collectionView.indexPathsForVisibleItems.first else { return }
        
        selectedIndex = (indexPath as NSIndexPath).row
        
        numberOfImages.text         = "\(selectedIndex + 1) of \(imageList.count)"
    }
}
