//
//  PostCollectionViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/25.
//

import UIKit
import SDWebImage
class PostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
        layer.cornerRadius = 5
    }

    public func configure(url: URL){
        self.imageView.sd_setImage(with: URL(string: url.absoluteString))
    }
    public func configure(with image: UIImage){
        imageView.image = image
    }
    
    static let identifier = "PostCollectionViewCell"
    static func nib() -> UINib {
        return UINib(nibName: "PostCollectionViewCell", bundle: nil)
    }
}
