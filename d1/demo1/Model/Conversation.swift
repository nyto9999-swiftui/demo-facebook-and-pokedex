//
//  Conversation.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/18.
//

import Foundation

struct Conversation {
    let id: String
    let senderName: String
    let receiverName: String
    let receiverEmail: String // for downloading icon image 
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
