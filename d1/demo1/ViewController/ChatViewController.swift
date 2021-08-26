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
        title = "Chat"
        talbeview.register(ChatTableViewCell.nib(), forCellReuseIdentifier: ChatTableViewCell.identifier)
        talbeview.delegate = self
        talbeview.dataSource = self
        getAllConversations()
    }
    
    //從Firebase/users/當前使用者的email/latestMessage讀取資料
    private func getAllConversations(){
        let user = UserDefaults.standard.string(forKey: "email")
        let safeUser = DatabaseManager.safeString(for: user!)
        print(safeUser)
        DatabaseManager.shared.getAllConversations(for: safeUser, completion: { [weak self] result in
            switch result {
            case .success(let conversations):
                self?.conversationFeed = conversations
                DispatchQueue.main.async {
                    self?.talbeview.reloadData()
                }
            case .failure(let error):
                print(error)

                DispatchQueue.main.async {
                    self?.talbeview.reloadData()
                }
            }
        })
    }
}


//MARK:Tableview
extension ChatViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationFeed.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = talbeview.dequeueReusableCell(withIdentifier: ChatTableViewCell.identifier, for: indexPath) as! ChatTableViewCell
        cell.configure(with: conversationFeed[indexPath.row])
        return cell
    }
    
    //Navigate to MSG VC
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let vc = MSGViewController(with: conversationFeed[indexPath.row].receiverEmail, id: conversationFeed[indexPath.row].id, receiverName: conversationFeed[indexPath.row].receiverName)
        
        vc.title = conversationFeed[indexPath.row].senderName
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
}
