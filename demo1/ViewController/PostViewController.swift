//
//  PostViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/24.
//

import UIKit
import Photos
import PhotosUI
import BSImagePicker
import FirebaseAuth
class PostViewController: UIViewController {
    
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var textView: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var profileImageView: UIImageView!
    let safeEmail = DatabaseManager.safeString(for: UserDefaults.standard.string(forKey: "email")!)
    var selectedAssets = [PHAsset]()
    var images = [UIImage]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        collectionSetup()
    }
    
    private func setup(){
        let name = UserDefaults.standard.string(forKey: "name")
        nameLabel.text = name
        StorageManager.shared.getUIImageData(path: "profile/\(safeEmail)_profile_picture.png", for: profileImageView)
    }
    
    @IBAction func camera(_ sender: Any) {
        runImagePicker()
    }
    
    /*post */
    @IBAction func sentPost(_ sender: Any) {
        // generate unique postID
        let time = NSDate().timeIntervalSince1970
        let profileImgName = "\(safeEmail)_profile_picture.png"
        let safeID = DatabaseManager.safeString(for: "\(safeEmail)_\(String(time))")
        let post = Post(postID: safeID, profileImage: profileImgName, owner: nameLabel.text!, txt: textView.text, image: images)
        
        DatabaseManager.shared.insertPost(with: post, completion: { success in
            guard success == true else { print("failed to insert post"); return}
        })
        textView.text = ""
        images = [UIImage]()
        self.dismiss(animated: true)
    }

    func collectionSetup() -> Void{
        collectionView.frame = CGRect(x: 0,y: 0,width: view.frame.width,height: 0)
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 20, left: 0, bottom: 10, right: 0)
        layout.itemSize = CGSize(width: collectionView.width/3-20, height: collectionView.width/3-20)
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 0
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.collectionViewLayout = layout
        collectionView.register(PostCollectionViewCell.nib(), forCellWithReuseIdentifier: PostCollectionViewCell.identifier)
    }
    
    func runImagePicker() {
        let imagePicker = ImagePickerController()
        
        presentImagePicker(imagePicker, select: { (asset: PHAsset) -> Void in
            // User selected an asset. Do something with it. Perhaps begin processing/upload?
            
        }, deselect: { (asset: PHAsset) -> Void in
            // User deselected an asset. Cancel whatever you did when asset was selected.
        }, cancel: { (assets:[PHAsset]) -> Void in
            // User canceled selection.
        }, finish: { (assets: [PHAsset]) -> Void in
            // User finished selection assets.
            
            for i in 0..<assets.count{
                self.selectedAssets.append(assets[i])
            }
            self.convertAssetsToImg()
            
            self.collectionView.reloadData()
        }, completion: nil)
    }
    
    func convertAssetsToImg() -> Void{
        if selectedAssets.count != 0{
            
            for i in 0..<selectedAssets.count{
                
                // reciving request to convert assets to images
                let manager = PHImageManager.default()
                let option = PHImageRequestOptions()
                var thumbnail = UIImage()
                
                option.isSynchronous = true
                manager.requestImage(for: selectedAssets[i], targetSize: .zero, contentMode: .aspectFill, options: option, resultHandler: {(result, info)->Void in thumbnail = result!
                })
                
                let data = thumbnail.jpegData(compressionQuality: 0.7)
                let newImage = UIImage(data: data!)
                if images.contains(newImage!){
                    print("image exist")
                }
                else{
                    self.images.append(newImage! as UIImage)
                    
                }
            }
            
            selectedAssets = []
            
            //The button is enabled if there is images
            
            
            
        }
        
        print("complete photo array \(self.images)")
    }
    
    
    
    
}

extension PostViewController: UICollectionViewDelegate{
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        collectionView.deselectItem(at: indexPath, animated: true)
        print("delete tapped image")
        images.remove(at: indexPath.row)
        
        self.collectionView.reloadData()
    }
}

extension PostViewController: UICollectionViewDataSource{
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: PostCollectionViewCell.identifier, for: indexPath) as! PostCollectionViewCell
        
        cell.configure(with: images[indexPath.row])
        
        return cell
    }
}

extension PostViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate{
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        guard let image = info[UIImagePickerController.InfoKey.originalImage] as? UIImage else {return}
        images.append(image)
        collectionView.reloadData()
        picker.dismiss(animated: true, completion: nil)
        
    }
}
