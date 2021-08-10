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
    var currentImage:Int = 1
    var postFeed: Post?
    let user = UserDefaults.standard.string(forKey: "name")
    let postID = UserDefaults.standard.string(forKey: "postID")
    static let identifier = "MainPostTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        likeButtonClicked()
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
        
        //Get first imageview
        if let pID = postFeed?.postID, let Extension = postFeed?.postPictureName {
            StorageManager.shared.getUIImageForCell(path: "\(pID)/\(Extension)_1.png", imgview: self.postImageView)
        }
        
        // delete button
        SetDeleteButtonForPostOwner()
        
        // like button
        likeButtonState()
        
        //swipe right
        postImageView.isUserInteractionEnabled = true
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(gesture:)))
        swipeRight.direction = .right
        self.postImageView.addGestureRecognizer(swipeRight)
        
        //swipe left
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(self.swipe(gesture:)))
        swipeLeft.direction = .left
        self.postImageView.addGestureRecognizer(swipeLeft)
        
        
    }
}

//MARK: DeleteButton/LikeButton
extension MainPostTableViewCell {
    private func likeButtonClicked(){
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
    
    
    private func SetDeleteButtonForPostOwner(){
        if postFeed?.owner != user! {
            self.deleteButton.setImage(UIImage(systemName: ""), for: .normal)
        }
        else {
            self.deleteButton.setImage(UIImage(systemName: "xmark.circle.fill"), for: .normal)
        }
    }
    private func likeButtonState(){
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

//MARK: Animation/PostImageView
extension MainPostTableViewCell {
    
    //UIGestureRecognizer
    @objc func swipe(gesture: UIGestureRecognizer?) -> Void {
        if (postFeed?.imageCount) == nil {
            print("no images")
            return
        }
        if let swipegesture = gesture as? UISwipeGestureRecognizer {
            
            switch swipegesture.direction {
            case UISwipeGestureRecognizer.Direction.left:
                
                if currentImage == (postFeed?.imageCount)! { currentImage = 1}
                else { currentImage += 1}
                
                getPostImage()
                animateRotate(to: "left")

            case UISwipeGestureRecognizer.Direction.right:
                if currentImage == 1 { currentImage = (postFeed?.imageCount)! }
                else { currentImage -= 1}
        
                getPostImage()
                animateRotate(to: "right")
            default:
                break
            }
        }
    }
    
    //download image from firebase
    private func getPostImage(){
        if let pID = postFeed?.postID, let Extension = postFeed?.postPictureName {
            StorageManager.shared.getUIImageForCell(path: "\(pID)/\(Extension)_\(currentImage).png", imgview: self.postImageView)
        }
    }
    
    //post imageview animation
    private func animateRotate(to: String){
        if to == "right" {
            UIView.animate(withDuration: 0.1, animations: {
                self.postImageView.transform = CGAffineTransform(rotationAngle: .pi/25)
                    }){ _ in
                UIView.animate(withDuration: 0.25) {
                    self.postImageView.transform = CGAffineTransform.identity
                }
            }
        }
        else{ // left
            UIView.animate(withDuration: 0.1, animations: {
                self.postImageView.transform = CGAffineTransform(rotationAngle: -.pi/25)
                    }){ _ in
                UIView.animate(withDuration: 0.25) {
                    self.postImageView.transform = CGAffineTransform.identity
                }
            }
        }
    }
}
