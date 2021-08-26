//
//  ChatViewController.swift
//  demoMsger
//
//  Created by 宇宣 Chen on 2021/7/1.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import SDWebImage

class MSGViewController: MessagesViewController {
    
    private var senderPhotoURL: URL?
    private var receiverPhotoURL: URL?
    private let conversationId: String?
    public let receiverId: String
    private let receiverName: String
    public let email = UserDefaults.standard.string(forKey: "email")
    public let name = UserDefaults.standard.string(forKey: "name")
    private var messages = [Message]()
    
    private var currentUser: Sender? {
        let safeEmail = DatabaseManager.safeString(for: email ?? "email empty")
        return Sender(photoURL: "", senderId: safeEmail, displayName: name ?? "name empty")
    }
    private var createConversationId: String? {
        let currentUser = DatabaseManager.safeString(for: email ?? "email empty")
        let conversationId = "\(receiverId)_\(currentUser)"
        return conversationId
    }
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        return UUID().uuidString
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    private func setup(){
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        messageInputBar.inputTextView.becomeFirstResponder()
       
        if self.conversationId == nil {
            listenForMessages(for: createConversationId!, shouldScrollToBottom: true)
        }
        else {
            listenForMessages(for: self.conversationId!, shouldScrollToBottom: true)
        }
    }
    
    init(with email: String, id: String?, receiverName: String){
        self.conversationId = id
        self.receiverId = email
        self.receiverName = receiverName
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //從Firebase/conversation/conversationId讀取訊息
    private func listenForMessages(for conversationId: String, shouldScrollToBottom: Bool) {
        
        DatabaseManager.shared.getAllMessages(with: conversationId, completion: { [weak self] result in
            switch result {
            case.success(let messages):
                guard !messages.isEmpty else {
                    print("no msg")
                    return
                }
                self?.messages = messages
                self?.messages.sort { $0.sentDate < $1.sentDate}
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                    if shouldScrollToBottom {
                        self?.messagesCollectionView.scrollToLastItem()
                    }
                }
            case .failure(let error):
                print("Failed to get messages: \(error)")
            }
        })
    }
}

//MARK: Message
extension MSGViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    //who the current sender is
    public func currentSender() -> SenderType {
        if let sender = currentUser {
            return sender
        }
        fatalError("Self Sender is nil email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) -> MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessagesCollectionView) -> Int {
        return messages.count
    }
    
    func configureAvatarView(_ avatarView: AvatarView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        let sender = message.sender
        if sender.senderId == currentUser?.senderId {
            if let currentUserImageURL = self.senderPhotoURL {
                avatarView.sd_setImage(with: currentUserImageURL, completed: nil)
            }
            else {
                guard let email = UserDefaults.standard.string(forKey: "email") else {
                    return
                }
                let safeEmail = DatabaseManager.safeString(for: email)
                let path = "profile/\(safeEmail)_profile_picture.png"
                
                //fetch url
                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.senderPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })
            }
        }
        else{
            if let receiverPhotoURL = self.receiverPhotoURL {
                avatarView.sd_setImage(with: receiverPhotoURL, completed: nil)
            }
            else {
                let email = self.receiverId
                let safeEmail = DatabaseManager.safeString(for: email)
                let path = "profile/\(safeEmail)_profile_picture.png"
                
                //fetch url
                StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
                    switch result {
                    case .success(let url):
                        self?.receiverPhotoURL = url
                        DispatchQueue.main.async {
                            avatarView.sd_setImage(with: url, completed: nil)
                        }
                    case .failure(let error):
                        print("\(error)")
                    }
                })

            }
        }
    }
}

// MARK: Input bar
extension MSGViewController: InputBarAccessoryViewDelegate {
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty, let currentSender = self.currentUser, let messageId = createMessageId(), let conversationId = createConversationId else {
            return
        }
        let message = Message(sender: currentSender, messageId: messageId, sentDate: Date(), kind: .text(text))
        
        DatabaseManager.shared.sendMessage(conversationID: conversationId, receiverId: receiverId, receiverName: receiverName, message: message, completion: { success in
            
            if success {
                print("meesage sent")
            }
            else{
                print("failed to send")
            }
        })
    }
}






