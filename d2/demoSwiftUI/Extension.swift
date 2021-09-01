//
//  Extension.swift
//  demoSwiftUI
//
//  Created by 宇宣 Chen on 2021/8/26.
//

import SwiftUI




extension Color {
    static let lightShadow = Color(red: 255 / 255, green: 255 / 255, blue: 255 / 255)
    static let darkShadow = Color(red: 163 / 255, green: 177 / 255, blue: 198 / 255)
    static let background = Color(red: 219/255, green: 215/255, blue: 207/255)
    static let neumorphictextColor = Color(red: 132 / 255, green: 132 / 255, blue: 132 / 255)
    static let darkPink = Color(red: 208 / 255, green: 45 / 255, blue: 208 / 255)
    static let ivory = Color(red: 219/255, green: 215/255, blue: 207/255)
    static let lightBlue = Color(red: 206/255, green: 239/255, blue: 255/255)
    static let lightRed = Color(red: 255/255, green: 199/255, blue: 182/255)
    static let pink = Color(red: 255/255, green: 141/255, blue: 125/255)
    static let pokeRed = Color(red: 236/255, green: 105/255, blue: 102/255)
    static let pokeWhite = Color(red: 219/255, green: 215/255, blue: 207/255)
    
}

extension String {
    var isInt: Bool {
        return Int(self) != nil
    }
}


public extension String {
    subscript(value: Int) -> Character {
        self[index(at: value)]
    }
}

public extension String {
    subscript(value: NSRange) -> Substring {
        self[value.lowerBound..<value.upperBound]
    }
}

public extension String {
    subscript(value: CountableClosedRange<Int>) -> Substring {
        self[index(at: value.lowerBound)...index(at: value.upperBound)]
    }
    
    subscript(value: CountableRange<Int>) -> Substring {
        self[index(at: value.lowerBound)..<index(at: value.upperBound)]
    }
    
    subscript(value: PartialRangeUpTo<Int>) -> Substring {
        self[..<index(at: value.upperBound)]
    }
    
    subscript(value: PartialRangeThrough<Int>) -> Substring {
        self[...index(at: value.upperBound)]
    }
    
    subscript(value: PartialRangeFrom<Int>) -> Substring {
        self[index(at: value.lowerBound)...]
    }
}

private extension String {
    func index(at offset: Int) -> String.Index {
        index(startIndex, offsetBy: offset)
    }
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }

        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
