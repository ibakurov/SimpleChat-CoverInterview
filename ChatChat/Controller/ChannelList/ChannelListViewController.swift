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

import Firebase
import UIKit

enum Section: Int {
    case createNewChannelSection = 0
    case currentChannelsSection
    
    func reuseIdentifier() -> String {
        switch self {
        case .createNewChannelSection:
            return "NewChannel"
        case .currentChannelsSection:
            return "ExistingChannel"
        }
    }
}

class ChannelListViewController: UITableViewController {
    
    //-----------------
    // MARK: - Variables
    //-----------------
        
    private var channels: [Channel] = []
        
    //-----------------
    // MARK: - Initialization
    //-----------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        observeChannels()
    }
    
    deinit {
        ChannelsFirebaseAPI.shared.removeObservers()
    }
    
    //-----------------
    // MARK: - API Requests
    //-----------------
    
    private func observeChannels() {
        ChannelsFirebaseAPI.shared.observeChannels({ [weak self] id, name in
            guard let `self` = self else { return }
            
            self.channels.append(Channel(id: id, name: name))
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        })
    }
    
    //-----------------
    // MARK: - Navigation
    //-----------------
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        if let channel = sender as? Channel {
            let chatVc = segue.destination as! ChatViewController
            
            chatVc.channel = channel
        }
    }
}

//-----------------
// MARK: - UITableViewDataSource
//-----------------
extension ChannelListViewController {
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let currentSection = Section(rawValue: section) else {
            return 0
        }
        switch currentSection {
        case .createNewChannelSection:
            return 1
        case .currentChannelsSection:
            return channels.count
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let currentSection = Section(rawValue: indexPath.section) else {
            return UITableViewCell()
        }
        
        let cell = tableView.dequeueReusableCell(withIdentifier: currentSection.reuseIdentifier(), for: indexPath)
        
        switch currentSection {
        case .createNewChannelSection:
            if let createNewChannelCell = cell as? CreateChannelCell {
                createNewChannelCell.delegate = self
            }
        case .currentChannelsSection:
            cell.textLabel?.text = channels[(indexPath as NSIndexPath).row].name
        }
        
        return cell
    }
}

//-----------------
// MARK: - UITableViewDelegate
//-----------------
extension ChannelListViewController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if (indexPath as NSIndexPath).section == Section.currentChannelsSection.rawValue {
            let channel = channels[(indexPath as NSIndexPath).row]
            self.performSegue(withIdentifier: "ShowChannel", sender: channel)
        }
    }
}

//-----------------
// MARK: - CreateChannelCellDelegate
//-----------------
extension ChannelListViewController: CreateChannelCellDelegate {
    
    func createChannelCell(_ cell: CreateChannelCell, createInitatedWithTitile title: String) {
        ChannelsFirebaseAPI.shared.addChannel(withTitle: title)
    }
}
