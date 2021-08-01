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
    var postsFeed:[Post] = []
    let refreshControl = UIRefreshControl()
    override func viewDidLoad() {
        super.viewDidLoad()
        //if not  users, back to login vc
        validateAuth()
        //get all posts from firebase postwall
        setup()
    }
    override func viewDidAppear(_ animated: Bool) {
        nameLabel.text = UserDefaults.standard.string(forKey: "name")
        let safeEmail = DatabaseManager.shared.getSafeString()
        //download profile img from db
        StorageManager.shared.getUIImageData(path: "profile/\(safeEmail)_profile_picture.png", for: profileImageView)
        getAllPosts()
    }
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        }
    }
    private func setup() {
       
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        tableView.register(MainPostTableViewCell.nib(), forCellReuseIdentifier: MainPostTableViewCell.identifier)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
    }
    private func getAllPosts() {
        DatabaseManager.shared.getAllPosts( completion: {[weak self] result in
            switch result {
            case .success(let posts):
                DispatchQueue.main.async {
                    self?.postsFeed = posts
                    self?.tableView.reloadData()
                    self?.refreshControl.endRefreshing()
                }
            case .failure(let error):
                print("\(error)")
                self?.refreshControl.endRefreshing()
            }
        })
    }
    @objc func refresh(_ sender: AnyObject){
        getAllPosts()
    }
    @IBAction func test(_ sender: Any) {
        print("aaaa \(self.postsFeed.count)")
        print(postsFeed[0].postID)
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainPostTableViewCell.identifier, for: indexPath) as! MainPostTableViewCell
        cell.configure(with: postsFeed[indexPath.row])
        return cell
    }
}













