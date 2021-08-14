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
        setup()
        
    }
    
    private func setup(){
        emailTextfield.textfieldImage(imageName: "envelope")
        passwordTextfield.textfieldImage(imageName: "key")
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
    }

    
    @IBAction func didTapFacebook(_ sender: Any) {
        let loginButton = FBLoginButton()
        loginButton.delegate = self
        loginButton.permissions = ["public_profile", "email"]
        loginButton.isHidden = true
        loginButton.sendActions(for: .touchUpInside)
        self.view.addSubview(loginButton)
        
    }
    
    @IBAction func didTapLogin(_ sender: Any) {
        guard let email = emailTextfield.text, let password = passwordTextfield.text, !email.isEmpty, !password.isEmpty else {
            print("login validation fail")
            return
        }
        // MARK: - Firebase signIn
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { [weak self] authResult, error in
            guard error == nil else {
                print("Failed to log in user with email: \(email)")
                return
            }
            
            let safeEmail = DatabaseManager.safeString(for: email)
            UserDefaults.standard.set(email, forKey: "email")
            DatabaseManager.shared.getUsername(path: safeEmail, completion: { result in
                switch result {
                case .success(let username):
                    UserDefaults.standard.set("\(username)",forKey: "name")
                case .failure(let error):
                    print("Failed to read data with error \(error)")
                }
            })
            self?.dismiss(animated: true, completion: nil)
        })
    }
    
    
    
}


// MARK: Facebook LogIn
extension LoginViewController: LoginButtonDelegate {
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
                            //upload profile image
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
                                
                                StorageManager.shared.uploadSinglePicture(with: data, path: "profile", fileName: filename, completion: { result in
                                    switch result {
                                    case .success(let downloadUrl):
                                        // MARK: UserDefault(profile_picture_url)
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
                    guard authResult != nil, error == nil else {
                        print("Facebook credential login failed, MFA may be needed")
                        return
                    }
                    print("Successfully logged user in")
                    //dismiss
                    self?.dismiss(animated: true, completion: nil)
                })
            })
        })
    }
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation
    }
}


extension  UITextField {
    func textfieldImage(imageName:String) {
        let padding = 10
        let size = 25
        let outerView = UIView(frame: CGRect(x: 0, y: 0, width: size+padding+5, height: size) )
        let iconView  = UIImageView(frame: CGRect(x: padding, y: 0, width: size, height: size))
        iconView.image = UIImage(systemName: imageName)
        outerView.addSubview(iconView)
        leftView = outerView
        leftViewMode = .always
    }
}

extension LoginViewController {
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
