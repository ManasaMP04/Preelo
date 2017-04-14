//
//  DisplayPhotoVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/04/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

class DisplayPhotoVC: UIViewController {

    @IBOutlet fileprivate weak var customNavigationBar  : CustomNavigationBar!
    @IBOutlet fileprivate weak var numberOfPhotos       : UILabel!
    @IBOutlet fileprivate weak var collectionView       : UICollectionView!
    
    fileprivate var photos = [String]()
    
    required init(_ photos: [String]) {
        
        self.photos = photos
        super.init(nibName: "AddPatientVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
}

//MARK:- UICollectionViewDelegate, UICollectionViewDataSource

extension DisplayPhotoVC: UICollectionViewDelegate, UICollectionViewDataSource {

    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return photos.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "", for: indexPath)
        
        if let imageView = cell.viewWithTag(10) as? UIImageView {
        
            imageView.image = UIImage(named: photos[indexPath.row])
        }
        
        return cell
    }
}
