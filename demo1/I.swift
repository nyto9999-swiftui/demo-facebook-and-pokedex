//
//  I.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/1.
//

import Foundation
import UIKit

class I {
    static let use = I()
    
    public func getUIImageData(path: String, for imgview: UIImageView) -> Void{
        let ref = StorageManager.shared.reference.reference(withPath: path)
        ref.getData(maxSize: 1 * 1024 * 1024, completion: { [weak self] data, error in
            guard let data = data else {
                print(error ?? "failed to getData")
                return
            }
            imgview.image = UIImage(data: data)
        })
    }
}
