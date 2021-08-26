//
//  RegisterViewController.swift
//  demo1
//
//  Created by 宇宣 Chen on 2021/7/23.
//

import UIKit
import FirebaseAuth

class RegisterViewController: UIViewController {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var emailTextfield: UITextField!
    @IBOutlet weak var firstNameTextfield: UITextField!
    @IBOutlet weak var lastNameTextfield: UITextField!
    @IBOutlet weak var passwordTextfield: UITextField!

    var activeTextField : UITextField? = nil
    override func viewDidLoad() {
        super.viewDidLoad()
        setup()
    }
    
    /// 基本設定
    private func setup(){
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPicture))
        imageView.addGestureRecognizer(gesture)
        
        emailTextfield.delegate = self
        firstNameTextfield.delegate = self
        lastNameTextfield.delegate = self
        passwordTextfield.delegate = self
        
        let tap = UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        view.addGestureRecognizer(tap)
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(RegisterViewController.keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    
    
    /// 點擊頭像彈出Photo libary action sheet
    @objc private func didTapPicture(){
        presentPhotoActionSheet()
    }
    
    /// 點擊註冊按鈕
    /// 簡單的validation -> 確認是否重複註冊到Firebase -> Firebase用戶註冊 -> Insert 用戶到Firebase -> 上傳頭像到Storage -> dismiss
    @IBAction func didTapSignup(_ sender: Any) {
        guard let firstname = firstNameTextfield.text,
              let lastname = lastNameTextfield.text,
              let email = emailTextfield.text,
              let password = passwordTextfield.text,
              !email.isEmpty,
              !password.isEmpty,
              !firstname.isEmpty,
              !lastname.isEmpty else {
            let alertController = UIAlertController(title: "Error", message: "Invalid input", preferredStyle: .alert)
            alertController.show()
            return
        }
        
        //MARK: - Firebase
        DatabaseManager.shared.userExists(with: email, completion: { [weak self] exist in
            // check if email exist
            guard !exist else {
                print("Email exist")
                return
            }
            // create firebase user
            FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: { authResult, error in
                guard authResult != nil, error == nil else {
                    print("Firebase create user fail")
                    return
                }
                UserDefaults.standard.setValue(email, forKey: "email")
                UserDefaults.standard.setValue("\(firstname)\(lastname)", forKey: "name")
                // inser user data to db
                let appUser = AppUser(name: firstname+lastname, emailAddress: email)
                DatabaseManager.shared.insertUser(with: appUser, completion: { success in
                    if success {
                        
                        guard let image = self?.imageView.image,
                              let data = image.pngData() else {
                            return
                        }
                        let fileName = appUser.profilePictureName //"\(safeEmail)_profile_picture.png"
                        //upload profile picture
                        StorageManager.shared.uploadSinglePicture(with: data, path: "profile", fileName: fileName, completion: { result in
                            switch result {
                            case.success(let downloadUrl):
                                UserDefaults.standard.set(downloadUrl, forKey: "profile_picture_url")
                                print(downloadUrl)
                            case.failure(let error):
                                print("Storage manager error: \(error)")
                            }
                        })
                    }
                })
                self?.dismiss(animated: true, completion: nil)
            })
        })
    }
}
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    /// 上傳頭像圖片 action sheet
    func presentPhotoActionSheet() {
        let actionSheet = UIAlertController(title: "Profile Picture",
                                            message: "How would you like to select a picture?",
                                            preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Cancel",
                                            style: .cancel,
                                            handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Take Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentCamera()

        }))
        actionSheet.addAction(UIAlertAction(title: "Chose Photo",
                                            style: .default,
                                            handler: { [weak self] _ in

                                                self?.presentPhotoPicker()

        }))

        present(actionSheet, animated: true)
    }
    
    /// 相機
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    /// photo library
    func presentPhotoPicker() {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true, completion: nil)
        guard let selectedImage = info[UIImagePickerController.InfoKey.editedImage] as? UIImage else {
            return
        }

        self.imageView.image = selectedImage
    }

    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion: nil)
    }
}

//MARK: Keyboard
extension RegisterViewController:UITextFieldDelegate {
    func textFieldDidBeginEditing(_ textField: UITextField) {
        self.activeTextField = textField
    }
    func textFieldDidEndEditing(_ textField: UITextField) {
        self.activeTextField = nil
    }
    
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
              // if keyboard size is not available for some reason, dont do anything
              return
           }
        
        var shouldMoveViewUp = false
        
        // if active text filed is not nil
        if let activeTextField = activeTextField {

           let bottomOfTextField = activeTextField.convert(activeTextField.bounds, to: self.view).maxY;
           
           let topOfKeyboard = self.view.frame.height - keyboardSize.height

           // if the bottom of Textfield is below the top of keyboard, move up
           if bottomOfTextField > topOfKeyboard {
             shouldMoveViewUp = true
           }
         }
        
        if(shouldMoveViewUp) {
            self.view.frame.origin.y = 0 - keyboardSize.height
          }
    
    }
    @objc func keyboardWillHide(notification: NSNotification) {
      // move back the root view origin to zero
      self.view.frame.origin.y = 0
    }
}

