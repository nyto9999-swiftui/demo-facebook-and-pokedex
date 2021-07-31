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
    var postsFeed:[Post] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
        getAllPosts()
        nameLabel.text = UserDefaults.standard.string(forKey: "name")
        safeEmail = DatabaseManager.shared.getSafeString()
        //profile img
        StorageManager.shared.getUIImageData(path: "profile/\(safeEmail)_profile_picture.png", for: profileImageView)
        
        tableView.register(MainPostTableViewCell.nib(), forCellReuseIdentifier: MainPostTableViewCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        
//        tableView.rowHeight = UITableView.automaticDimension
      
    }
    
    var layout: UICollectionViewFlowLayout = {
        let layout = UICollectionViewFlowLayout()
        let width = UIScreen.main.bounds.size.width
        layout.estimatedItemSize = CGSize(width: width, height: 10)
        return layout
    }()
   
  
    private func validateAuth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        }
        
    }
    @IBAction func test(_ sender: Any) {
        print("aaaa \(self.postsFeed.count)")
        print(postsFeed[0].postID)
    }
    
    private func getAllPosts() {
        DatabaseManager.shared.getAllPosts( completion: {[weak self] result in
            switch result {
            case .success(let posts):
                
                DispatchQueue.main.async {
                    self?.postsFeed = posts
                    self?.tableView.reloadData()
                }
                
            case .failure(let error):
                print("\(error)")
            }
        })
    }

}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        print("bbbbb \(self.postsFeed.count)")
        return self.postsFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainPostTableViewCell.identifier, for: indexPath) as! MainPostTableViewCell
        
//        downloadSingleImage(for: posts[indexPath.row].profileImage, imgview: cell.profileImageView)
        cell.configure(with: postsFeed[indexPath.row])
        cell.textview.text = postsFeed[indexPath.row].txt
        cell.postownerLable.text = postsFeed[indexPath.row].owner
        return cell
    }
    
    
}













