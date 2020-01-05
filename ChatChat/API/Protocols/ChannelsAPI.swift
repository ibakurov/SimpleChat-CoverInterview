//
//  ChannelsAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/24/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import Foundation

public protocol ChannelsAPI {
    func addChannel(withTitle title: String)
    func observeChannels(_ success: @escaping (String, String) -> (), failure: @escaping () -> ())
    func removeObservers()
}
