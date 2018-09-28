//
//  FirstViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FirstViewController: UIViewController {
    
    
    // Dropbox認証がされてないときは強制的に認証ページへ
    override func viewDidAppear(_ animated: Bool) {
        
        guard let client = DropboxClientsManager.authorizedClient else {
            DropboxClientsManager.authorizeFromController(
                UIApplication.shared, controller: self, openURL: {(url:URL) -> Void in UIApplication.shared.open(url)})
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }


}

