//
//  ViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/22.
//
import UIKit
import SwiftUI
import FirebaseAuth
import FBSDKLoginKit

class MainViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var postsFeed:[Post] = []
    let refreshControl = UIRefreshControl()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        validateAuth()
        setup()
        getAllPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        DispatchQueue.main.async {
            self.tableView.reloadData()
        }
    }
    
    /// 準備圖片給PostVC 的 profile icon
    @IBAction func createPost(_ sender: Any) {
        performSegue(withIdentifier: "createPost", sender: nil)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "createPost" {
            print("yes")
            let destination = segue.destination as! PostViewController
            destination.segueImage = self.profileImageView.image
        }
    }
    
    // 如果不是Firebase認證的使用者,回到LoginVC
    private func validateAuth(){
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
            present(vc, animated: true)
        }
    }
    
    // 基本設定
    private func setup() {
        nameLabel.text = UserDefaults.standard.string(forKey: "name")
        let safeEmail = DatabaseManager.shared.getSafeString()
        //download profile img from db
        StorageManager.shared.getUIImageData(path: "profile/\(safeEmail)_profile_picture.png", for: profileImageView)
        
        //profile imageview tapgesture
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapProfileImage))
        profileImageView.isUserInteractionEnabled = true
        profileImageView.addGestureRecognizer(gesture)
        
        //refresh
        refreshControl.attributedTitle = NSAttributedString(string: "Pull to refresh")
        refreshControl.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)
        
        //tableview
        tableView.register(MainPostTableViewCell.nib(), forCellReuseIdentifier: MainPostTableViewCell.identifier)
        tableView.addSubview(refreshControl)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .systemGray2
        getAllPosts()
    }
    
    @objc func refresh(_ sender: AnyObject){
        getAllPosts()
        DispatchQueue.main.async {
            self.refreshControl.endRefreshing()
        }
    }
    
    /// 從Firebase獲取全部貼文
    private func getAllPosts() {
        DatabaseManager.shared.getAllPosts( completion: {[weak self] gotPosts in
            switch gotPosts {
            case .success(let posts):
                guard posts.count == self?.postsFeed.count else {
                    self?.postsFeed = posts
                    self?.postsFeed.sort { $0.postID < $1.postID}
                    DispatchQueue.main.async {
                        self?.tableView.reloadData()
                    }
                    return
                }
            case .failure(let error):
                self?.postsFeed = []
                print(error)
            }
        })
    }
}


//MARK:Talbeview
let cellSpacingHeight: CGFloat = 5
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
 
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.postsFeed.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
 
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let footerView = UIView()
        footerView.backgroundColor = UIColor.clear
        return footerView
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainPostTableViewCell.identifier, for: indexPath) as! MainPostTableViewCell

        cell.configure(with: postsFeed[indexPath.section])
        print(postsFeed.count)
        //add border and color
        cell.backgroundColor = UIColor.white
        
        //comment button
        cell.commentButton.tag = indexPath.section
        cell.commentButton.addTarget(self, action: #selector(goComment), for: UIControl.Event.touchUpInside)
        
    
        //delete button
        cell.deleteButton.tag = indexPath.section
        cell.deleteButton.addTarget(self, action: #selector(goDelete), for: UIControl.Event.touchUpInside)
        return cell
    }
    
    // cellForRowAt buttons
    @objc func goDelete(sender: UIButton){
        DatabaseManager.shared.deletePost(for: postsFeed[sender.tag].postID)
        StorageManager.shared.removePostImage(path: postsFeed[sender.tag].postID)
        postsFeed.remove(at: sender.tag)
        tableView.reloadData()
    }
    @objc func goComment(sender: UIButton) {
        let safeEmail = DatabaseManager.shared.getSafeString()
        UserDefaults.standard.setValue(postsFeed[sender.tag].postID, forKey: "postID")

        UserDefaults.standard.setValue("profile/\(safeEmail)_profile_picture.png", forKey: "senderIcon")
        print(postsFeed[sender.tag].postID)

        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CommentViewController") as! CommentViewController
        present(vc, animated: true)
    }
}

//點擊profile icon 登出
extension MainViewController:UIScrollViewDelegate{
    @objc func didTapProfileImage(){
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        //log out
        let action = UIAlertAction(title: "Logout", style: .default, handler: { UIAlertAction in
            if AccessToken.current != nil {
                let loginManager = LoginManager()
                loginManager.logOut()
            }
            do {
                try FirebaseAuth.Auth.auth().signOut()
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let vc = storyboard.instantiateViewController(identifier: "LoginViewController") as! LoginViewController
                self.present(vc, animated: true)
            } catch  {
                print("Failed to log out")
            }
        })
        alert.addAction(action)
        
        present(alert, animated: true, completion: {
            alert.view.superview?.isUserInteractionEnabled = true
            alert.view.superview?.subviews[0].addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.alertSheetDismiss)))
        })
    }
    @objc func alertSheetDismiss(){
        self.dismiss(animated: true, completion: nil)
    }
}













