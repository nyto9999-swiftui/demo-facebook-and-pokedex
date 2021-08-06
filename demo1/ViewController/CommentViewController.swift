//
//  CommentViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/6.
//

import UIKit



class CommentViewController: UIViewController {
    let data = ["a","b"]
    @IBOutlet weak var comment: UITextField!
    @IBOutlet weak var tableview: UITableView!
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
        // Do any additional setup after loading the view.
    }
    private func setup(){
        comment.addTarget(self, action: #selector(didTapEnter), for: UIControl.Event.primaryActionTriggered)
        
        
        tableview.register(CommentTableViewCell.nib(), forCellReuseIdentifier: CommentTableViewCell.identifier)
        tableview.delegate = self
        tableview.dataSource = self
    }
    @objc func didTapEnter() {
        guard let postID = UserDefaults.standard.string(forKey: "postID"),
              let sender = UserDefaults.standard.string(forKey: "name"),
              let senderIcon = UserDefaults.standard.string(forKey: "senderIcon") else {
            print("failed to get postID")
            return
        }
        let comment = Comment(sender: sender, txt: comment.text!, senderIcon: senderIcon)
        DatabaseManager.shared.insertComment(for: postID, comment: comment)
    }

}

extension CommentViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: CommentTableViewCell.identifier, for: indexPath) as! CommentTableViewCell
        cell.imageview.backgroundColor = .red
        cell.name.text! = data[indexPath.row]
        cell.txt.text! = ""
        return cell
    }
}
 
