//
//  ThirdViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/29.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit
import SwiftyDropbox

class ThirdViewController: UIViewController {
    
    
    // ラベル。
    @IBOutlet weak var label: UILabel!
    
    
    // ログインボタン押したとき。
    @IBAction func loginButton(_ sender: Any) {
        
        if let _ = DropboxClientsManager.authorizedClient {
            label.text = "Already logined."
        } else {
            DropboxClientsManager.authorizeFromController(
                .shared, controller: self, openURL: {(url:URL) -> Void in UIApplication.shared.open(url)})
            label.text = "Logined!"
        }
    }
    
    
    // ログアウトボタン押したとき。
    @IBAction func logoutButton(_ sender: Any) {
        
        if let _ = DropboxClientsManager.authorizedClient {
            DropboxClientsManager.unlinkClients()
            label.text = "Unlinked."
        } else {
            label.text = "Not logined."
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
