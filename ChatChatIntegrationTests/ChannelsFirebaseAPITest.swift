//
//  ChannelsFirebaseAPITest.swift
//  ChatChatIntegrationTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
import Firebase
@testable import ChatChatDEV

class ChannelsFirebaseAPITest: XCTestCase {
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    var channelsRef: DatabaseReference!
    
    //-----------------
    // MARK: - Test Methods
    //-----------------
    
    override  class func setUp() {
        super.setUp()
        
        if FirebaseApp.app() == nil {
            FirebaseApp.configure()
        }
    }
    
    override func setUp() {
        super.setUp()
        
        #if ENVDEV
            channelsRef =  Database.database().reference().child("dev").child("channels")
        #else
            channelsRef = Database.database().reference().child("channels")
        #endif
        
    }
    
    override func tearDown() {
        ChannelsFirebaseAPI.shared.removeObservers()
        
        super.tearDown()
    }
    
    func testCreatingChannel() {
        let asyncRunningExpectation = expectation(description: "CreatingChannel")
        
        ChannelsFirebaseAPI.shared.observeChannels({ [weak self] id, name in
            guard let `self` = self else { return }
            
            XCTAssertNotNil(id)
            XCTAssertNotNil(name)
            XCTAssertEqual(name, "Test Channel")
            self.channelsRef.child(id).onDisconnectRemoveValue()
            asyncRunningExpectation.fulfill()
        }) {
            XCTAssert(false, "Failed to observe channels table in Firebase")
            asyncRunningExpectation.fulfill()
        }
        
        ChannelsFirebaseAPI.shared.addChannel(withTitle: "Test Channel")
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
}

