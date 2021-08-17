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
    @IBOutlet weak var userInforArea: UIView!
    var postsFeed:[Post] = []
    var test:[Comment] = []
    var array:[String] = []
    let refreshControl = UIRefreshControl()
    
    let zoomImageview = UIView()
    let startingFrame = CGRect(x: 50,y: 50,width: 200,height: 100)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        validateAuth()
        setup()
        getAllPosts()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
//        navigationController?.setNavigationBarHidden(true, animated: animated)
        tableView.reloadData()
    }
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
        DatabaseManager.shared.getAllMessages(with: "123-gmail-com_nyto4826-yahoo-com-tw") { Result in
            switch Result {
            case .success(let messages):
                print("f")
            case .failure(let error):
                print("err")
            }
        }
    }
}
let cellSpacingHeight: CGFloat = 5

//MARK:Talbeview
extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return cellSpacingHeight
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        
        return self.postsFeed.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let headerView = UIView()
        headerView.backgroundColor = UIColor.clear
        return headerView
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: MainPostTableViewCell.identifier, for: indexPath) as! MainPostTableViewCell
//        cell.postImageView.isUserInteractionEnabled = true
        cell.configure(with: postsFeed[indexPath.section])
        
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
        print("jfdklasjf\(sender.tag)")
        UserDefaults.standard.setValue("profile/\(safeEmail)_profile_picture.png", forKey: "senderIcon")
        print(postsFeed[sender.tag].postID)
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(identifier: "CommentViewController") as! CommentViewController
        present(vc, animated: true)
    }
    
   
    

}

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













