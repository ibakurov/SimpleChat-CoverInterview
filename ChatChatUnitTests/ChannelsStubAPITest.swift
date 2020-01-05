//
//  ChannelsStubTest.swift
//  ChatChatUnitTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
@testable import ChatChatDEV

class ChannelsStubAPITest: XCTestCase {
    
    //-----------------
    // MARK: - Test Methods
    //-----------------
    
    override func setUp() {
        super.setUp()
        
        ChannelsStubAPI.shared.channels.removeAll()
        ChannelsStubAPI.shared.observers.removeAll()
    }
    
    override func tearDown() {
        ChannelsStubAPI.shared.channels.removeAll()
        ChannelsStubAPI.shared.observers.removeAll()
        
        super.tearDown()
    }
    
    func testAddChannel() {
        ChannelsStubAPI.shared.addChannel(withTitle: "Title 1")
        ChannelsStubAPI.shared.addChannel(withTitle: "Title 2")
        
        XCTAssertNotNil(ChannelsStubAPI.shared.channels)
        XCTAssertFalse(ChannelsStubAPI.shared.channels.isEmpty)
        XCTAssertTrue(ChannelsStubAPI.shared.channels.count == 2)
        XCTAssertEqual(ChannelsStubAPI.shared.channels[0], "Title 1")
        XCTAssertEqual(ChannelsStubAPI.shared.channels[1], "Title 2")
    }
    
    func testAddObserver() {
        ChannelsStubAPI.shared.observeChannels({ id, title in
            XCTAssertNotNil(id)
            XCTAssertNotNil(title)
            XCTAssertEqual(id, "1")
            XCTAssertEqual(title, "1")
            XCTAssertNotNil(ChannelsStubAPI.shared.observers)
            XCTAssertFalse(ChannelsStubAPI.shared.observers.isEmpty)
            XCTAssertTrue(ChannelsStubAPI.shared.observers.count == 1)
        }, failure: {
            XCTAssert(false, "Failed to observe the channels")
        })
    }
    
    func testRemoveObserver() {
        ChannelsStubAPI.shared.removeObservers()
        XCTAssertNotNil(ChannelsStubAPI.shared.observers)
        XCTAssertTrue(ChannelsStubAPI.shared.observers.isEmpty)
    }
    
}
