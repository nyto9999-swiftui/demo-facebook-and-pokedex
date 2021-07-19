//
//  App_coordinator.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import UIKit

protocol Coordinator {
    var childCoordinators: [Coordinator] {get}
    func start()
        
}

final class App_coordinator: Coordinator {
    private(set) var childCoordinators: [Coordinator] = []
    
    private let window: UIWindow
    
    init(window:UIWindow) {
        self.window = window
    }
    func start() {
        let navigationController = UINavigationController()
        
        let main_coordinator = Main_coordinator(navigation_controller: navigationController)
        childCoordinators.append(main_coordinator)
        main_coordinator.start()
        
        window.rootViewController = navigationController
        window.makeKeyAndVisible()
    }
}
