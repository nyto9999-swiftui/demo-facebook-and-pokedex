//
//  StorageManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseStorage
import SDWebImage
public enum StorageErrors: Error {
    case failedToUploadPictures
    case failedToUpload
    case failedToGetDownloadUrl
}

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    public let reference = Storage.storage()
    
    
    public func uploadSinglePicture(with data: Data, path: String,fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
            storage.child("\(path)/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
                guard error == nil else {
                    print("failed to upload pic data to storage")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
            })
            completion(.success("uploaded profile img: \(fileName)"))
    }
    
    public func uploadPictures(with ArrayData: [Data], path: String,fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        var count = 1
        for data in ArrayData {
            //nyto1-gmail-com_1627381007-885789_post_picture_1.png
            storage.child("\(path)/\(fileName)_\(count).png").putData(data, metadata: nil, completion: {  _, error in
                guard error == nil else {
                    completion(.failure(StorageErrors.failedToUploadPictures))
                    return
                }
            })
            count = count+1
            completion(.success("send: \(fileName)_\(count-1)"))
        }
    }
    
    
    public func downloadUrl (for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storage.child(path)
        print("paht:\(path)")
        ref.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
    
    
  
    
    
    //remove post image
    public func removePostImage(path: String){
        storage.storage.reference().child(path).listAll {[weak self] Result, err in
            for item in Result.items {
                self?.storage.child("\(path)/\(item.name)").delete()
            }
        }
    }
    
    
    
    //get image
    public func getUIImageData(path: String, for imgview: UIImageView) -> Void{
           let ref = StorageManager.shared.reference.reference(withPath: path)
           ref.getData(maxSize: 1 * 10240 * 10240, completion: { data, error in
               guard let data = data else {
                   print(error ?? "failed to get UIimage Data")
                   return
               }
               imgview.image = UIImage(data: data)
           })
       }
    
    // get image for cell
    var imagePath: String?
    let imageCache = NSCache<NSString, UIImage>()
    public func getUIImageForCell(path: String, imgview: UIImageView) -> Void{
        imagePath = path
//        imgview.image = nil
        
        let ref = StorageManager.shared.reference.reference(withPath: path)
        
        if let imageFromCache = imageCache.object(forKey: path as NSString)
        {
            imgview.image = imageFromCache
            return
        }
        ref.getData(maxSize: 1 * 10240 * 10240, completion: {[weak self] data, error in
            guard let data = data else {
                print(error ?? "failed to get UIimage Data")
                return
            }
            DispatchQueue.main.async {
                let imgToCache = UIImage(data: data)
                
                if self?.imagePath == path {
                    imgview.image = imgToCache
                }
                self?.imageCache.setObject(imgToCache!, forKey: path as NSString)
                imgview.image = imgToCache
            }
        })
    }
    
   
   
}

class CustomImageView: UIImageView {
    let imageCache = NSCache<NSString, UIImage>()
    var tmp: String?
    
    func getUIImageData(path: String) -> Void{
        let ref = StorageManager.shared.reference.reference(withPath: path)
        
        image = nil
        
        if let imageFromCache = imageCache.object(forKey: path as NSString)
        {
            self.image = imageFromCache
            return
        }
        
        ref.getData(maxSize: 1 * 10240 * 10240, completion: { data, error in
            
            guard let data = data else {
                print(error ?? "failed to get UIimage Data")
                return
            }
            DispatchQueue.main.async {
                
                let imgToCache = UIImage(data: data)
                
                if self.tmp == path {
                    self.image = imgToCache
                }
                
                self.imageCache.setObject(imgToCache!, forKey: path as NSString)
                
                self.image = imgToCache
            }
        })
    }
    
    
    
}

