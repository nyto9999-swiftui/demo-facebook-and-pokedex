//
//  Comment.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/6.
//

import UIKit

struct Comment {
    let commentID: String
    let postID: String
    let sender: String
    let txt: String
    let senderIcon: String
    var createdAt: String
    
    var StringTime: Int {
        return Int(createdAt)!
    }
}
