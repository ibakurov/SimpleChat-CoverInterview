//
//  AuthFirebaseAPITest.swift
//  ChatChatIntegrationTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
import Firebase
@testable import ChatChatDEV

class AuthFirebaseAPITest: XCTestCase {
    
    //-----------------
    // MARK: - Test Methods
    //-----------------
    
    override  class func setUp() {
        super.setUp()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    func testAnonymousAuthentication() {
        let asyncRunningExpectation = expectation(description: "AnonymousAuthentication")
        
        AuthFirebaseAPI.shared.authenticateAnonimously(success: { id in
            XCTAssertNotNil(id)
            asyncRunningExpectation.fulfill()
        }) { error in
            XCTAssertNotNil(error)
            asyncRunningExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
            XCTAssertNotNil(Auth.auth().currentUser)
        }
    }
}
