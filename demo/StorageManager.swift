//
//  StorageManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseStorage
public enum StorageErrors: Error {
    case failedToUpload
    case failedToGetDownloadUrl
}

final class StorageManager {
    static let shared = StorageManager()
    private let storage = Storage.storage().reference()
    
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        
        storage.child("image/\(fileName)").putData(data, metadata: nil, completion: { [weak self] metadata, error in
            
            guard error == nil else {
                print("failed to upload pic data to storage")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self?.storage.child("image/\(fileName)").downloadURL(completion: { url , error in
                
                guard let url = url else {
                    print("Failed to get download url")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("download url returned \(urlString)")
                completion(.success(urlString))
                
            })
        })
    }
}
