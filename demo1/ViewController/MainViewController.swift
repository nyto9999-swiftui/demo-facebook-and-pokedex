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
    var test:[Comment] = []
    var array:[String] = []
    let refreshControl = UIRefreshControl()
    let safeEmail = DatabaseManager.shared.getSafeString()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
        setup()
        getAllPosts()
        
    }
    
    //if not  users, back to login vc
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        }
    }
    
    private func setup() {
        nameLabel.text = UserDefaults.standard.string(forKey: "name")
        //download profile img from db
        StorageManager.shared.getUIImageData(path: "profile/\(safeEmail)_profile_picture.png", for: profileImageView)
       
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        
        tableView.register(MainPostTableViewCell.nib(), forCellReuseIdentifier: MainPostTableViewCell.identifier)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        getAllPosts()
        
    }
    @objc func refresh(_ sender: AnyObject){
        getAllPosts()
        refreshControl.endRefreshing()
        tableView.reloadData()
    }
    
    private func getAllPosts() {
        DatabaseManager.shared.getAllPosts( completion: {[weak self] gotPosts in
            switch gotPosts {
            case .success(let posts):
                guard posts.count == self?.postsFeed.count else {
                    self?.postsFeed = posts
                    self?.postsFeed.sort { $0.postID < $1.postID}
                    self?.tableView.reloadData()
                    return
                }
            case .failure(let error):
                self?.postsFeed = []
                print(error)
            }
        })
    }
    
    
    
    @IBAction func test(_ sender: Any) {
        StorageManager.shared.removePostImage(path: "nyto4826-yahoo-com-tw_1628422340-713126/")
        
        
    }
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.postsFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainPostTableViewCell.identifier, for: indexPath) as! MainPostTableViewCell
        
        cell.configure(with: postsFeed[indexPath.row])
        
        //comment button
        cell.commentButton.tag = indexPath.row
        cell.commentButton.addTarget(self, action: #selector(goComment), for: UIControl.Event.touchUpInside)
        
    
        //delete button
        cell.deleteButton.tag = indexPath.row
        cell.deleteButton.addTarget(self, action: #selector(goDelete), for: UIControl.Event.touchUpInside)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
    }
    @objc func goDelete(sender: UIButton){
        DatabaseManager.shared.deletePost(for: postsFeed[sender.tag].postID)
        StorageManager.shared.removePostImage(path: postsFeed[sender.tag].postID)
        postsFeed.remove(at: sender.tag)
        tableView.reloadData()
    }
    
    
    @objc func goComment(sender: UIButton) {
        UserDefaults.standard.setValue(postsFeed[sender.tag].postID, forKey: "postID")
        print(sender.tag)
        UserDefaults.standard.setValue("profile/\(safeEmail)_profile_picture.png", forKey: "senderIcon")
        print(postsFeed[sender.tag].postID)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CommentViewController") as! CommentViewController
        present(vc, animated: true)
    }
}













