//
//  MainPostTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/30.
//

import UIKit

class MainPostTableViewCell: UITableViewCell {
    
    @IBOutlet weak var textview: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postownerLable: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    var postFeed: Post?
    static let identifier = "MainPostTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MainPostTableViewCell", bundle: nil)
    }
    
    func configure(with model: Post) {
        print("configure \(model.profileImage)")
        StorageManager.shared.getUIImageData(path: "profile/\(model.profileImage)", for: self.profileImageView)
        //nyto4826-yahoo-com-tw_1627658643-386545_post_picture_1.png
        print("configure \(model.postID)/\(model.postPictureName)_1.png")
        StorageManager.shared.getUIImageData(path: "\(model.postID)/\(model.postPictureName)_1.png", for: self.postImageView)
    }
}
