//
//  DatabaseManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseDatabase
import MessageKit
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
        
        self.database.child("users/\(user.safeEmail)/username").setValue(user.name)
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
            "profileImg": post.profileImage,
            "imageCount": post.imageCount ?? 0
        ]
        self.database.child("postwall/\(post.postID)").setValue(newPost) {   (error:Error?, ref:DatabaseReference) in
            guard error == nil else {
                print("failed to insert post")
                completion(false)
                return
            }
        }
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
                    let txt = p.value["txt"] as? String,
                    let imageCount = p.value["imageCount"] as? Int else {
                    print("fail to get all post")
                    return
                }
                Feed.append(Post(postID: p.key, profileImage: profileImage, owner: owner, txt: txt, image: nil, imageCount: imageCount))
            }
            completion(.success(Feed))
        })
        
    }
    
    //delete post
    public func deletePost(for path: String){
        self.database.child("postwall/\(path)").removeValue() { err,_  in
            if err != nil {
                print(err ?? "Failed to delete post")
            }
        }
        self.database.child("comments/\(path)").removeValue() { err,_ in
            if err != nil {
                print(err ?? "Failed to delete comment")
            }
        }
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
                print(err ?? "Failed to delete like")
            }
        }
    }
    
    //check like
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
        let time = NSDate().timeIntervalSince1970
        
        let newComment: [String: Any] = [
            "owner":comment.sender,
            "txt":comment.txt,
            "senderIcon":comment.senderIcon,
            "createdAt":String(time)
        ]
        self.database.child("comments/\(post)/\(comment.commentID)").setValue(newComment)
    }
    
    // get all comments
    public func getAllComments(for path: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        database.child("comments/\(path)").observe(.value, with: { post in
            var comments = [Comment]()
            
            for comment in post.children {
                if let comment = comment as? DataSnapshot {
                    guard let dict = comment.value as? [String: Any] else {
                        print("no value")
                        completion(.failure(Hi.DatabaseError.failedToGetData))
                        return
                    }
                    guard let sender = dict["owner"] as? String,
                          let senderIcon = dict["senderIcon"] as? String,
                          let txt = dict["txt"] as? String,
                          let createdAt = dict["createdAt"] as? String else {
                        print("errrror")
                        return
                    }
                    comments.append(Comment(commentID: comment.key, postID: path, sender: sender, txt: txt, senderIcon: senderIcon, createdAt: createdAt))
                }
            }
            completion(.success(comments))
        })
    }
    
    //get all users
    
    //usermail {
    //[username: name]
    //}
    public func getALlUsers(completion: @escaping (Result<[AppUser], Error>) -> Void) {
        
        var users = [AppUser]()
        self.database.child("users/").observe(.value, with: { snapshot in
            for user in snapshot.children {
                if let user = user as? DataSnapshot {
                    
                    guard let dict = user.value as? [String:Any] else {
                        print("ffjfjff")
                        return
                    }
                    guard let name = dict["username"] as? String else {
                        return
                            completion(.failure(Hi.DatabaseError.failedToGetData))
                    }
                    users.append(AppUser(name: name, emailAddress: user.key))
                }
            }
            completion(.success(users))
        })
    }
    
    public func tryit(){
        print("jfk")
        self.database.child("users/").observe(.value) { DataSnapshot in
            for user in DataSnapshot.children {
                if let user = user as? DataSnapshot {
                    print(user.key)
                }
            }
        }
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
    }
    
    //MARK: sendMessage
    public func sendMessage(conversationID: String, receiver: String, senderName: String, message: Message, completion: @escaping (Bool) -> Void) {
        
        let dateString = Hi.dataFormatter.string(from: message.sentDate)
        var content = ""
        switch message.kind {
        
        case .text(let messageText):
            content = messageText
        case .attributedText(_):
            break
        case .photo(let mediaItem):
            if let targetUrlString = mediaItem.url?.absoluteString{
                content = targetUrlString
            }
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        let MessageEntry: [String: Any] = [
            "senderName": senderName,
            "type": message.kind.messageKindString,
            "content": content,
            "date": dateString,
            "senderId": message.sender.senderId,
            "receiverId": receiver,
            "is_read": false,
        ]
        
        database.child("conversation/\(conversationID)/\(message.messageId)").setValue(MessageEntry) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Failed to send message: \(error)")
                completion(false)
            }
            else{
                print("message send")
                completion(true)
            }
            
        }
    }
    
    public func getAllMessages(with conversationId: String, completion: @escaping (Result<[Message],Error>) -> Void){
        database.child("conversation/\(conversationId)").observe(.value) { DataSnapshot in
            var messages = [Message]()
           
            for eachMessage in DataSnapshot.children {
                if let eachMessage = eachMessage as? DataSnapshot {
                    guard let dict = eachMessage.value as? [String:Any] else {
                        completion(.failure(Hi.DatabaseError.failedToGetData))
                        return
                    }
                    //sender, msgId, date, kind
                    guard let senderName = dict["senderName"] as? String,
                          let senderId = dict["senderId"] as? String,
                          let content = dict["content"] as? String,
                          let type = dict["type"] as? String,
                          let dateString = dict["date"] as? String,
                          let date = Hi.dataFormatter.date(from: dateString)  else {
                        print("faileedfailed")
                        return
                    }
                    var kind: MessageKind?
                    if type == "text" {
                        kind = .text(content)
                    }
                    guard let finalKind = kind else {
                        print("finlkind")
                        return
                    }
                    let sender = Sender(photoURL: "", senderId: senderId, displayName: senderName)
                    messages.append(Message(sender: sender, messageId: eachMessage.key, sentDate: date, kind: finalKind))
                }
            }
            print(messages.count)
            completion(.success(messages))
        }
        
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

