//
//  MainPostTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/30.
//

import UIKit

class MainPostTableViewCell: UITableViewCell {
    @IBOutlet weak var commentButton: UIButton!
    @IBOutlet weak var deleteButton: UIButton!
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var textview: UILabel!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var postownerLable: UILabel!
    @IBOutlet weak var postImageView: UIImageView!
    
    var postFeed: Post?
    let user = UserDefaults.standard.string(forKey: "name")
    let postID = UserDefaults.standard.string(forKey: "postID")
    static let identifier = "MainPostTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        if likeButton.currentImage == UIImage(systemName: "hand.thumbsup") {
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            DatabaseManager.shared.insertLike(path: postFeed!.postID, clicker: user!, completion: { success in
                if success {
                    print("insert like successed")
                }
            })
        }
        else{
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            DatabaseManager.shared.delLike(path: postFeed!.postID, clicker: user!)
        }
    }
    
    // comment button
    @IBAction func test2(_ sender: Any) {
        
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MainPostTableViewCell", bundle: nil)
    }

    public func configure(with model: Post) {
        UserDefaults.standard.setValue(model.postID, forKey: "postID")
        self.postFeed = model
        self.textview.text = postFeed?.txt
        self.postownerLable.text = postFeed?.owner
        
        
        //icon image
        if let path = postFeed?.profileImage {
            StorageManager.shared.getUIImageForCell(path: "profile/\(path)", imgview: self.profileImageView)
        }
        
        //image view
        if let pID = postFeed?.postID, let Extension = postFeed?.postPictureName {
            StorageManager.shared.getUIImageForCell(path: "\(pID)/\(Extension)_1.png", imgview: self.postImageView)
        }
        
        // delete button
        if postFeed?.owner != user! {
            self.deleteButton.setImage(UIImage(systemName: ""), for: .normal)
        }
        else {
            self.deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
        
        // like button
        DatabaseManager.shared.checkLike(for: postFeed!.postID, clicker: user!) { click in
            if click {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            }
            else {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
        }
        
    }
    
}
