//
//  Main_ViewController.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/18.
//

import UIKit
import FirebaseAuth
class Main_ViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .red
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        validate_auth()
    }
    
    private func validate_auth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = Login_ViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    
    
    
}
