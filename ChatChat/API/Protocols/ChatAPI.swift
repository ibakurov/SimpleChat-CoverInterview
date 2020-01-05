//
//  ChatAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import UIKit

public protocol ChatAPI {
    func observeMessages(forChannelId channelId: String, newMessage: @escaping (_ senderId: String, _ name: String, _ text: String?, _ imageURL: String?, _ key: String?) -> (), updatedMessage: @escaping (_ key: String, _ imageURL: String) -> ())
    
    func sendMessage(toChannelId channelId: String, fromId senderId: String, andName name: String, withText text: String)
    func sendPhotoMessage(toChannelId channelId: String, fromId senderId: String, andName name: String) -> String?
    
    func canImageBeDownloaded(atURL imageURL: String) -> Bool
    func uploadImage(_ fileURL: URL, path: String, key: String, withChannelId channelId: String)
    func downloadImage(withimageURL imageURL: String, success: @escaping (UIImage) -> (), failure: @escaping () -> ())
    
    func observeTyping(forChannelId channelId: String, withUserId userId: String, status: @escaping (Bool) -> ())
    func setTyping(_ value: Bool, forChannelId channelId: String, withUserId userId: String)
    
    func removeObservers()
}
