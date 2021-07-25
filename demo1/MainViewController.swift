//
//  ViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/22.
//
import UIKit
import SwiftUI
import FirebaseAuth


class MainViewController: UIViewController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
    }
   
    @IBAction func didTapPost(_ sender: Any) {
        
       
    }
    private func validateAuth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        }
        
    }
}







