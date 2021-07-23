//
//  LoginViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/22.
//

import UIKit
import FirebaseAuth
import FBSDKLoginKit
class LoginViewController: UIViewController {
  
    
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!
    @IBOutlet weak var fbButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        emailTextfield.setLeftImage(imageName: "envelope")
        passwordTextfield.setLeftImage(imageName: "key")
  
    }
    @IBAction func didTapFacebook(_ sender: Any) {
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        loginButton.isHidden = true
        self.view.addSubview(loginButton)
        loginButton.sendActions(for: .touchUpInside)
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text, !email.isEmpty, !password.isEmpty else {
            print("login validation fail")
            return
        }
        
        // MARK: - Firebase signIn
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in

            guard let result = authResult, error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            let user = result.user
            let safeEmail = DatabaseManager.safeEmail(emailAddress: email)
            DatabaseManager.shared.getDataFor(path: safeEmail, completion: { [weak self] result in
                switch result {
                case .success(let data):
                    guard let userData = data as? [String: Any],
                          let firstName = userData["first_name"] as? String,
                          let lastName = userData["last_name"] as? String else {
                        return
                    }
                    UserDefaults.standard.set("\(firstName) \(lastName)",forKey: "name")
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            UserDefaults.standard.set(email, forKey: "email")
            
            print("Logged In User: \(user)")
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    
  
}

extension UITextField {
    func setLeftImage(imageName:String) {
        let padding = 10
        let size = 25
        
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding+5, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = UIImage(systemName: imageName)
        outerView.addSubview(iconView)
        
        leftView = outerView
        leftViewMode = .always         }
}
// MARK: Facebook LogIn Button
extension LoginViewController: LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard  let token = result?.token?.tokenString else {
            print("User failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields": "email, first_name, last_name, picture.type(large)"], tokenString: token, version: nil, httpMethod: .get)
        
        facebookRequest.start(completion: { _, result, error in
            guard let result = result as? [String:Any], error == nil else {
                print("Failed to make facebook graph request")
                return
            }
            
            print(result)
            guard let firstName = result["first_name"] as? String,
                  let lastName = result["last_name"] as? String,
                  let email = result["email"] as? String,
                  let picture = result["picture"] as? [String:Any],
                  let data = picture["data"] as? [String:Any],
                  let pictureUrl = data["url"] as? String else {
                print("Failed to get email and anme from fb result")
                return
            }
            //MARK: - UserDefault(email name)
            UserDefaults.standard.set(email, forKey: "email")
            UserDefaults.standard.set("\(firstName) \(lastName)",forKey: "name")
            
            DatabaseManager.shared.userExists(with: email, completion: {exsits in
                if !exsits {
                    
                    let appUser = AppUser(firstName: firstName, lastName: lastName, emailAddress: email)
                    DatabaseManager.shared.insertUser(with: appUser, completion: { success in
                        if success {
                            //upload image
                            guard let url = URL(string: pictureUrl) else {
                                return
                            }
                            
                            print("Downloading data from facebook image")
                            
                            // tranfer url to data
                            URLSession.shared.dataTask(with: url, completionHandler: { data, _, error in
                                guard let data = data else {
                                    print("Failed to get data from facebook")
                                    return
                                }
                                
                                print("got data from FB, uploading...")
                                
                                let filename = appUser.profilePictureName
                                StorageManager.shared.uploadProfilePicture(with: data, fileName: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                        print(downloadUrl)
                                    case .failure(let error):
                                        print("Storage maanger error: \(error)")
                                    }
                                })
                            }).resume()
                            
                        }
                    })
                }
                let credential = FacebookAuthProvider.credential(withAccessToken: token)
                FirebaseAuth.Auth.auth().signIn(with: credential, completion: { [weak self] authResult, error in
                    
                    guard let strongSelf = self else {
                        return
                    }
                    
                    guard authResult != nil, error == nil else {
                        if let error = error {
                            print("Facebook credential login failed, MFA may be needed")
                        }
                        return
                    }
                    print("Successfully logged user in")
                    self?.dismiss(animated: true, completion: nil)
                })
            })
            
            
        })
        
        
    }
    
    
}
