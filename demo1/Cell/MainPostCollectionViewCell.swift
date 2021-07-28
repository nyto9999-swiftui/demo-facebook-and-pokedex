//
//  MainPostCollectionViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/28.
//

import UIKit

class MainPostCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var imageView: UIImageView!
    static let identifier = "MainPostCollectionViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "MainPostCollectionViewCell", bundle: nil)
    }
    
    public func configure(with image: UIImage){
        imageView.image = image
    }

}
