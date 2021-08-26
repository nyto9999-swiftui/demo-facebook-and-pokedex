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
    @IBOutlet weak var collectionview: UICollectionView!
    @IBOutlet weak var pageControl: UIPageControl!
    @IBOutlet weak var view: UIView!
    var imgCount = 0
    var postFeed: Post?
    let user = UserDefaults.standard.string(forKey: "name")
    let postID = UserDefaults.standard.string(forKey: "postID")
    
    override func awakeFromNib() {
        super.awakeFromNib()
        setupColleciton()
    }
    
    private func setupColleciton(){
        collectionview.register(MainPostImagesCollectionViewCell.nib(), forCellWithReuseIdentifier: MainPostImagesCollectionViewCell.identifier)
        
        collectionview.delegate = self
        collectionview.dataSource = self
    }
    
    @IBAction func didTapLike(_ sender: Any) {
        likeButtonClicked()
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
    
        // delete button
        SetDeleteButtonForPostOwner()
        
        // like button
        likeButtonState()
    }
    
    static let identifier = "MainPostTableViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "MainPostTableViewCell", bundle: nil)
    }
}

//MARK: DeleteButton/LikeButton
extension MainPostTableViewCell {
    private func likeButtonClicked(){
        if likeButton.currentImage == UIImage(systemName: "hand.thumbsup") {
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            DatabaseManager.shared.insertLike(postId: postFeed!.postID, clicker: user!, completion: { success in
                if success {
                    print("insert like successed")
                }
            })
        }
        else{
            self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            DatabaseManager.shared.delLike(postId: postFeed!.postID, clicker: user!)
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
        DatabaseManager.shared.isLike(for: postFeed!.postID, clicker: user!) { click in
            if click {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup.fill"), for: .normal)
            }
            else {
                self.likeButton.setImage(UIImage(systemName: "hand.thumbsup"), for: .normal)
            }
        }
    }
}

//MARK: collection view for post images
extension MainPostTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        let count = (postFeed?.imageCount)!
        pageControl.numberOfPages = count
        pageControl.isHidden = !(count>1)
        return count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionview.dequeueReusableCell(withReuseIdentifier: MainPostImagesCollectionViewCell.identifier, for: indexPath) as! MainPostImagesCollectionViewCell
        cell.configure(with: postFeed!, indexrow: indexPath.row)
        
        return cell
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        return CGSize(width: collectionView.width, height: collectionview.height)
    }

    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
    func scrollViewDidEndScrollingAnimation(_ scrollView: UIScrollView) {
        pageControl?.currentPage = Int(scrollView.contentOffset.x) / Int(scrollView.frame.width)
    }
}

