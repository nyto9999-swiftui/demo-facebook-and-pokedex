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
    
    //insert post
    public func insertPost(with post: Post, completion: @escaping ((Bool) -> Void)){
        let newPost: [String: Any] = [
            "owner":post.owner,
            "txt":post.txt,
            "postID":post.postID,
            "profileImg": post.profileImage
        ]
        self.database.child("postwall/\(post.postID)").setValue(newPost) {   (error:Error?, ref:DatabaseReference) in
            guard error == nil else {
                print("failed to insert post")
                completion(false)
                return
            }
        }//MARK: fix
        var arrayData = [Data]()
        //upload image to storage
        for img in post.image! {
            guard let data = img.pngData() else {
                print("png error")
                completion(false)
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
                completion(true)
            case .failure(let error):
                print(error)
                completion(false)
            }
        })
    }
    
    //get all posts
    public func getAllPosts(completion: @escaping (Result<[Post], Error>) -> Void) {
        database.child("postwall").observe(.value, with: { snapshot in
            var Feed:[Post] = []
            guard let posts = snapshot.value as? [String:[String:Any]] else {
                completion(.failure(Hi.DatabaseError.failedToFetch))
                return
            }
            for p in posts {
                guard
                    let owner = p.value["owner"] as? String,
                    let profileImage = p.value["profileImg"] as? String,
                    let txt = p.value["txt"] as? String else {
                    print("fail to get all post")
                    return
                }
                Feed.append(Post(postID: p.key, profileImage: profileImage, owner: owner, txt: txt, image: nil))
            }
            completion(.success(Feed))
        })
        
    }
    //insert like
    public func insertLike(path: String, clicker: String, completion: @escaping ((Bool) -> Void)) {
        database.child("postwall/\(path)/like").observeSingleEvent(of: .value, with: { snapshot in
            let newLike:[String:String] = ["\(clicker)":"\(clicker)"]
            
            guard var like = snapshot.value as? [String:String] else {
                //empty
                self.database.child("postwall/\(path)/like").setValue(newLike) { err, _ in
                    guard err == nil else {
                        completion(false)
                        return
                    }
                    completion(true)
                }
                completion(true)
                return
            }
            // append element to like
            like["\(clicker)"] = "\(clicker)"
            self.database.child("postwall/\(path)/like").setValue(newLike) { err, _ in
                guard err == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        })
    }
    
    // delete like
    public func delLike(path: String, clicker: String) {
        database.child("postwall/\(path)/like/\(clicker)").removeValue { err,_  in
            if err != nil {
                print("\(err)" ?? "failed to delte like")
            }
        }
    }
    public func checkLike(for post: String, clicker:String, completion: @escaping ((Bool) -> Void)) {
        database.child("postwall/\(post)/like").observe(.value, with: {snapshot in
            //empty
            guard let snap = snapshot.value as? [String: String] else {
                completion(false)
                return
            }
            //clicked
            guard snap["\(clicker)"] == nil else {
                completion(true)
                return
            }
            // not click
            completion(false)
        })
    }
    
    //insert comment
    public func insertComment(for post: String, comment: Comment) {
        
        let newComment: [String: Any] = [
            "postID":post,
            "owner":comment.sender,
            "txt":comment.txt,
            "senderIcon":comment.senderIcon
        ]
        self.database.child("comments/\(post)").setValue(newComment)
    }
    
    
    public func hi() {
        let like:[String] = ["tony","chen","宇亘陳"]
        self.database.child("postwall/nyto4826-yahoo-com-tw_1627941263-837333/like").setValue(like)
        
        database.child("postwall/nyto4826-yahoo-com-tw_1627944152-029378/like").observe(.value, with: {snapshop in
            guard let likes = snapshop.value as? [String] else {
                print("faileddddddd")
                return
            }
            for i in likes {
                if i == "like" {
                    print("yes")
                }
            }
        })
    }}

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




