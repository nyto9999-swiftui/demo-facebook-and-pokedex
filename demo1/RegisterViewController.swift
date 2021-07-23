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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        imageView.isUserInteractionEnabled = true
        let gesture = UITapGestureRecognizer(target: self, action: #selector(didTapPicture))
        imageView.addGestureRecognizer(gesture)
    }
    
    @objc private func didTapPicture(){
        presentPhotoActionSheet()
    }
    

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
                print("invalid register")
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
                // inser user to db
                let appUser = AppUser(firstName: firstname, lastName: lastname, emailAddress: email)
                DatabaseManager.shared.inserUser(with: appUser, completion: { success in
                    if success {
                        guard let image = self?.imageView.image,
                              let data = image.pngData() else {
                            print("image png fail")
                            return
                        }
                        let imgString = appUser.profilePictureName
                        StorageManager.shared.uploadProfilePicture(with: data, fileName: imgString, completion: { result in
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

//MARK: Extension
extension RegisterViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    
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
    
    func presentCamera() {
        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.delegate = self
        vc.allowsEditing = true
        present(vc, animated: true)
    }

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
