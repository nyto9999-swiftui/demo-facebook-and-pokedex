//
//  DatabaseManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    
    static func safeEmail(emailAddress : String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    public func insertUser(with user: AppUser, completion: @escaping (Bool) -> Void){
      
        self.database.child("users/\(user.safeEmail)/username").setValue(user.firstName+user.lastName)
        self.database.child("users/\(user.safeEmail)/username").getData(completion: { error, snapshot in
            if let error = error {
                print("Error getting data \(error)")
                completion(false)
            }
            else if snapshot.exists() {
                completion(true)
            }
            else {
                print("No data available")
                completion(false)
            }
        })
    }
    

    
    public func insertPost(with post: Post, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("users/\(post.safeEmail)/username").getData(completion: { error, snapshot in
            if let error = error {
                completion(.failure(error))
            }
            else{
                completion(.success(snapshot.value as Any))
            }
        })
    }
    
}

extension DatabaseManager {
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
       
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    
    
}


struct AppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String {
        
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}

struct Post {
    let owner: String
    let txt: String
    let image: UIImage
    var safeEmail: String {
        
        var safeEmail = owner.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }

}
