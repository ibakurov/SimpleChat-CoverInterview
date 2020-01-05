//
//  ChannelsFirebaseAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/20/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage

public class ChannelsFirebaseAPI: ChannelsAPI {
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    public static let shared = ChannelsFirebaseAPI()
    
    private var channelRef: DatabaseReference {
        #if ENVDEV
            return Database.database().reference().child("dev").child("channels")
        #else
            return Database.database().reference().child("channels")
        #endif
    }

    //-----------------
    // MARK: - Initialization
    //-----------------
    
    //This is made private on purpose to keep this class truly Singleton, so that no one can create copies of it.
    private init() {}
    
    //-----------------
    // MARK: - Methods
    //-----------------
    
    public func addChannel(withTitle title: String) {
        let newChannelRef = channelRef.childByAutoId()
        let channelItem = [
            "name": title
        ]
        newChannelRef.setValue(channelItem)
    }
    
    public func observeChannels(_ success: @escaping (String, String) -> () = { _, _ in }, failure: @escaping () -> () = {}) {
        channelRef.observe(.childAdded, with: { snapshot in
            guard let channelData = snapshot.value as? [String: AnyObject],
                let name = channelData["name"] as? String else {
                print("Error! Could not decode channel data")
                failure()
                return
            }
            success(snapshot.key, name)
        })
    }
    
    public func removeObservers() {
        channelRef.removeAllObservers()
    }
}
