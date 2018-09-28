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
    
    
    // 日付を格納するラベル。
    @IBOutlet weak var label: UILabel!
    // タスクが入るテーブル。
    @IBOutlet weak var table: UITableView!
    
    
    
    // Dropbox認証がされてないときは強制的に認証ページへ
    override func viewDidAppear(_ animated: Bool) {
        
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromController(
                UIApplication.shared, controller: self, openURL: {(url:URL) -> Void in UIApplication.shared.open(url)})
            return
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dropboxからデータを取得してテーブルに表示します。
        Tasks.downloadTasks(table:table)
    }


}

