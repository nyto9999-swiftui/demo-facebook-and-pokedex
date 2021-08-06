//
//  Post.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/1.
//

import Foundation
import UIKit

struct Post {
    let postID: String
    let profileImage: String
    let owner: String
    let txt: String
    var image: [UIImage]?
    
    
    var safePost: String {
        let safePostID = postID.replacingOccurrences(of: ".", with: "-")
        return safePostID
    }

    var postPictureName: String {
        return "post_picture"
    }
    
 
}
