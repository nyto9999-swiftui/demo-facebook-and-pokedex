//
//  DatabaseManager.swift
//  demo
//
//  Created by 宇宣 Chen on 2021/7/19.
//

import Foundation
import FirebaseDatabase

final class DatabaseManager{
    
    public enum DatabaseError: Error {
        case failedToFetch
    }
    static let shared = DatabaseManager()
    private let database = Database.database().reference()
    
    
    static func safeEmail(emailAddress : String) -> String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    public func inserUser(with user: AppUser, completion: @escaping (Bool) -> Void){
        
        database.child(user.safeEmail).setValue([
            "first_name:": user.firstName,
            "last_name" : user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to insert user to db")
                completion(false)
                return
            }
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                // if db has users attr
                if var usersCollection = snapshot.value as? [[String: String]] {
                    let newUser = [
                        "name" : user.firstName + "" + user.lastName,
                        "email" : user.safeEmail
                    ]
                    usersCollection.append(newUser)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                    
                }
                else {
                    let newUserCollection: [[String: String]] = [
                        ["name": user.firstName + "" + user.lastName,
                         "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newUserCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        completion(true)
                    })
                }
                
            })
        })
    }
    
}

extension DatabaseManager {
    public func userExists(with email: String,
                           completion: @escaping ((Bool) -> Void)) {
        
        
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
            guard snapshot.value as? String != nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    public func getDataFor(path: String, completion: @escaping (Result<Any, Error>) -> Void){
        self.database.child("\(path)").observeSingleEvent(of: .value, with: { snapshot in
            guard let value = snapshot.value else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            completion(.success(value))
        })
    }
    
    public func insertUser(with user: AppUser, completion: @escaping (Bool)->Void){
        database.child(user.safeEmail).setValue([
            "first_name:": user.firstName,
            "last_name": user.lastName
        ], withCompletionBlock: { error, _ in
            guard error == nil else {
                print("Failed to write to database")
                completion(false)
                return
            }
            
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollection = snapshot.value as? [[String: String]] {
                    //append to user dictionary
                    let newElement = [
                        "name": user.firstName  + "" + user.lastName,
                        "email": user.safeEmail
                    ]
                    usersCollection.append(newElement)
                    
                    self.database.child("users").setValue(usersCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                    
                    
                }
                else {
                    //create that array
                    let newCollection: [[String: String]] = [
                        ["name": user.firstName  + "" + user.lastName,
                         "email": user.safeEmail]
                    ]
                    
                    self.database.child("users").setValue(newCollection, withCompletionBlock: { error, _ in
                        guard error == nil else {
                            completion(false)
                            return
                        }
                        
                        completion(true)
                    })
                }
            })
        })
}
}


struct AppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var safeEmail: String {
        
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    var profilePictureName: String {
        return "\(safeEmail)_profile_picture.png"
    }
}
