//
//  Main_ViewController.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/18.
//

import UIKit
import FirebaseAuth
class MainViewController: UIViewController {
    
    private let tableView: UITableView = {
        let tableview = UITableView()
        tableview.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return tableview
    }()
    let data = ["log out"]
    
    static func instantiate() -> MainViewController {
        let storyboard = UIStoryboard(name: "Main", bundle: .main)
        let controller = storyboard.instantiateViewController(identifier: "MainViewController") as! MainViewController
        return controller
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(tableView)
        tableView.delegate = self
        tableView.dataSource = self
        
        validate_auth()
        setup()
    }
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        tableView.frame = view.bounds
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
    }
    
    @objc private func tapped_right_barbutton(){
        print("yes")
    }
    
    private func setup(){
        let plus_image = UIImage(systemName: "plus.circle.fill")
        let bar_buttonitem = UIBarButtonItem(image: plus_image, style: .plain, target: self, action: #selector(tapped_right_barbutton))
        bar_buttonitem.tintColor = .primary
        navigationItem.rightBarButtonItem = bar_buttonitem
        navigationItem.title = "Main"
        navigationController?.navigationBar.prefersLargeTitles = true
        
    }
    
    private func validate_auth(){
        
        if FirebaseAuth.Auth.auth().currentUser == nil {
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        }
    }
    
    
    
    
}

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = data[indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        do {
            try FirebaseAuth.Auth.auth().signOut()
            let vc = LoginViewController()
            let nav = UINavigationController(rootViewController: vc)
            nav.modalPresentationStyle = .fullScreen
            present(nav, animated: false)
        } catch {
            print("Failed to log out")
        }
        
        
        
    }
    
    
}
