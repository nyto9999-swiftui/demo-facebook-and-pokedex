//
//  ChatViewController.swift
//  demoMsger
//
//  Created by 宇宣 Chen on 2021/7/1.
//

import UIKit
import MessageKit
import  InputBarAccessoryView
import SDWebImage


class MSGViewController: MessagesViewController {
    
    
    
    
    public var isNewConversation = false
    private let conversationId: String?
    public let receiver: String
    
    
    private var messages = [Message]()
    
    private var currentUser: Sender? {
        guard let email = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        let safeEmail = DatabaseManager.safeString(for: email)
        return Sender(photoURL: "", senderId: safeEmail, displayName: "me")
    }
    private var createConversationId: String? {
        guard  let currentUserEmail = UserDefaults.standard.string(forKey: "email") else {
            return nil
        }
        let currentUser = DatabaseManager.safeString(for: currentUserEmail)
        let conversationId = "\(receiver)_\(currentUser)"
        return conversationId
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
    
    
    init(with email: String, id: String?){
        self.conversationId = id
        self.receiver = email
        super.init(nibName: nil, bundle: nil)
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
        setupInputButton()
        
        
    }
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
    
    private func setupInputButton(){
        let button = InputBarButtonItem()
        button.setSize(CGSize(width: 35, height: 35), animated: false)
        button.setImage(UIImage(systemName: "paperclip"), for: .normal)
        button.onTouchUpInside({ [weak self] _ in
            print("yes")
        })
        messageInputBar.setLeftStackViewWidthConstant(to: 36, animated: false)
        messageInputBar.setStackViewItems([button], forStack: .left, animated: false)
    }
    
    //MARK: ConversationID
    private func createMessageId() -> String? {
        // date, otherUserEmail, senderEmail, randomInt
        return UUID().uuidString
    }
    
    
}

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
    
    func configureMediaMessageImageView(_ imageView: UIImageView, for message: MessageType, at indexPath: IndexPath, in messagesCollectionView: MessagesCollectionView) {
        guard let message = message as? Message else {
            return
        }
        
        switch message.kind {
        case .photo(let media):
            guard let imageUrl = media.url else {
                return
            }
            imageView.sd_setImage(with: imageUrl, completed: nil)
        default:
            break
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
        
        DatabaseManager.shared.sendMessage(conversationID: conversationId, receiver: receiver, senderName: self.title ?? "User", message: message, completion: { success in
            
            if success {
                print("meesage sent")
            }
            else{
                print("failed to send")
            }
        })
        
        
    }
}






