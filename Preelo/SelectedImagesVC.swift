//
//  SelectedImagesVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit

protocol SelectedImagesVCDelegate: class {
    
    func sendButtonTapped(_ vc: SelectedImagesVC, imageList: [UIImage])
}


class SelectedImagesVC: UIViewController {
    
    @IBOutlet fileprivate weak var customNavigation : CustomNavigationBar!
    @IBOutlet fileprivate weak var imageView        : UIImageView!
    @IBOutlet fileprivate weak var collectionView   : UICollectionView!
    @IBOutlet fileprivate weak var selectImageButton: UIButton!
    @IBOutlet fileprivate weak var collectionViewHeight: NSLayoutConstraint!
    
    weak var delegate: SelectedImagesVCDelegate?
    fileprivate var imageList = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        customNavigation.delegate = self
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        delegate?.sendButtonTapped(self, imageList: imageList)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.allowsEditing = false
        imagePicker.sourceType = .savedPhotosAlbum
        imagePicker.sele
        present(imagePicker, animated: true, completion: nil)
    }
}

extension SelectedImagesVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension SelectedImagesVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageList.append(image)
        }
        
        collectionViewHeight.constant = imageList.count > 1 ? 45 : 0
        collectionView.reloadData()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        
        picker.dismiss(animated: true, completion: nil)
    }
}

extension SelectedImagesVC: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return imageList.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ImageCell.cellId, for: indexPath) as! ImageCell
        
        cell.showImageWithName(imageList[indexPath.row])
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        imageView.image = imageList[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 45, height: 45)
    }
}

