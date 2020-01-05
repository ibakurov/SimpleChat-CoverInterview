//
//  ChatFirebaseAPITest.swift
//  ChatChatIntegrationTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import XCTest
import Firebase
@testable import ChatChatDEV

class ChatFirebaseAPITest: XCTestCase {
        
    //-----------------
    // MARK: - Constants
    //-----------------
    
    private struct DefaultKeys {
        static let imageURLNotSet = "NOTSET"
    }
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    var channelId = "123"
    var senderId = "user123"
    var username = "username123"
    var messageText = "Text123"
    
    var imageURL: URL!
    
    var channelsRef: DatabaseReference!
    
    var messageRef: DatabaseReference!
    var userIsTypingRef: DatabaseReference!
    
    var isTyping: Bool = false
    
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
        channelsRef.child(channelId).onDisconnectRemoveValue()

        clearDocumentsFolder()
        if let imageURL = moveFileFromBundleToDocumentsFolder() {
            self.imageURL = imageURL
        }
    }
    
    override func tearDown() {
        ChatFirebaseAPI.shared.removeObservers()
        
        clearDocumentsFolder()
        if let imageURL = imageURL {
            Storage.storage().reference(forURL: "gs://cover-interview-ib.appspot.com").child(imageURL.path).delete(completion: nil)
        }
        
        super.tearDown()
    }
    
    func testSendingTextMessage() {
        let asyncRunningExpectation = expectation(description: "SendingTextMessage")
        
        ChatFirebaseAPI.shared.observeMessages(forChannelId: channelId, newMessage: { [weak self] senderId, senderName, text, imageURL, key in
            guard let `self` = self else { return }
            
            XCTAssertNotNil(senderId)
            XCTAssertNotNil(senderName)
            XCTAssertNotNil(text)
            XCTAssertNil(imageURL)
            XCTAssertNil(key)
            
            XCTAssertEqual(senderId, self.senderId)
            XCTAssertEqual(senderName, self.username)
            XCTAssertEqual(text, self.messageText)
            
            asyncRunningExpectation.fulfill()
        }) { key, imageURL in
            XCTAssert(false, "The update message should not have run on the text message")
        }
        
        ChatFirebaseAPI.shared.sendMessage(toChannelId: channelId, fromId: senderId, andName: username, withText: messageText)
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
    func testSendingPhotoMessage() {
        let asyncRunningExpectation = expectation(description: "SendingPhotoMessage")
        
        ChatFirebaseAPI.shared.observeMessages(forChannelId: channelId, newMessage: { [weak self] senderId, senderName, text, imageURL, key in
            guard let `self` = self else { return }
            
            XCTAssertNotNil(senderId)
            XCTAssertNotNil(senderName)
            XCTAssertNil(text)
            XCTAssertNotNil(imageURL)
            XCTAssertNotNil(key)
            
            XCTAssertEqual(senderId, self.senderId)
            XCTAssertEqual(senderName, self.username)
            
            ChatFirebaseAPI.shared.uploadImage(self.imageURL, path: self.imageURL.path, key: key!, withChannelId: self.channelId)
        }) { [weak self] key, imageURL in
            guard let `self` = self else { return }
            
            XCTAssertNotNil(key)
            XCTAssertNotNil(imageURL)
            XCTAssertEqual(imageURL, "gs://cover-interview-ib.appspot.com\(self.imageURL.path)")
            
            asyncRunningExpectation.fulfill()
        }
        
        let key = ChatFirebaseAPI.shared.sendPhotoMessage(toChannelId: channelId, fromId: senderId, andName: username)
        XCTAssertNotNil(key)
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
    func testDownloadingImageSuccessfully() {
        let asyncRunningExpectation = expectation(description: "DownloadingImage")

        ChatFirebaseAPI.shared.observeMessages(forChannelId: channelId, newMessage: { [weak self] senderId, senderName, text, imageURL, key in
            guard let `self` = self else { return }
            
            XCTAssertNotNil(senderId)
            XCTAssertNotNil(senderName)
            XCTAssertNil(text)
            XCTAssertNotNil(imageURL)
            XCTAssertNotNil(key)
            
            XCTAssertEqual(senderId, self.senderId)
            XCTAssertEqual(senderName, self.username)
            
            ChatFirebaseAPI.shared.uploadImage(self.imageURL, path: self.imageURL.path, key: key!, withChannelId: self.channelId)
        }) { [weak self] key, imageURL in
            guard let `self` = self else { return }
            
            XCTAssertNotNil(key)
            XCTAssertNotNil(imageURL)
            XCTAssertEqual(imageURL, "gs://cover-interview-ib.appspot.com\(self.imageURL.path)")
            
            ChatFirebaseAPI.shared.downloadImage(withimageURL: imageURL, success: { image in
                XCTAssertNotNil(image)
                asyncRunningExpectation.fulfill()
            }) {
                XCTAssert(false, "Donwload of the image from Firebase has failed")
                asyncRunningExpectation.fulfill()
            }
        }
        
        let key = ChatFirebaseAPI.shared.sendPhotoMessage(toChannelId: channelId, fromId: senderId, andName: username)
        XCTAssertNotNil(key)
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
    func testDownloadingImageFailure() {
        let asyncRunningExpectation = expectation(description: "DownloadingImage")
        
        ChatFirebaseAPI.shared.downloadImage(withimageURL: imageURL.path, success: { image in
            XCTAssertNil(image)
            asyncRunningExpectation.fulfill()
        }) {
            asyncRunningExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
    //Whenver we set the typing status on device, we track through local variable, so that we don't show our typing indicator. Thus it means, that until we set and observe the typing status from the same device, we will never get tru response in this test.
    func testTypingStatus() {
        let asyncRunningExpectation = expectation(description: "TypingStatus")
        
        ChatFirebaseAPI.shared.observeTyping(forChannelId: channelId, withUserId: senderId) { status in
            XCTAssertNotNil(status)
            XCTAssertFalse(status)
            asyncRunningExpectation.fulfill()
        }
        
        waitForExpectations(timeout: 30) { expectationError in
            XCTAssertNil(expectationError, expectationError!.localizedDescription)
        }
    }
    
    //-----------------
    // MARK: - Helper Methods
    //-----------------
    
    func moveFileFromBundleToDocumentsFolder() -> URL? {
        if let bundlePath = Bundle.main.path(forResource: "image", ofType: ".jpg") {
            let destPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let fileManager = FileManager.default
            let fullDestPath = URL(fileURLWithPath: destPath).appendingPathComponent("image.jpg")
            
            do {
                try fileManager.copyItem(atPath: bundlePath, toPath: fullDestPath.path)
                return fullDestPath
            } catch {
                XCTAssert(false, "image.jpg couldn't be copied to Documents")
            }
        } else {
            XCTAssert(false, "image.jpg couldn't be located in Bundle")
        }
        return nil
    }
    
    func clearDocumentsFolder() {
        let fileManager = FileManager.default
        let docsFolderPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
        do {
            let filePaths = try fileManager.contentsOfDirectory(atPath: docsFolderPath)
            for filePath in filePaths {
                try fileManager.removeItem(atPath: "\(docsFolderPath)/\(filePath)")
            }
        } catch {
            XCTAssert(false, "Could not clear temp folder: \(error)")
        }
    }
    
}

