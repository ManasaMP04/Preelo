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
        
        StaticContentFile.setButtonFont(saveImage)
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
        
        if let name = msg.image_url as? UIImage {
            
            saveImageIntoLocal(name)
        } else if let name = msg.image_url as? String {
            
            if let imageUrl = URL(string: name) {
                
                do {
                    let data = try Data.init(contentsOf: imageUrl)
                    saveImageIntoLocal(UIImage.sd_image(with: data))
                    
                } catch let error as NSError {
                    print(error.debugDescription)
                }
            }}
    }
    
    fileprivate func saveImageIntoLocal(_ image: UIImage) {
        
        let fileManager = FileManager.default
        
        let paths = (NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as NSString).appendingPathComponent("preelo")
        let dateComponent = Date().stringWithDateFormat("MMddYYhhmm")
        let imagePath = paths.appendingFormat("/%@", dateComponent)
        
        if !fileManager.fileExists(atPath: paths) {
            
            try! fileManager.createDirectory(atPath: paths, withIntermediateDirectories: true, attributes: nil)
        }
        
        if !fileManager.fileExists(atPath: imagePath) {
            
            if let imageData = UIImageJPEGRepresentation(image, 1.0)  {
                
                fileManager.createFile(atPath: imagePath as String, contents: imageData, attributes: nil)
            }
        } else {
            
            self.view.showToast(message: "Image is already saved")
        }
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
        
        selectedIndex = (indexPath as NSIndexPath).row
        
        numberOfImages.text         = "\(selectedIndex + 1) of \(imageList.count)"
    }
}
