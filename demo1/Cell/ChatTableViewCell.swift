//
//  ChatTableViewCell.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/17.
//

import UIKit

class ChatTableViewCell: UITableViewCell {
    static let identifier = "ChatTableViewCell"
    
    static func nib() -> UINib {
        return UINib(nibName: "ChatTableViewCell", bundle: nil)
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        backgroundColor = .red
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}
