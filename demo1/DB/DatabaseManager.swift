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
    
    /*Firebase 不接受 '. @ # 等符號*/
    static func safeString(for firebaseUpload : String) -> String {
        var safeEmail = firebaseUpload.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    
    /// 第一次使用此App需要用戶的資料
    /// Caller: RegisterViewController
    /// - Parameters:
    ///   - user: AppUser的屬性 -> 用戶姓名, 郵箱作為id使用
    ///   - completion: True -> 用戶姓名, id 成功上傳至Firebase, False -> 上傳失敗
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
    
    /// 上傳使用者貼文
    /// Caller: PostViewController
    /// - Parameters:
    ///   - post: Post屬性： owner, txt, postId = String(Email + Date), profileImg = String(Email + _profile_picture.png), imageCount
    ///   - completion: True -> 上傳至 postwall, False -> 上傳失敗
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
    
    /// 獲取Postwall 底下的所有貼文
    /// Caller: Main VC Tableview
    /// - Parameter completion: True -> 回傳[Post]給Main VC Tableview ,  False -> Error
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
    
    /// 使用者刪除自己特定的貼文
    /// Caller: Main VC TableviewCell 的 Delete 按鈕
    /// - Parameter postId: AppUser.Email + date()
    public func deletePost(for postId: String){
        self.database.child("postwall/\(postId)").removeValue() { err,_  in
            if err != nil {
                print(err ?? "Failed to delete post")
            }
        }
        self.database.child("comments/\(postId)").removeValue() { err,_ in
            if err != nil {
                print(err ?? "Failed to delete comment")
            }
        }
    }
    
    /// 使用者點擊Main VC TableviewCell 的 Like 按鈕
    /// Caller: Main VC TableviewCell 的 Like 按鈕
    /// - Parameters:
    ///   - postId: AppUser.Email + date(), e.g. "nyto4826-yahoo-com-tw_1628960831-5357928"
    ///   - clicker: UserDefault.stand.string(forKey: "name")
    ///   - completion: True -> 上傳 [ "clicker" , "clicker] 至 postId/like, Fales -> Error
    public func insertLike(postId: String, clicker: String, completion: @escaping ((Bool) -> Void)) {
        database.child("postwall/\(postId)/like").observeSingleEvent(of: .value, with: { snapshot in
            let newLike:[String:String] = ["\(clicker)":"\(clicker)"]
            
            guard var like = snapshot.value as? [String:String] else {
                //empty
                self.database.child("postwall/\(postId)/like").setValue(newLike) { err, _ in
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
            self.database.child("postwall/\(postId)/like").setValue(newLike) { err, _ in
                guard err == nil else {
                    completion(false)
                    return
                }
                completion(true)
            }
        })
    }
    
    /// 使用者取消自已按過喜歡的貼文
    /// Caller: Main VC TableviewCell 的 Like 按鈕
    /// - Parameters:
    ///   - postId: AppUser.Email + date(),    e.g. "nyto4826-yahoo-com-tw_1628960831-5357928"
    ///   - clicker: UserDefault.stand.string(forKey: "name")    e.g. TonyChen
    public func delLike(postId: String, clicker: String) {
        database.child("postwall/\(postId)/like/\(clicker)").removeValue { err,_  in
            if err != nil {
                print(err ?? "Failed to delete like")
            }
        }
    }
    
    /// 使用者是否已按過Post的Like按鈕
    /// Caller: MainPostTableViewCell.Configure()
    /// - Parameters:
    ///   - postId: AppUser.Email + date(),    e.g. "nyto4826-yahoo-com-tw_1628960831-5357928"
    ///   - clicker: UserDefault.stand.string(forKey: "name")    e.g. TonyChen
    ///   - completion: True -> Like按鈕已按過, False -> Like按鈕沒按過
    public func isLike(for postId: String, clicker:String, completion: @escaping ((Bool) -> Void)) {
        database.child("postwall/\(postId)/like").observe(.value, with: {snapshot in
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
    
    /// 上傳使用者的留言至Firebase
    /// Caller: MainVC TableviewCell 的 Comment按鈕 -> CommemtVC 的 TextField
    /// - Parameters:
    ///   - postId: AppUser.Email + date(),    e.g. "nyto4826-yahoo-com-tw_1628960831-5357928"
    ///   - comment: UUID()
    public func insertComment(for postId: String, comment: Comment) {
        let time = Date().timeIntervalSince1970
        
        let newComment: [String: Any] = [
            "owner":comment.sender,
            "txt":comment.txt,
            "senderIcon":comment.senderIcon,
            "createdAt":String(time)
        ]
        self.database.child("comments/\(postId)/\(comment.commentID)").setValue(newComment)
    }
    
    /// 從Firebase獲取指定的貼文裡的所有留言
    /// Caller: CommentVC
    /// - Parameters:
    ///   - postId: AppUser.Email + date(),    e.g. "nyto4826-yahoo-com-tw_1628960831-5357928"
    ///   - completion: 回傳[Comment] 到 ＣommentVC Tableview
    public func getAllComments(for postId: String, completion: @escaping (Result<[Comment], Error>) -> Void) {
        database.child("comments/\(postId)").observe(.value, with: { post in
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
                    comments.append(Comment(commentID: comment.key, postID: postId, sender: sender, txt: txt, senderIcon: senderIcon, createdAt: createdAt))
                }
            }
            completion(.success(comments))
        })
    }
    
    /// 從Firebase獲取Users的屬性
    /// Caller: UserSearchVC
    /// - Parameter completion: True -> 回傳[AppUser]給UearSearchVC, False -> Error
    public func getALlUsers(completion: @escaping (Result<[AppUser], Error>) -> Void) {
        
        var users = [AppUser]()
        self.database.child("users/").observe(.value, with: { snapshot in
            for user in snapshot.children {
                if let user = user as? DataSnapshot {
                    
                    guard let dict = user.value as? [String:Any] else {
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
            users = []
        })
    }
    
    //MARK: sendMessage
    /// 使用者在MSG VC 輸入訊息
    /// Caller: CommentVC 的 TextField
    /// - Parameters:
    ///   - conversationID: "\(receiverId)_\(currentUser)"
    ///   - receiverId: Receiver Email
    ///   - receiverName: receiverName
    ///   - message: 屬性：sender, messageId, sentDate, kind
    ///   - completion: True -> 成功上傳comment到 Firebase 並且 上傳到 receiver 和 sender 的 lastMessage底下, False -> False
    public func sendMessage(conversationID: String, receiverId: String, receiverName: String, message: Message, completion: @escaping (Bool) -> Void) {
        
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
            "senderName": message.sender.displayName,
            "receiverName": receiverName,
            "type": message.kind.messageKindString,
            "content": content,
            "date": dateString,
            "senderId": message.sender.senderId,
            "receiverId": receiverId,
            "is_read": false,
        ]
        
        //Firebase/Comments
        database.child("conversation/\(conversationID)/\(message.messageId)").setValue(MessageEntry) { (error:Error?, ref:DatabaseReference) in
            if let error = error {
                print("Failed to send message: \(error)")
                completion(false)
            }
        }
        
        // Firebase/users/sender/latestMessage
        database.child("users/\(message.sender.senderId)/latestMessage/\(conversationID)").setValue(MessageEntry) { error, _ in
            if let error = error {
                print("Failed to send message: \(error)")
                completion(false)
            }
        }
        
        // Firebase/users/receiver/latestMessage
        database.child("users/\(receiverId)/latestMessage/\(conversationID)").setValue(MessageEntry) { error, _ in
            if let error = error {
                print("Failed to send message: \(error)")
                completion(false)
            }
        }
    }
    
    /// 獲取 使用者與所有對話過的用戶的最後一次對話
    /// Caller: ChatVC Tableview
    /// - Parameters:
    ///   - user: UserDefault.stand.string(forKey: "email")
    ///   - completion: True -> 回傳[Conversation], False -> Error
    public func getAllConversations(for user: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        var conversations = [Conversation]()
        database.child("users/\(user)/latestMessage").observe(.value, with: { snapshot in
            for eachMessage in snapshot.children {
                guard let eachMessage = eachMessage as? DataSnapshot else {
                    completion(.failure(Hi.DatabaseError.failedToGetData))
                    return
                }
                guard let dict = eachMessage.value as? [String:Any] else {
                    completion(.failure(Hi.DatabaseError.failedToGetData))
                    return
                }
                
                guard let senderName = dict["senderName"] as? String,
                      let receiverName = dict["receiverName"] as? String,
                      let receiverId = dict["receiverId"] as? String,
                      let content = dict["content"] as? String,
                      let date = dict["date"] as? String,
                      let isRead = dict["is_read"] as? Bool else {
                    completion(.failure(Hi.DatabaseError.failedToGetData))
                    return
                }
                let lastestMessage = LatestMessage(date: date, text: content, isRead: isRead)
                conversations.append(Conversation(id: eachMessage.key, senderName: senderName, receiverName: receiverName, receiverEmail: receiverId, latestMessage: lastestMessage))
            }
            completion(.success(conversations))
            conversations = []
        })
    }
    
    
    /// 獲取使用者與特定用戶的所有對話
    /// Caller: MSG VC
    /// - Parameters:
    ///   - conversationId: "\(receiverId)_\(currentUser)"  e.g. nyto-gmail-com_123-gmail-com
    ///   - completion: True -> 回傳[Message], False -> Error
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
    /// 防止用戶資料重複登入到Firebase
    /// Caller: LoginVC(Facebook用戶註冊), RegisterVC
    /// - Parameters:
    ///   - email: 使用者的Email 會被作為 userId 使用
    ///   - completion: True -> 註冊至Firebase成功, False -> False
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
    
    /// 獲取使用者名稱
    /// Caller: LoginVC
    /// - Parameters:
    ///   - userId: = User Email
    ///   - completion: True -> get username, False -> False
    public func getUsername(username: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("users/\(username)").observeSingleEvent(of: .value, with: { snapshot in
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

