//
//  ChatViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/10.
//

import UIKit

class UserSearchViewController: UIViewController {
    var txt = ""
    var userFound = [AppUser]()
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.width, height: 20))
    @IBOutlet weak var tableview: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setup()
    }
    
    
    private func setup(){
        tableview.register(ChatSearchUserTableViewCell.nib(), forCellReuseIdentifier: ChatSearchUserTableViewCell.identifier)
        tableview.delegate = self
        tableview.dataSource = self
        
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        
        self.navigationItem.leftItemsSupplementBackButton = true
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        searchBar.delegate = self
        
    }

}
extension UserSearchViewController: UITableViewDelegate,UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userFound.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableview.dequeueReusableCell(withIdentifier: ChatSearchUserTableViewCell.identifier, for: indexPath) as! ChatSearchUserTableViewCell
    
        cell.configure(with: userFound[indexPath.row])
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let model = userFound[indexPath.row]
        let vc = MSGViewController(with: model.safeEmail, id: nil)
        vc.title = model.name
        vc.navigationItem.largeTitleDisplayMode = .never
        navigationController?.pushViewController(vc, animated: true)
    }
    
    
}

extension UserSearchViewController: UISearchBarDelegate  {
    func searchBarTextDidBeginEditing(_ searchBar: UISearchBar) {
        
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(searchUser), with: searchText, afterDelay: 0.5)
        txt = searchText
        if txt == ""{
            self.userFound = []
            self.tableview.reloadData()
        }
    }
    
    @objc func searchUser(){
        DatabaseManager.shared.getALlUsers(completion: { [weak self] result in
            switch result{
            case .success(let appUser):
                for eachUser in appUser {
                    if eachUser.name == (self?.txt.lowercased())! {
                        self?.userFound.append(eachUser)
                        self?.tableview.reloadData()
                    }
                }
            case .failure(let err):
                print(err)
                
            }
        })
        
        
    }
}


