//
//  AuthFirebaseAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/20/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import FirebaseAuth

public class AuthFirebaseAPI: AuthAPI {
    
    //-----------------
    // MARK: - Properties
    //-----------------
    
    public static let shared = AuthFirebaseAPI()
    
    //-----------------
    // MARK: - Init
    //-----------------
    
    //This is made private on purpose to keep this class truly Singleton, so that no one can create copies of it.
    private init() {}
    
    //-----------------
    // MARK: - Methods
    //-----------------
    
    public func authenticateAnonimously(success: @escaping (String) -> () = { _ in }, failure: @escaping (String) -> () = { _ in }) {
        Auth.auth().signInAnonymously { result, error in
            if let result = result {
                success(result.user.uid)
            } else {
                failure(error?.localizedDescription ?? "Failed to log in")
            }
        }
    }
}
