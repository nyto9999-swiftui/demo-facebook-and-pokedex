//
//  ProfileViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
class ProfileViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let data = ["log out"]
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = "Profile"
        
    }
}

extension ProfileViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        if AccessToken.current != nil {
            let loginManager = LoginManager()
            loginManager.logOut()
        }
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        } catch  {
            print("Failed to log out")
        }
        
    }
    
    
}
