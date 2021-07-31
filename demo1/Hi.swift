//
//  I.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/1.
//

import Foundation
import UIKit

class Hi {
    static let use = Hi()
    
    public enum DatabaseError: Error {
        case failedToFetch
        case failedToGetData
        case observeSingleEvent
    }
}
