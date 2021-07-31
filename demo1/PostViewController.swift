//
//  PostViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/24.
//

import UIKit
import BSImagePicker
import Photos
import PhotosUI
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
//        fetchImage(imageView: profileImageView)
        // profile image
        StorageManager.shared.getUIImageData(path: "image/\(safeEmail)_profile_picture.png", for: profileImageView)
    }
    
    @IBAction func camera(_ sender: Any) {
        runPicker()
    }
    
    
    //MARK: fix
    private func fetchImage(imageView: UIImageView) {
        let fileName = "\(safeEmail)_profile_picture.png"
        UserDefaults.standard.setValue(fileName, forKey: "profile_picture_url")
        let path = "image/"+fileName
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
                self?.downloadProfileImage(imageView: imageView, url: url)
            case .failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
    }
    private func downloadProfileImage(imageView: UIImageView, url: URL) {
        
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.profileImageView.image = image
            }
        }).resume()
    }
    /*post */
    @IBAction func sentPost(_ sender: Any) {
        // generate unique postID
        let time = NSDate().timeIntervalSince1970
        let profileImgName = UserDefaults.standard.string(forKey: "profile_picture")
        let safeID = DatabaseManager.safeString(for: "\(safeEmail)_\(String(time))")
        let post = Post(postID: safeID, profileImage: profileImgName!, owner: nameLabel.text!, txt: textView.text, image: images)
        
        print("jfladjfdasjf\(post.profileImage)")
        DatabaseManager.shared.insertPost(with: post, completion: { success in
            if success {
                var arrayData = [Data]()
                //upload image to storage
                for img in post.image! {
                    guard let data = img.pngData() else {
                        print("png error")
                        return
                    }
                    print("send post to db")
                    arrayData.append(data)
                }
                
                let filename = post.postPictureName
                StorageManager.shared.uploadPictures(with: arrayData, path:post.safePost, fileName: filename, completion: { result in
                    switch result {
                    case .success(let url):
                        print(url)
                    case .failure(let error):
                        print(error)
                    }
                })
            }
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
    
    func runPicker() {
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
