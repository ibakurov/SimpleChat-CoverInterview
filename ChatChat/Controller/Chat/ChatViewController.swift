/*
 * Copyright (c) 2015 Razeware LLC
 *
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 *
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 *
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */

import UIKit
import Photos
import JSQMessagesViewController

final class ChatViewController: JSQMessagesViewController {
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    private var messages: [JSQMessage] = []
    private var photoMessageMap = [String: JSQPhotoMediaItem]()
    
    var channel: Channel! {
        didSet {
            title = channel.name
        }
    }
    
    lazy var outgoingBubbleImageView: JSQMessagesBubbleImage = self.setupOutgoingBubble()
    lazy var incomingBubbleImageView: JSQMessagesBubbleImage = self.setupIncomingBubble()
    
    var isTyping = false {
        didSet {
            ChatFirebaseAPI.shared.setTyping(isTyping, forChannelId: channel.id, withUserId: senderId)
        }
    }
    
    // MARK: View Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        senderDisplayName = Profile.shared.name
        senderId = Profile.shared.id ?? ""
        observeMessages()
        
        // No avatars
        collectionView?.collectionViewLayout.incomingAvatarViewSize = .zero
        collectionView?.collectionViewLayout.outgoingAvatarViewSize = .zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        observeTyping()
    }
    
    deinit {
        ChatFirebaseAPI.shared.removeObservers()
    }
    
    //-----------------
    // MARK: - Actions
    //-----------------
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!) {
        ChatFirebaseAPI.shared.sendMessage(toChannelId: channel.id, fromId: senderId, andName: senderDisplayName, withText: text)
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
        isTyping = false
    }
    
    //-----------------
    // MARK: - UI and User Interaction
    //-----------------
    
    private func setupOutgoingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }
    
    private func setupIncomingBubble() -> JSQMessagesBubbleImage {
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        return bubbleImageFactory!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }
    
    override func didPressAccessoryButton(_ sender: UIButton) {
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            checkCameraAcces { granted in
                if granted {
                    self.presentPhotoPicker(.camera)
                } else {
                    sender.isEnabled = false
                }
            }
        } else {
            checkPhotoGalleryAcces { status in
                if status == .authorized {
                    self.presentPhotoPicker(.photoLibrary)
                } else {
                    sender.isEnabled = false
                }
            }
        }
    }
    
    private func addMessage(withId id: String, name: String, text: String) {
        if let message = JSQMessage(senderId: id, displayName: name, text: text) {
            messages.append(message)
        }
    }
    
    private func addPhotoMessage(withId id: String, key: String, mediaItem: JSQPhotoMediaItem) {
        if let message = JSQMessage(senderId: id, displayName: "", media: mediaItem) {
            messages.append(message)
            
            if mediaItem.image == nil {
                photoMessageMap[key] = mediaItem
            }
            
            collectionView.reloadData()
        }
    }
}

//-----------------
// MARK: - API Requests
//-----------------
extension ChatViewController {
    
    func observeMessages() {
        ChatFirebaseAPI.shared.observeMessages(forChannelId: channel.id, newMessage: { [weak self] senderId, name, text, imageURL, key in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.messageReceived(senderId: senderId, name: name, text: text, imageURL: imageURL, key: key)
            }
        }) { [weak self] key, imageURL in
            guard let `self` = self else { return }
            DispatchQueue.main.async {
                self.messageUpdated(key: key, imageURL: imageURL)
            }
        }
    }
    
    func messageReceived(senderId: String, name: String, text: String?, imageURL: String?, key: String?) {
        if let text = text {
            addMessage(withId: senderId, name: name, text: text)
            finishReceivingMessage()
        } else if let imageURL = imageURL, let key = key, let mediaItem = JSQPhotoMediaItem(maskAsOutgoing: senderId == self.senderId) {
            addPhotoMessage(withId: senderId, key: key, mediaItem: mediaItem)
            if ChatFirebaseAPI.shared.canImageBeDownloaded(atURL: imageURL) {
                downloadImage(withURL: imageURL, andMediaItemToUpdate: mediaItem, forKey: key, shouldRemoveExistingImage: false)
            }
        }
    }
    
    func messageUpdated(key: String, imageURL: String) {
        if let mediaItem = photoMessageMap[key], ChatFirebaseAPI.shared.canImageBeDownloaded(atURL: imageURL) {
            downloadImage(withURL: imageURL, andMediaItemToUpdate: mediaItem, forKey: key, shouldRemoveExistingImage: true)
        }
    }
    
    func downloadImage(withURL imageURL: String, andMediaItemToUpdate mediaItem: JSQPhotoMediaItem, forKey key: String, shouldRemoveExistingImage shouldRemove: Bool) {
        ChatFirebaseAPI.shared.downloadImage(withimageURL: imageURL, success: { [weak self, mediaItem, key, shouldRemove] image in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                mediaItem.image = image
                if shouldRemove {
                    self.photoMessageMap.removeValue(forKey: key)
                }
                self.collectionView.reloadData()
            }
            }, failure: { [weak self, key] in
                guard let `self` = self else { return }
                
                DispatchQueue.main.async {
                    self.photoMessageMap.removeValue(forKey: key)
                    self.collectionView.reloadData()
                }
        })
    }
    
    func observeTyping() {
        ChatFirebaseAPI.shared.observeTyping(forChannelId: channel.id, withUserId: senderId) { [weak self] status in
            guard let `self` = self else { return }
            
            DispatchQueue.main.async {
                self.showTypingIndicator = status
                if status {
                    self.scrollToBottom(animated: true)
                }
            }
        }
    }
}

