//
//  Main_ViewController.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/18.
//

import UIKit
import FirebaseAuth
class Main_ViewController: UIViewController {
    
    
    static func instantiate() -> Main_ViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(identifier: "Main_ViewController") as! Main_ViewController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validate_auth()
        setup()
        
    }
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func tapped_right_barbutton(){
        print("yes")
    }
    
    private func setup(){
        let plus_image = UIImage(systemName: "plus.circle.fill")
        let bar_buttonitem = UIBarButtonItem(image: plus_image, style: .plain, target: self, action: #selector(tapped_right_barbutton))
        bar_buttonitem.tintColor = .primary
        navigationItem.rightBarButtonItem = bar_buttonitem
        navigationItem.title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = true
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
