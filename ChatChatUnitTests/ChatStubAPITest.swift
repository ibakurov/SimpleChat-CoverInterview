//
//  ChatStubAPITest.swift
//  ChatChatUnitTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
@testable import ChatChatDEV

class ChatStubAPITest: XCTestCase {
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    let channelId = "123"
    let userId = "user123"
    let userName = "userName123"
    let text = "Text123"
    let path = "path"
    
    //-----------------
    // MARK: - Test Methods
    //-----------------
    
    override func setUp() {
        super.setUp()
        
        ChatStubAPI.shared.textMessages.removeAll()
        ChatStubAPI.shared.photoMessages.removeAll()
        ChatStubAPI.shared.observers.removeAll()
        ChatStubAPI.shared.typingObserver.removeAll()
    }
    
    override func tearDown() {
        ChatStubAPI.shared.textMessages.removeAll()
        ChatStubAPI.shared.photoMessages.removeAll()
        ChatStubAPI.shared.observers.removeAll()
        ChatStubAPI.shared.typingObserver.removeAll()
        
        super.tearDown()
    }
    
    func testSendTextMessage() {
        ChatStubAPI.shared.sendMessage(toChannelId: channelId, fromId: userId, andName: userName, withText: text)
        
        XCTAssertNotNil(ChatStubAPI.shared.textMessages)
        XCTAssertFalse(ChatStubAPI.shared.textMessages.isEmpty)
        XCTAssertTrue(ChatStubAPI.shared.textMessages.count == 1)
        XCTAssertEqual(ChatStubAPI.shared.textMessages[0].0, channelId)
        XCTAssertEqual(ChatStubAPI.shared.textMessages[0].1, userId)
        XCTAssertEqual(ChatStubAPI.shared.textMessages[0].2, userName)
        XCTAssertEqual(ChatStubAPI.shared.textMessages[0].3, text)
    }
    
    func testSendPhotoMessage() {
        let key = ChatStubAPI.shared.sendPhotoMessage(toChannelId: channelId, fromId: userId, andName: userName)
        
        XCTAssertNotNil(key)
        XCTAssertNotNil(ChatStubAPI.shared.photoMessages)
        XCTAssertFalse(ChatStubAPI.shared.photoMessages.isEmpty)
        XCTAssertTrue(ChatStubAPI.shared.photoMessages.count == 1)
        XCTAssertNotNil(ChatStubAPI.shared.photoMessages[key!])
        XCTAssertEqual(ChatStubAPI.shared.photoMessages[key!]!.0, channelId)
        XCTAssertEqual(ChatStubAPI.shared.photoMessages[key!]!.1, userId)
        XCTAssertEqual(ChatStubAPI.shared.photoMessages[key!]!.2, userName)
        XCTAssertEqual(ChatStubAPI.shared.photoMessages[key!]!.3, ChatStubAPI.DefaultKeys.imageURLNotSet)
        XCTAssertEqual(ChatStubAPI.shared.photoMessages[key!]!.4, key!)
        
        XCTAssertNil(ChatStubAPI.shared.photoMessages["456"])
    }
    
    func testAddObserverForMessages() {
        ChatStubAPI.shared.observeMessages(forChannelId: channelId, newMessage: { (senderId, name, text, imageURL, key) in
            XCTAssertNotNil(senderId)
            XCTAssertNotNil(name)
            XCTAssertNotNil(text)
            XCTAssertNotNil(imageURL)
            XCTAssertNotNil(key)
            XCTAssertEqual(senderId, "1")
            XCTAssertEqual(name, "1")
            XCTAssertEqual(text, "1")
            XCTAssertEqual(imageURL, "1")
            XCTAssertEqual(key, "1")
        }) { key, imageURL in
            XCTAssertNotNil(imageURL)
            XCTAssertNotNil(key)
            XCTAssertEqual(imageURL, "1")
            XCTAssertEqual(key, "1")
        }
        
        XCTAssertNotNil(ChatStubAPI.shared.observers)
        XCTAssertFalse(ChatStubAPI.shared.observers.isEmpty)
        XCTAssertTrue(ChatStubAPI.shared.observers.count == 1)
    }
    
    func testUploadImage() {
        let key = ChatStubAPI.shared.sendPhotoMessage(toChannelId: channelId, fromId: userId, andName: userName)
        uploadImage()
        
        XCTAssertNotNil(key)
        XCTAssertNotNil(ChatStubAPI.shared.photoMessages[key!])
        XCTAssertEqual(ChatStubAPI.shared.photoMessages[key!]!.2, path)
    }
    
    func uploadImage() {
        let key = "\(channelId)\(userId)key"
        ChatStubAPI.shared.uploadImage(URL(string: path)!, path: path, key: key, withChannelId: channelId)
    }
    
    func testDownloadImage() {
        uploadImage()
        
        ChatStubAPI.shared.downloadImage(withimageURL: path, success: { image in
            XCTAssertNotNil(image)
        }) {
            XCTAssert(false, "Failed to download an image")
        }
    }
    
    func testAddObserverForTyping() {
        ChatStubAPI.shared.observeTyping(forChannelId: channelId, withUserId: userId) { [weak self] status in
            guard let `self` = self else { return }
            XCTAssertNotNil(status)
            XCTAssertEqual(status, (ChatStubAPI.shared.typingObserver["\(self.channelId)\(self.userId)typing"] ?? false))
        }
        
        XCTAssertNotNil(ChatStubAPI.shared.observers)
        XCTAssertFalse(ChatStubAPI.shared.observers.isEmpty)
        XCTAssertNotNil(ChatStubAPI.shared.typingObserver)
        XCTAssertFalse(ChatStubAPI.shared.typingObserver.isEmpty)
        XCTAssertNotNil(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"])
    }
    
    func testSetTypingAtTheSameChannel() {
        ChatStubAPI.shared.setTyping(true, forChannelId: channelId, withUserId: userId)
        
        XCTAssertNotNil(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"])
        XCTAssertEqual(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"], true)
        
        let currentValue = ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"]!
        
        ChatStubAPI.shared.setTyping(!currentValue, forChannelId: channelId, withUserId: userId)
        
        XCTAssertNotEqual(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"], currentValue)
    }
    
    func testSetTypingAtTheDifferentChannel() {
        ChatStubAPI.shared.setTyping(true, forChannelId: channelId, withUserId: userId)
        
        XCTAssertNotNil(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"])
        XCTAssertEqual(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"], true)
        
        let currentValue = ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"]!
        
        ChatStubAPI.shared.setTyping(!currentValue, forChannelId: "456", withUserId: userId)
        
        XCTAssertNotNil(ChatStubAPI.shared.typingObserver["456\(userId)typing"])
        XCTAssertNotEqual(ChatStubAPI.shared.typingObserver["\(channelId)\(userId)typing"], ChatStubAPI.shared.typingObserver["456\(userId)typing"])
    }
    
    func testRemoveObservers() {
        ChatStubAPI.shared.observeTyping(forChannelId: channelId, withUserId: userId) { _ in }
        ChatStubAPI.shared.observeMessages(forChannelId: channelId, newMessage: { _,_,_,_,_  in}) { _,_ in }
        
        ChatStubAPI.shared.removeObservers()
        XCTAssertNotNil(ChatStubAPI.shared.observers)
        XCTAssertTrue(ChatStubAPI.shared.observers.isEmpty)
        XCTAssertNotNil(ChatStubAPI.shared.typingObserver)
        XCTAssertTrue(ChatStubAPI.shared.typingObserver.isEmpty)
    }
}

