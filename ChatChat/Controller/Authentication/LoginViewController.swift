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
import Firebase

class LoginViewController: UIViewController {
    
    //-----------------
    // MARK: - Variables
    //-----------------
    
    @IBOutlet private weak var nameField: UITextField!
    @IBOutlet private weak var bottomLayoutGuideConstraint: NSLayoutConstraint!
    
    //-----------------
    // MARK: - Initialization
    //-----------------
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillShowNotification(_:)), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(self.keyboardWillHideNotification(_:)), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
    }
    
    //-----------------
    // MARK: - Actions
    //-----------------
    
    @IBAction func loginDidTouch(_ sender: AnyObject) {
        if let userName = nameField?.text, !userName.isEmpty {
            AuthFirebaseAPI.shared.authenticateAnonimously(success: { [weak self, userName] userId in
                guard let `self` = self else { return }
                Profile.shared.id = userId
                Profile.shared.name = userName
                DispatchQueue.main.async {
                    self.performSegue(withIdentifier: "ChannelList", sender: nil)
                }
            }, failure: { [weak self] error in
                guard let `self` = self else { return }
                DispatchQueue.main.async {
                    self.presentErrorAlert(withTitle: "Error", andMessage: error)
                }
            })
        } else {
            self.presentErrorAlert(withTitle: "Error", andMessage: "Enter username")
        }
    }
    
    //-----------------
    // MARK: - Notifications
    //-----------------
    
    @objc func keyboardWillShowNotification(_ notification: Notification) {
        if let keyboardEndFrame = ((notification as NSNotification).userInfo?[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            let convertedKeyboardEndFrame = view.convert(keyboardEndFrame, from: view.window)
            bottomLayoutGuideConstraint.constant = view.bounds.maxY - convertedKeyboardEndFrame.minY
        }
    }
    
    @objc func keyboardWillHideNotification(_ notification: Notification) {
        bottomLayoutGuideConstraint.constant = 48.0
    }

    //-----------------
    // MARK: - Helpers
    //-----------------
    
    func presentErrorAlert(withTitle title: String, andMessage message: String) {
        let alertVC = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertVC.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
        present(alertVC, animated: true, completion: nil)
    }
}

