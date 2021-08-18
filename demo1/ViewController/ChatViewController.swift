//
//  ChatViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/18.
//

import UIKit

class ChatViewController: UIViewController {
    var conversationFeed = [Conversation]()
    @IBOutlet weak var talbeview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        talbeview.register(ChatTableViewCell.nib(), forCellReuseIdentifier: ChatTableViewCell.identifier)
        talbeview.delegate = self
        talbeview.dataSource = self
        getAllConversations()
    }
    private func getAllConversations(){
        let user = UserDefaults.standard.string(forKey: "email")
        let safeUser = DatabaseManager.safeString(for: user!)
        print(safeUser)
        DatabaseManager.shared.getAllConversations(for: safeUser, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversationFeed = conversations
                self?.talbeview.reloadData()
            case .failure(let error):
                print(error)
            }
        })
    }
}



extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = talbeview.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        cell.configure(with: conversationFeed[indexPath.row])
        return cell
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MSGViewController(with: conversationFeed[indexPath.row].otherUserEmail, id: conversationFeed[indexPath.row].id
                                   
        )
        vc.title = conversationFeed[indexPath.row].name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}
