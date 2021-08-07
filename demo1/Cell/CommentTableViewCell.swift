//
//  CommentTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/6.
//

import UIKit

class CommentTableViewCell: UITableViewCell {
    var CommentFeed: Comment?
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var txt: UILabel!
    @IBOutlet weak var createdAt: UILabel!
    
    static let identifier = "CommentTableViewCell"
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    static func nib() -> UINib {
        return UINib(nibName: "CommentTableViewCell", bundle: nil)
    }
    
    func configure(with model: Comment){
        self.CommentFeed = model
        //MARK: fix time difference
        self.name.text = CommentFeed?.sender
        self.txt.text = CommentFeed?.txt
        let time = CommentFeed?.createdAt
        
        let date = Date(timeIntervalSinceReferenceDate: Double(time!)!)
        let df = DateFormatter()
        df.dateFormat = "yyyy/MM/dd hh:mm:ss"
        self.createdAt.text = df.string(from: date)
        
        if let senderIconString = CommentFeed?.senderIcon {
            StorageManager.shared.getUIImageForCell(path: senderIconString, imgview: self.imageview)
        }
    }
    
    
}
extension Date {

    static func - (lhs: Date, rhs: Date) -> TimeInterval {
        return lhs.timeIntervalSinceReferenceDate - rhs.timeIntervalSinceReferenceDate
    }

}
