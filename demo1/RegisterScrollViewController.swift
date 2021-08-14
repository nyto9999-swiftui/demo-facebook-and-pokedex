//
//  RegisterScrollViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/8/12.
//

import UIKit

class RegisterScrollViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterScrollViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(RegisterScrollViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
          }
    
    @objc func keyboardWillShow(notification: NSNotification) {
       guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue
       else {
         // if keyboard size is not available for some reason, dont do anything
         return
       }

       let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: keyboardSize.height , right: 0.0)
       scrollView.contentInset = contentInsets
       scrollView.scrollIndicatorInsets = contentInsets
     }

     @objc func keyboardWillHide(notification: NSNotification) {
       let contentInsets = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
           
       
       // reset back the content inset to zero after keyboard is gone
       scrollView.contentInset = contentInsets
       scrollView.scrollIndicatorInsets = contentInsets
     }
    }


    