//-----------------
// MARK: - CollectionViewDataSource
//-----------------
extension ChatViewController {
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource! {
        return messages[indexPath.item].senderId == senderId ? outgoingBubbleImageView : incomingBubbleImageView
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAt: indexPath) as! JSQMessagesCollectionViewCell
        cell.textView?.textColor = messages[indexPath.item].senderId == senderId ? .white : .black
        return cell
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat {
        return 15
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView?, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString? {
        let message = messages[indexPath.item]
        switch message.senderId {
        case senderId:
            return nil
        default:
            guard let senderDisplayName = message.senderDisplayName else {
                assertionFailure()
                return nil
            }
            return NSAttributedString(string: senderDisplayName)
        }
    }
}

//-----------------
// MARK: - UITextViewDelegate
//-----------------
extension ChatViewController {
    
    override func textViewDidChange(_ textView: UITextView) {
        super.textViewDidChange(textView)
        // If the text is not empty, the user is typing
        isTyping = textView.text != ""
    }
}

//-----------------
// MARK: - Image Picker Delegate
//-----------------
extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func checkCameraAcces(completion: @escaping (Bool) -> ()) {
        AVCaptureDevice.requestAccess(for: .video) { granted in
            completion(granted)
        }
    }
    
    func checkPhotoGalleryAcces(completion: @escaping (PHAuthorizationStatus) -> ()) {
        let status = PHPhotoLibrary.authorizationStatus()
        if status == .notDetermined {
            PHPhotoLibrary.requestAuthorization { status in
                completion(status)
            }
        } else {
            completion(status)
        }
    }
    
    func presentPhotoPicker(_ source: UIImagePickerControllerSourceType) {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = source
        present(picker, animated: true, completion:nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [String : Any]) {
        
        picker.dismiss(animated: true, completion:nil)
        
        if let photoReferenceUrl = info[UIImagePickerControllerReferenceURL] as? URL {
            // Handle picking a Photo from the Photo Library
            photoHasBeenPickedFromLibrary(photoReferenceUrl)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            // Handle picking a Photo from the Camera - TODO
            imageHasBeenTakingFromCamera(image)
        }
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        picker.dismiss(animated: true, completion:nil)
    }
    
    func photoHasBeenPickedFromLibrary(_ photoReferenceUrl: URL) {
        let assets = PHAsset.fetchAssets(withALAssetURLs: [photoReferenceUrl], options: nil)
        let asset = assets.firstObject
        
        if let key = ChatFirebaseAPI.shared.sendPhotoMessage(toChannelId: channel.id, fromId: senderId, andName: senderDisplayName) {
            asset?.requestContentEditingInput(with: nil, completionHandler: { [weak self] contentEditingInput, info in
                guard let `self` = self,
                    let senderId = self.senderId,
                    let imageFileURL = contentEditingInput?.fullSizeImageURL else { return }
                
                let path = "\(senderId)/\(Int(Date.timeIntervalSinceReferenceDate * 1000))/\(photoReferenceUrl.lastPathComponent)"
                
                ChatFirebaseAPI.shared.uploadImage(imageFileURL, path: path, key: key, withChannelId: self.channel.id)
            })
        }
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    func imageHasBeenTakingFromCamera(_ image: UIImage) {
        if let imageURL = saveImageToTempDirectory(image) {
            if let key = ChatFirebaseAPI.shared.sendPhotoMessage(toChannelId: channel.id, fromId: senderId, andName: senderDisplayName) {
                ChatFirebaseAPI.shared.uploadImage(imageURL, path: imageURL.path, key: key, withChannelId: self.channel.id)
            }
        }
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        finishSendingMessage()
    }
    
    func saveImageToTempDirectory(_ image: UIImage) -> URL? {
        guard let imageData = UIImageJPEGRepresentation(image, 1) else {
            return nil
        }
        do {
            let imageURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!.appendingPathComponent("\(Int(Date.timeIntervalSinceReferenceDate * 1000)).jpeg")
            try imageData.write(to: imageURL)
            return imageURL
        } catch {
            return nil
        }
    }
}
