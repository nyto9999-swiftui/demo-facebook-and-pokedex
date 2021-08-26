//
//  ChatTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/18.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    var ConversationFeed:Conversation?
    let currentUser = UserDefaults.standard.string(forKey: "name")
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var lastestMsg: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    public func configure(with model: Conversation){
        ConversationFeed = model
        
        //reciver
        self.sender.text = ConversationFeed?.receiverName
        
        //msg
        if let currentUser = currentUser {
            if ConversationFeed?.senderName == currentUser {
                self.lastestMsg.text = "你: \((ConversationFeed?.latestMessage.text)!)"
            }
            else {
                self.lastestMsg.text = ConversationFeed?.latestMessage.text
            }
        }
        
        //profile icon
        if let recevierString = ConversationFeed?.receiverEmail {
            let recevierIconString = "profile/\(recevierString)_profile_picture.png"
            StorageManager.shared.getUIImageForCell(path: recevierIconString, imgview: self.imageview)
            self.imageview.contentMode = .scaleAspectFill
        }
       
    }
    
    static let identifier = "ChatTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "ChatTableViewCell", bundle: nil)
    }
}
