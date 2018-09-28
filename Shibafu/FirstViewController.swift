//
//  FirstViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    
    // ===============================
    // tableView用メソッド
    // ===============================
    // タスクが入るテーブル。
    @IBOutlet weak var table: UITableView!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        return Tasks.normals.count
    }
    
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")
        
        // 2桁以上表示。
        cell.textLabel?.numberOfLines = 0
        
        // 内容。
        let text:String = Tasks.normals[indexPath.row]
        cell.textLabel?.text = text
        
        // 継続タスクは背景色を変えます。
        if Utils.isKeepTask(line: text) {
            cell.contentView.backgroundColor = UIColor(red: 200/255, green: 220/255, blue: 170/255, alpha: 1.0)
        }
        
        // 完了しているタスクにはチェックを入れる。
        if Utils.isDoneTask(line: text) {
            cell.accessoryType = .checkmark
        }
        
        return cell
    }
    
    
    // 日付を格納するラベル。
    @IBOutlet weak var label: UILabel!
    
    
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

