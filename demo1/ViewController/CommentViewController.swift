//
//  CommentViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/6.
//

import UIKit



class CommentViewController: UIViewController {
    let post = ""
    var CommentFeed = [Comment]()
    
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var tableview: UITableView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        getAllComments()
        setup()
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        let postID = UserDefaults.standard.string(forKey: "postID")
    }
    public func setup(){
        comment.addTarget(self, action: #selector(didTapEnter), for: UIControl.Event.primaryActionTriggered)
        
        
        tableview.register(CommentTableViewCell.nib(), forCellReuseIdentifier: CommentTableViewCell.identifier)
        
        tableview.delegate = self
        tableview.dataSource = self
    }
    //textfield
    @objc func didTapEnter() {
        guard comment.text != nil else {
            print("empty comment ")
            return
        }
        guard let postID = UserDefaults.standard.string(forKey: "postID"),
              let sender = UserDefaults.standard.string(forKey: "name"),
              let senderIcon = UserDefaults.standard.string(forKey: "senderIcon") else {
            print("failed to get postID")
            return
        }
        let comment = Comment(commentID: UUID().uuidString, postID: postID, sender: sender, txt: comment.text!, senderIcon: senderIcon, createdAt: "")
        DatabaseManager.shared.insertComment(for: postID, comment: comment)
        
        DispatchQueue.main.async {
            
            
            self.CommentFeed.sort { $0.createdAt > $1.createdAt}
            self.tableview.reloadData()
        }
    }
    
    private func getAllComments(){
        guard let postID = UserDefaults.standard.string(forKey: "postID") else {
            return
        }
        DatabaseManager.shared.getAllComments(for: postID, completion: { [weak self]result in
            switch result {
            case .success(let comments):
                self?.CommentFeed = comments
                self?.CommentFeed.sort { $0.createdAt > $1.createdAt}
                self?.tableview.reloadData()
            case .failure(let error):
                print("\(error)" ?? "failed to get comments")
                self?.CommentFeed = []
            }
        })
    }

}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return CommentFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
        
        cell.configure(with: CommentFeed[indexPath.row])
        
        return cell
    }
}
 
