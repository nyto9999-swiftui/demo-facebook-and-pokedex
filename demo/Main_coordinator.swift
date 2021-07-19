//
//  Main_coordinator.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import UIKit

final class Main_coordinator: Coordinator {
    private(set) var childCoordinators: [Coordinator] = []
    private let navigation_controller: UINavigationController
    
    init(navigation_controller: UINavigationController) {
        self.navigation_controller = navigation_controller
    }
    
    func start() {
        let main_viewcontroller = MainViewController.instantiate()
        navigation_controller.setViewControllers([main_viewcontroller], animated: false)
    }
}
