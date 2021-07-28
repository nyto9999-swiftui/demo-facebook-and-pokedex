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
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var profileImageView: UIImageView!
    
    @IBOutlet weak var nameLabel: UILabel!
    var safeEmail = ""
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
        tableView.delegate = self
        tableView.dataSource = self
        nameLabel.text = UserDefaults.standard.string(forKey: "name")
        safeEmail = getSafeEmail()
        fetchImage(imageView: profileImageView)
        tableView.register(MainTableViewCell.nib(), forCellReuseIdentifier: MainTableViewCell.identifier)
        tableView.rowHeight = UITableView.automaticDimension
        
    }
    
    private func fetchImage(imageView: UIImageView){
        let fileName = "1_" + safeEmail + "_profile_picture.png"
        let path = "image/"+fileName
        StorageManager.shared.downloadUrl(for: path, completion: { [weak self] result in
            switch result {
            case .success(let url):
            self?.downloadProfileImage(imageView: imageView, url: url)
            case.failure(let error):
                print("Failed to get download url: \(error)")
            }
        })
    }
    private func downloadProfileImage(imageView: UIImageView, url: URL) {
        
        URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
            guard let data = data, error == nil else {
                return
            }
            DispatchQueue.main.async {
                let image = UIImage(data: data)
                self.profileImageView.image = image
            }
        }).resume()
    }
   
    private func getSafeEmail() -> String {
        let email = UserDefaults.standard.string(forKey: "email")
        let safe = DatabaseManager.safeEmail(emailAddress: email!)
        return safe
    }
  
    private func validateAuth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        }
        
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 10
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainTableViewCell.identifier, for: indexPath) as! MainTableViewCell
        
        return cell
    }
    
 
}







