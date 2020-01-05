//
//  AuthStubTest.swift
//  ChatChatUnitTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
@testable import ChatChatDEV

class AuthStubAPITest: XCTestCase {
    
    //-----------------
    // MARK: - Test Methods
    //-----------------
    
    func testAnonymousAuthentication() {
        AuthStubAPI.shared.authenticateAnonimously(success: { id in
            XCTAssertNotNil(id)
            XCTAssertEqual(id, "id")
        }) { error in
            XCTAssertNotNil(error)
        }
    }
}
