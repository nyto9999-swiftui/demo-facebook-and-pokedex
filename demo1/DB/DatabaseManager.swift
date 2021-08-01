//
//  DatabaseManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    
    static func safeString(for firebaseUpload : String) -> String {
        var safeEmail = firebaseUpload.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    //insert user
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
    
    //main page post wall
    public func insertPost(with post: Post, completion: @escaping ((Bool) -> Void)){
                                        //owner = safeEmail
        self.database.child("postwall").observeSingleEvent(of: .value, with: { snapshot in
            if var postwallCollection = snapshot.value as? [[String:Any]] {
                let newPost: [String: Any] = [
                    "owner":post.owner,
                    "txt":post.txt,
                    "postID":post.postID,
                    "profileImg": post.profileImage
                ]
                postwallCollection.append(newPost)
                
                self.database.child("postwall").setValue(postwallCollection, withCompletionBlock: {error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
            else {
                //create that array
                let newPost: [[String: Any]] = [[
                    "owner":post.owner,
                    "txt":post.txt,
                    "postID":post.postID,
                    "profileImg": post.profileImage
                ]]
                self.database.child("postwall").setValue(newPost, withCompletionBlock: {error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                })
            }
        })
    }
    
    //get all posts
    public func getAllPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        
        database.child("postwall").observe(.value, with: { snapshot in
            var postfeed:[Post] = []
            guard let posts = snapshot.value as? [[String:Any]] else {
                print("failed to get all post")
                return
            }
            print(posts.count)
            print(posts)
            for i in posts {
                guard let owner = i["owner"] as? String,
                      let txt = i["txt"] as? String,
                      let postID = i["postID"] as? String,
                      let profileImge = i["profileImg"] as? String else {
                    completion(.failure(Hi.DatabaseError.failedToFetch))
                    return
                }
                postfeed.append(Post(postID: postID, profileImage: profileImge, owner: owner, txt: txt, image: nil))
            }
            completion(.success(postfeed))
            
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
    public func getUsername(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("users/\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value,
                  let userData = value as? [String:Any],
                  let username = userData["username"] as? String else {
                completion(.failure(Hi.DatabaseError.observeSingleEvent))
                return
            }
            completion(.success(username))
        })
    }
    
    public func getSafeString() -> String {
        let email = UserDefaults.standard.string(forKey: "email")
        let safe = DatabaseManager.safeString(for: email!)
        return safe
    }
  
    
    
    
    
    
}




