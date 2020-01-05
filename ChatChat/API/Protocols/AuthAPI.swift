//
//  AuthAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation

public protocol AuthAPI {
    func authenticateAnonimously(success: @escaping (String) -> (), failure: @escaping (String) -> ())
}
