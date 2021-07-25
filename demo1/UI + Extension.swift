//
//  UI + Extension.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/23.
//

import Foundation
import UIKit

extension UIAlertController {
    
    func show() {
        present(animated: true, completion: nil)
    }
    
    func present(animated: Bool, completion: (() -> Void)?) {
        if let rootVC = UIApplication.shared.keyWindow?.rootViewController {
            presentFromController(controller: rootVC, animated: animated, completion: completion)
        }
    }
    
    private func presentFromController(controller: UIViewController, animated: Bool, completion: (() -> Void)?) {
        if
            let navVC = controller as? UINavigationController,
            let visibleVC = navVC.visibleViewController
        {
            presentFromController(controller: visibleVC, animated: animated, completion: completion)
        } else if
            let tabVC = controller as? UITabBarController,
            let selectedVC = tabVC.selectedViewController
        {
            presentFromController(controller: selectedVC, animated: animated, completion: completion)
        } else if let presented = controller.presentedViewController {
            presentFromController(controller: presented, animated: animated, completion: completion)
        } else {
            controller.present(self, animated: animated, completion: completion);
        }
    }
}

extension UIView {

    public var width: CGFloat {
        return frame.size.width
    }

    public var height: CGFloat {
        return frame.size.height
    }

    public var top: CGFloat {
        return frame.origin.y
    }

    public var bottom: CGFloat {
        return frame.size.height + frame.origin.y
    }

    public var left: CGFloat {
        return frame.origin.x
    }

    public var right: CGFloat {
        return frame.size.width + frame.origin.x
    }

}
