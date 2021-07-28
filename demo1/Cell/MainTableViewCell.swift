//
//  MainTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/28.
//

import UIKit

class MainTableViewCell: UITableViewCell, UITextViewDelegate {

    @IBOutlet weak var txtview: UITextView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    static let identifier = "MainTableViewCell"
    override func awakeFromNib() {
        super.awakeFromNib()
        imageView?.image = UIImage(named: "bg")
        txtview.translatesAutoresizingMaskIntoConstraints = true
        txtview.sizeToFit()
        txtview.isScrollEnabled = false
        txtview.isEditable = false
        collectionView.frame = contentView.bounds
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 10, left: 0, bottom: 10, right: 0)
        layout.minimumLineSpacing = 5
        collectionView.collectionViewLayout = layout
        collectionView.register(MainPostCollectionViewCell.nib(), forCellWithReuseIdentifier: MainPostCollectionViewCell.identifier)
        collectionView.delegate = self
        collectionView.dataSource = self
        // Initialization code
    }

    static func nib() -> UINib {
        return UINib(nibName: "MainTableViewCell", bundle: nil)
    }
}
extension MainTableViewCell: UICollectionViewDelegate, UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 2
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MainPostCollectionViewCell.identifier, for: indexPath) as! MainPostCollectionViewCell
        
        cell.configure(with: (imageView?.image! ?? UIImage(named: "bg"))!)
        return cell
    }
    
    
}

