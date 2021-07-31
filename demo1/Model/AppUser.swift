//
//  AppUser.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/1.
//
import UIKit
struct AppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
