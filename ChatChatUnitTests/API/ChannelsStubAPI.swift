//
//  ChannelsStubAPI.swift
//  ChatChatUnitTests
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation
@testable import ChatChatDEV

public class ChannelsStubAPI: ChannelsAPI {
    
    //-----------------
    // MARK: - Properties
    //-----------------
    
    public static let shared = ChannelsStubAPI()
    
    var channels: [String] = []
    var observers: [Int] = []
    
    //-----------------
    // MARK: - Methods
    //-----------------
    
    public func addChannel(withTitle title: String) {
        channels.append(title)
    }
    
    public func observeChannels(_ success: @escaping (String, String) -> (), failure: @escaping () -> ()) {
        observers.append(1)
        success("1", "1")
    }
    
    public func removeObservers() {
        observers.removeAll()
    }
}

