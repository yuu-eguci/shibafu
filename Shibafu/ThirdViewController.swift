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
        
        // ユーザ名表示。
        showUsername()
    }
    
    
    // ログアウトボタン押したとき。
    @IBAction func logoutButton(_ sender: Any) {
        
        if let _ = DropboxClientsManager.authorizedClient {
            DropboxClientsManager.unlinkClients()
            label.text = "Unlinked."
            usernameLabel.text = ""
        } else {
            label.text = "Not logined."
        }
        
        // ユーザ名表示。
        showUsername()
    }
    
    
    // ===============================
    // ユーザーネーム表示
    // ===============================
    // ユーザーネーム表示メソッド。
    func showUsername() {
        
        if let client = DropboxClientsManager.authorizedClient {
            client.users.getCurrentAccount().response { response, error in
                if let account = response {
                    self.usernameLabel.text = account.name.givenName
                } else {
                    print(error!)
                }
            }
        } else {
            self.usernameLabel.text = ""
        }
    }
    
    
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    override func viewDidAppear(_ animated: Bool) {
        
        // ユーザ名表示。
        showUsername()
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
}
