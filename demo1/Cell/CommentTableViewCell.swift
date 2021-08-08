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
        
        //time difference
        let time = CommentFeed?.createdAt
        let difference = dateformatter(date: Double(time!)!)
        if difference != nil {
            self.createdAt.text = difference
        }
        
        //Icon image
        if let senderIconString = CommentFeed?.senderIcon {
            StorageManager.shared.getUIImageForCell(path: senderIconString, imgview: self.imageview)
        }
    }
    
    func dateformatter(date: Double) -> String {

        let date1:Date = Date() // Same you did before with timeNow variable
        let date2: Date = Date(timeIntervalSince1970: date)

        let calender:Calendar = Calendar.current
        let components: DateComponents = calender.dateComponents([.year, .month, .day, .hour, .minute, .second], from: date2, to: date1)
        print(components)
        var returnString:String = ""
        
        if components.year! >= 1 {
            returnString = String(describing: components.year!)+"  年前"
        }else if components.month! >= 1{
            returnString = String(describing: components.month!)+" 個月前"
        }else if components.day! >= 1{
            returnString = String(describing: components.day!) + " 天前"
        }else if components.hour! >= 1{
            returnString = String(describing: components.hour!) + " 小時前"
        }else if components.minute! >= 1{
            returnString = String(describing: components.minute!) + " 分鐘前"
        }else if components.second! >= 1{
            returnString = "剛剛"
        }

        return returnString
    }
}
