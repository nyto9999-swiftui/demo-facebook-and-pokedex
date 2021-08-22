//
//  ChatSearchUserTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/15.
//

import UIKit

class ChatSearchUserTableViewCell: UITableViewCell {
    @IBOutlet weak var imageview:UIImageView!
    @IBOutlet weak var label:UILabel!
    var appUserFeed:AppUser?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
    }
    
    public func configure(with model: AppUser){
        appUserFeed = model
        self.label.text = appUserFeed?.name
        //icon image
        if let path = appUserFeed?.profilePictureName {
            StorageManager.shared.getUIImageForCell(path: "profile/\(path)", imgview: self.imageview)
        }
    }
    
    static let identifier = "ChatSearchUserTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "ChatSearchUserTableViewCell", bundle: nil)
    }
}
