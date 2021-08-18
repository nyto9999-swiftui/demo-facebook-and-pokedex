//
//  ChatTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/18.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    var ConversationFeed:Conversation?
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var sender: UILabel!
    @IBOutlet weak var lastestMsg: UILabel!
    
    static let identifier = "ChatTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ChatTableViewCell", bundle: nil)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    public func configure(with model: Conversation){
        ConversationFeed = model
        self.sender.text = ConversationFeed?.name
        self.lastestMsg.text = ConversationFeed?.latestMessage.text
        
        if let recevierString = ConversationFeed?.otherUserEmail {
            let recevierIconString = "profile/\(recevierString)_profile_picture.png"
            StorageManager.shared.getUIImageForCell(path: recevierIconString, imgview: self.imageview)
        }
       
    }
    
}
