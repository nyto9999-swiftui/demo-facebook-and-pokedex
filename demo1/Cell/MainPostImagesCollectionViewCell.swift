//
//  MainPostImagesCollectionViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/14.
//

import UIKit

class MainPostImagesCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageview: UIImageView!
  
    override func awakeFromNib() {
        super.awakeFromNib()    
    }
    
    public func configure(with model: Post, indexrow: Int){
        //download images
        StorageManager.shared.getUIImageForCell(path: "\(model.postID)/\(model.postPictureName)_\(indexrow+1).png", imgview: self.imageview)
    }
    
    
    
    static let identifier = "MainPostImagesCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "MainPostImagesCollectionViewCell", bundle: nil)
    }
}
