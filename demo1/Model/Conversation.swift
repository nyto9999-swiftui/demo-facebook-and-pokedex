//
//  Conversation.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/18.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMessage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
