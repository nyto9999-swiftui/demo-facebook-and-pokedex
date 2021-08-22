//
//  StorageManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseStorage
import SDWebImage

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    public let reference = Storage.storage()
    
    
    /// 上傳一張圖片
    ///Caller: LoginVC(Facebook User), RegisterVC
    /// - Parameters:
    ///   - data: png data
    ///   - path: postID or profile
    ///   - fileName: 123-gmail-com_profile_picture.png
    ///   - completion: True -> 成功上傳圖片到Storage, False -> False
    public func uploadSinglePicture(with data: Data, path: String,fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
            storage.child("\(path)/\(fileName)").putData(data, metadata: nil, completion: { metadata, error in
                guard error == nil else {
                    print("failed to upload pic data to storage")
                    completion(.failure(Hi.StorageErrors.failedToUpload))
                    return
                }
            })
            completion(.success("uploaded profile img: \(fileName)"))
    }
    
    /// 上傳多張圖片
    /// - Parameters:
    ///   - ArrayData: Png image data
    ///   - path: user email + date() e.g. 123-gmail-com_profile_picture.png
    ///   - fileName: post_picture_
    ///   - completion: True -> 成功上傳數張圖片到Storage, False -> False
    public func uploadPictures(with ArrayData: [Data], path: String,fileName: String, completion: @escaping (Result<String, Error>) -> Void) {
        var count = 1
        for data in ArrayData {
            //nyto1-gmail-com_1627381007-885789_post_picture_1.png
            storage.child("\(path)/\(fileName)_\(count).png").putData(data, metadata: nil, completion: {  _, error in
                guard error == nil else {
                    completion(.failure(Hi.StorageErrors.failedToUploadPictures))
                    return
                }
            })
            count = count+1
            completion(.success("send: \(fileName)_\(count-1)"))
        }
    }
    
    
    /// 從Storage下載單張圖片網址
    /// Caller: MSG VC avatarimageview
    /// - Parameters:
    ///   - path: e.g. profile/123-gmail.com_profile_picture.png
    ///   - completion: True -> 成功下載圖片網址, False -> False
    public func downloadUrl (for path: String, completion: @escaping (Result<URL, Error>) -> Void) {
        let ref = storage.child(path)
        ref.downloadURL(completion: { url, error in
            guard let url = url, error == nil else {
                completion(.failure(Hi.StorageErrors.failedToGetDownloadUrl))
                return
            }
            completion(.success(url))
        })
    }
    
    /// 移除Storage上的圖片
    /// Caller: MainVC tableview cell 的 delete 按鈕
    /// - Parameter:
    ///   - path: 圖片位址 e.g. profile/123-gmail.com_profile_picture.png
    public func removePostImage(path: String){
        storage.storage.reference().child(path).listAll {[weak self] Result, err in
            for item in Result.items {
                self?.storage.child("\(path)/\(item.name)").delete()
            }
        }
    }
    
    /// 從Storage獲取圖片Data
    /// - Parameters:
    ///   - path: 圖片位址 e.g. profile/123-gmail.com_profile_picture.png
    ///   - imgview: UIImageView
    /// - Returns: UIImageView
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
    
    var imagePath: String?
    let imageCache = NSCache<NSString, UIImage>()
    /// 此方法可以解決tableview cell 會出現異步圖片錯亂的問題
    /// Caller: Chat Tableview cell.configure, etc.
    /// - Parameters:
    ///   - path: 圖片位址 e.g. profile/123-gmail.com_profile_picture.png
    ///   - imgview: UIImageView
    /// - Returns: UIImageView
    public func getUIImageForCell(path: String, imgview: UIImageView) -> Void{
        imagePath = path
        
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


