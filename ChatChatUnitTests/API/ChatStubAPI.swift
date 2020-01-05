//
//  ChatStubAPI.swift
//  ChatChatUnitTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit
@testable import ChatChatDEV

public class ChatStubAPI: ChatAPI {
    
    //-----------------
    // MARK: - Constants
    //-----------------
    
    struct DefaultKeys {
        static let imageURLNotSet = "NOTSET"
    }
    
    //-----------------
    // MARK: - Properties
    //-----------------
    
    public static let shared = ChatStubAPI()
    
    var textMessages: [(String, String, String, String)] = []
    var photoMessages: [String: (String, String, String, String, String)] = [:]
    var observers: [Int] = []
    var typingObserver: [String: Bool] = [:]
    
    //-----------------
    // MARK: - Methods
    //-----------------
    
    public func observeMessages(forChannelId channelId: String, newMessage: @escaping (_ senderId: String, _ name: String, _ text: String?, _ imageURL: String?, _ key: String?) -> (), updatedMessage: @escaping (_ key: String, _ imageURL: String) -> ()) {
        observers.append(1)
        newMessage("1", "1", "1", "1", "1")
        updatedMessage("1", "1")
    }
    
    public func sendMessage(toChannelId channelId: String, fromId senderId: String, andName name: String, withText text: String) {
        textMessages.append((channelId, senderId, name, text))
    }
    
    public func sendPhotoMessage(toChannelId channelId: String, fromId senderId: String, andName name: String) -> String? {
        let key = "\(channelId)\(senderId)key"
        photoMessages[key] = (channelId, senderId, name, DefaultKeys.imageURLNotSet, key)
        return key
    }
    
    public func uploadImage(_ fileURL: URL, path: String, key: String, withChannelId channelId: String) {
        photoMessages[key]?.2 = fileURL.absoluteString
    }
    
    public func canImageBeDownloaded(atURL imageURL: String) -> Bool {
        return true
    }
    
    public func downloadImage(withimageURL imageURL: String, success: @escaping (UIImage) -> (), failure: @escaping () -> ()) {
        for message in photoMessages {
            if message.value.2 == imageURL {
                success(UIImage(named: "test")!)
            }
        }
    }
    
    public func observeTyping(forChannelId channelId: String, withUserId userId: String, status: @escaping (Bool) -> ()) {
        observers.append(2)
        typingObserver["\(channelId)\(userId)typing"] = false
        status(typingObserver["\(channelId)\(userId)typing"] ?? false)
    }
    
    public func setTyping(_ value: Bool, forChannelId channelId: String, withUserId userId: String) {
        typingObserver["\(channelId)\(userId)typing"] = value
    }
    
    public func removeObservers() {
        observers.removeAll()
        typingObserver.removeAll()
    }
}
