//
//  SceneDelegate.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/18.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var app_coordinator: App_coordinator?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        
        guard let scene = (scene as? UIWindowScene) else { return }
        let window = UIWindow(windowScene: scene)
        self.window = window
        
        self.app_coordinator = App_coordinator(window: window)
        app_coordinator?.start()
    }

   
   


}

