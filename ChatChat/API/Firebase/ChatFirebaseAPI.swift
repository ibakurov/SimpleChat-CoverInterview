//
//  ChatFirebaseAPI.swift
//  ChatChat
//
//  Created by Illya Bakurov on 8/20/18.
//  Copyright © 2018 Razeware LLC. All rights reserved.
//

import FirebaseDatabase
import FirebaseStorage

public class ChatFirebaseAPI: ChatAPI {
    
    //-----------------
    // MARK: - Constants
    //-----------------
    
    private struct DefaultKeys {
        static let imageURLNotSet = "NOTSET"
    }
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    public static let shared = ChatFirebaseAPI()
    
    private var channelRef: DatabaseReference {
        #if ENVDEV
            return Database.database().reference().child("dev").child("channels")
        #else
            return Database.database().reference().child("channels")
        #endif
    }
    
    private var messageRef: DatabaseReference!
    private var messageQuery: DatabaseQuery!
    private var userIsTypingRef: DatabaseReference!
    private var usersTypingQuery: DatabaseQuery!
    
    private var isTyping: Bool = false
    
    //-----------------
    // MARK: - Initialization
    //-----------------
    
    //This is made private on purpose to keep this class truly Singleton, so that no one can create copies of it.
    private init() {}
    
    //-----------------
    // MARK: - Methods
    //-----------------
    
    public func observeMessages(forChannelId channelId: String, newMessage: @escaping (_ senderId: String, _ name: String, _ text: String?, _ imageURL: String?, _ key: String?) -> (), updatedMessage: @escaping (_ key: String, _ imageURL: String) -> ()) {
        messageRef = channelRef.child(channelId).child("messages")
        messageQuery = messageRef.queryLimited(toLast:25)
        
        // We can use the observe method to listen for new
        // messages being written to the Firebase DB
        messageQuery.observe(.childAdded, with: { snapshot in
            guard let messageData = snapshot.value as? [String: String] else {
                return
            }
                        
            if let id = messageData["senderId"], let name = messageData["senderName"], let text = messageData["text"], text.count > 0 {
                newMessage(id, name, text, nil, nil)
            } else if let id = messageData["senderId"], let imageURL = messageData["imageURL"], let name = messageData["senderName"] {
                newMessage(id, name, nil, imageURL, snapshot.key)
            } else {
                print("Error! Could not decode message data")
            }
        })
        
        // We can also use the observer method to listen for
        // changes to existing messages.
        // We use this to be notified when a photo has been stored
        // to the Firebase Storage, so we can update the message data
        messageRef.observe(.childChanged, with: { (snapshot) in
            let key = snapshot.key
            guard let messageData = snapshot.value as? [String: String] else {
                return
            }
            
            print(messageData)
            
            if let imageURL = messageData["imageURL"] {
                updatedMessage(key, imageURL)                
            }
        })
    }
    
    public func sendMessage(toChannelId channelId: String, fromId senderId: String, andName name: String, withText text: String) {
        messageRef = channelRef.child(channelId).child("messages")
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "senderId": senderId,
            "senderName": name,
            "text": text
            ]
        
        itemRef.setValue(messageItem)
    }
    
    public func sendPhotoMessage(toChannelId channelId: String, fromId senderId: String, andName name: String) -> String? {
        messageRef = channelRef.child(channelId).child("messages")
        let itemRef = messageRef.childByAutoId()
        
        let messageItem = [
            "imageURL": DefaultKeys.imageURLNotSet,
            "senderName": name,
            "senderId": senderId
            ]
        
        itemRef.setValue(messageItem)
        return itemRef.key
    }
    
    public func canImageBeDownloaded(atURL imageURL: String) -> Bool {
        return imageURL.hasPrefix("gs://")
    }
    
    public func downloadImage(withimageURL imageURL: String, success: @escaping (UIImage) -> () = { _ in }, failure: @escaping () -> () = {}) {
        if imageURL.hasPrefix("gs://") {
            downloadImageFromFirebaseStorage(imageURL, success: success, failure: failure)
        } else {
            failure()
        }
    }
    
    private func downloadImageFromFirebaseStorage(_ imageURL: String, success: @escaping (UIImage) -> () = { _ in }, failure: @escaping () -> () = {}) {
        let storageRef = Storage.storage().reference(forURL: imageURL)
        storageRef.getData(maxSize: INT64_MAX){ data, error in
            if let error = error {
                print("Error downloading image data: \(error)")
                failure()
                return
            }
            
            storageRef.getMetadata(completion: { [data] metadata, metadataErr in
                if let error = metadataErr {
                    print("Error downloading metadata: \(error)")
                    failure()
                    return
                }
                
                if metadata?.contentType == "image/gif", let data = data, let image = UIImage.gifWithData(data) {
                    success(image)
                } else if let data = data, let image = UIImage.init(data: data) {
                    success(image)
                } else {
                    failure()
                }
            })
        }
    }
    
    public func uploadImage(_ fileURL: URL, path: String, key: String, withChannelId channelId: String) {
        let storageRef = Storage.storage().reference(forURL: "gs://cover-interview-ib.appspot.com")
        storageRef.child(path).putFile(from: fileURL, metadata: nil) { [weak self, storageRef, key, channelId] metadata, error in
            guard let `self` = self else { return }
            
            if let error = error {
                print("Error uploading photo: \(error.localizedDescription)")
                return
            }
            if let path = metadata?.path {
                self.updateImageURL(storageRef.child(path).description, forPhotoMessageWithKey: key, atChannelWithId: channelId)
            }
        }
    }
    
    private func updateImageURL(_ url: String, forPhotoMessageWithKey key: String, atChannelWithId channelId: String) {
        let itemRef = channelRef.child(channelId).child("messages").child(key)
        itemRef.updateChildValues(["imageURL": url])
    }
    
    public func observeTyping(forChannelId channelId: String, withUserId userId: String, status: @escaping (Bool) -> ()) {
        let typingIndicatorRef = channelRef.child(channelId).child("typingIndicator")
        userIsTypingRef = typingIndicatorRef.child(userId)
        userIsTypingRef.onDisconnectRemoveValue()
        usersTypingQuery = typingIndicatorRef.queryOrderedByValue().queryEqual(toValue: true)
        
        usersTypingQuery.observe(.value) { [weak self] data in
            guard let `self` = self else { return }
            
            // You're the only typing, don't show the indicator
            if data.childrenCount == 1 && self.isTyping {
                status(false)
                return
            }
            
            // Are there others typing?
            status(data.childrenCount > 0)
        }
    }
    
    public func setTyping(_ value: Bool, forChannelId channelId: String, withUserId userId: String) {
        isTyping = value
        userIsTypingRef = channelRef.child(channelId).child("typingIndicator").child(userId)
        userIsTypingRef.setValue(value)
    }
    
    public func removeObservers() {
        messageRef?.removeAllObservers()
        messageQuery?.removeAllObservers()
        userIsTypingRef?.removeAllObservers()
        usersTypingQuery?.removeAllObservers()
    }
    
}

