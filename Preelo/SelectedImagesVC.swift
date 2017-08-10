//
//  SelectedImagesVC.swift
//  Preelo
//
//  Created by Manasa MP on 14/05/17.
//  Copyright © 2017 Manasa MP. All rights reserved.
//

import UIKit
import BSImagePicker
import Photos
import Alamofire

protocol SelectedImagesVCDelegate: class {
    
    func sendButtonTapped(_ vc: SelectedImagesVC, imageList: [UIImage])
}

class SelectedImagesVC: UIViewController {
    
    @IBOutlet weak var scrollview: UIScrollView!
    @IBOutlet fileprivate weak var customNavigation : CustomNavigationBar!
    @IBOutlet fileprivate weak var imageView        : UIImageView!
    @IBOutlet fileprivate weak var collectionView   : UICollectionView!
    @IBOutlet fileprivate weak var selectImageButton: UIButton!
    @IBOutlet fileprivate weak var collectionViewHeight: NSLayoutConstraint!
    @IBOutlet fileprivate weak var deleteButton         : UIButton!
    
    weak var delegate: SelectedImagesVCDelegate?
    fileprivate var imageList = [UIImage]()
    fileprivate var isCamera  = true
    fileprivate var selectedIndex =  IndexPath(row: 0, section: 0)
    
    init(_ isCamera: Bool = true, image: UIImage) {
        
        self.isCamera = isCamera
        self.imageList.append(image)
        super.init(nibName: "SelectedImagesVC", bundle: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        scrollview.minimumZoomScale = 1.0
        scrollview.maximumZoomScale = 6.0
        scrollview.delegate = self
        
        customNavigation.setTitle("Selected Images")
        customNavigation.delegate = self
        isCamera ? selectImageButton.setImage(UIImage(named: "Camera"), for: .normal) : selectImageButton.setImage(UIImage(named: "Gallery"), for: .normal)
        collectionViewHeight.constant = 0
        imageView.image = imageList[0]
        collectionView.register(UINib(nibName: "ImageCell", bundle: nil), forCellWithReuseIdentifier: ImageCell.cellId)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        
    }
    
    @IBAction func deleteButtonTapped(_ sender: Any) {
        
        if imageList.count > 0 {
            
            imageView.image = imageList[selectedIndex.row + 1]
            imageList.remove(at: selectedIndex.row)
            collectionView.deleteItems(at: [selectedIndex])
            
             deleteButton.isHidden = imageList.count == 0
        }
    }
    
    @IBAction func sendButtonTapped(_ sender: Any) {
        
        delegate?.sendButtonTapped(self, imageList: imageList)
        _ = navigationController?.popViewController(animated: true)
    }
    
    @IBAction func selectImageButtonTapped(_ sender: Any) {
        
        if isCamera {
            
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.allowsEditing = false
            imagePicker.sourceType = isCamera ?  .camera : .savedPhotosAlbum
            present(imagePicker, animated: true, completion: nil)
        } else {
            
            let vc = BSImagePickerViewController()
            vc.maxNumberOfSelections = 9
            
            bs_presentImagePickerController(vc, animated: true,
                                            select: { (asset: PHAsset) -> Void in
                                                
            }, deselect: { (asset: PHAsset) -> Void in
                
            }, cancel: { (assets: [PHAsset]) -> Void in
                
            }, finish: { (assets: [PHAsset]) -> Void in
                
                for element in assets {
                    
                    if element.mediaType == .image {
                        
                        let requestImageOption = PHImageRequestOptions()
                        requestImageOption.deliveryMode = PHImageRequestOptionsDeliveryMode.highQualityFormat
                        
                        let manager = PHImageManager.default()
                        
                        manager.requestImage(for: element, targetSize: PHImageManagerMaximumSize, contentMode:PHImageContentMode.default, options: requestImageOption) { (image:UIImage?, _) in
                            
                            if let img = image {
                                self.imageList.append(img)
                                
                                self.collectionViewHeight.constant = self.imageList.count > 0 ? 45 :  0
                                self.deleteButton.isHidden = self.imageList.count == 0
                                self.collectionView.reloadData()
                                
                            }}}}
                
            }, completion: nil)
        }
    }
}

extension SelectedImagesVC: CustomNavigationBarDelegate {
    
    func tappedBackButtonFromVC(_ customView: CustomNavigationBar) {
        
        _ = navigationController?.popViewController(animated: true)
    }
}

extension SelectedImagesVC: UIScrollViewDelegate {
    
    func viewForZooming(in scrollView: UIScrollView) -> UIView? {
        
        return imageView
    }
}

extension SelectedImagesVC: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [
        String : Any]) {
        
        if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            
            imageView.image = image
            
            if isCamera {
                
                imageList.removeAll()
                imageList.append(image)
            }
            
            picker.dismiss(animated: true, completion: nil)
        }
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
        
        selectedIndex = indexPath
        imageView.image = imageList[indexPath.row]
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: 45, height: 45)
    }
    
}

