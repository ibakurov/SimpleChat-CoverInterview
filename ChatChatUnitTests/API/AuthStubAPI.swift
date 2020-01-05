//
//  AuthStubAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
@testable import ChatChatDEV

public class AuthStubAPI: AuthAPI {
    
    //-----------------
    // MARK: - Properties
    //-----------------
    
    public static let shared = AuthStubAPI()
    
    //-----------------
    // MARK: - Methods
    //-----------------
    
    public func authenticateAnonimously(success: @escaping (String) -> (), failure: @escaping (String) -> ()) {
        success("id")
    }
}
