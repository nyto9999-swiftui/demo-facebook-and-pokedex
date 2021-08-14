//
//  ChatViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/10.
//

import UIKit

class ChatViewController: UIViewController {
    var txt = ""
    lazy var searchBar:UISearchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.width, height: 20))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    private func setup(){
        
        let leftNavBarButton = UIBarButtonItem(customView: searchBar)
        self.navigationItem.leftBarButtonItem = leftNavBarButton
        searchBar.delegate = self
        
    }

}
extension ChatViewController: UISearchBarDelegate  {
    
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        NSObject.cancelPreviousPerformRequests(withTarget: self)
        self.perform(#selector(test), with: searchText, afterDelay: 0.5)
        txt = searchText
    }
    
    @objc func test(){
        print("\(txt)")
        view.backgroundColor = .red
    }
    
}
