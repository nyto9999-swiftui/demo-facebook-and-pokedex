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
    case failedToUpload
    case failedToGetDownloadUrl
}

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    public let reference = Storage.storage()
    
 
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    
    public func uploadPicture(with datas: [Data], file: String,fileName: String, completion: @escaping UploadPictureCompletion) {
        var count = 1
        for data in datas {
            //1_nyto1-gmail-com_1627381007-885789_post_picture.png
            storage.child("\(file)/\(fileName)_\(count).png").putData(data, metadata: nil, completion: { [weak self] metadata, error in
                
                guard error == nil else {
                    print("failed to upload pic data to storage")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
            })
            count = count+1
            completion(.success("send: \(fileName)_\(count-1)"))
        }
    }
    public func uploadProfilePicture(with data: Data, file: String,fileName: String, completion: @escaping UploadPictureCompletion) {
            storage.child("\(file)/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
                guard error == nil else {
                    print("failed to upload pic data to storage")
                    completion(.failure(StorageErrors.failedToUpload))
                    return
                }
            })
            completion(.success("uploaded profile img: \(fileName)"))
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
    
    
    public func getUIImageData(path: String, for imgview: UIImageView) -> Void{
        let ref = StorageManager.shared.reference.reference(withPath: path)
        ref.getData(maxSize: 1 * 10240 * 10240, completion: { [weak self] data, error in
            guard let data = data else {
                print(error ?? "failed to getData")
                return
            }
            imgview.image = UIImage(data: data)
        })
    }
    
    
   
}
