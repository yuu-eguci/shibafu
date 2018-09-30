//
//  FirstViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit
import SwiftyDropbox

class FirstViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UIGestureRecognizerDelegate {
    
    
    // ===============================
    // tableView用メソッド
    // ===============================
    // タスクが入るテーブル。
    @IBOutlet weak var table: UITableView!
    // 日付を格納するラベル。
    @IBOutlet weak var label: UILabel!
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        // 更新日付出すの、ここでいっか……。
        let formatter:DateFormatter = Utils.createDateFormatter(format: Utils.FORMAT_YMDHMS)
        label.text = "Last modified:" + formatter.string(from: Tasks.modifiedDate)
        
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
    
    
    // ===============================
    // 長押し編集に関するもの
    // ===============================
    // 長押しされたインデックスが格納されます。
    var longPressedIndex:Int!
    
    
    // テーブル長押し時の処理です。(viewDidLoadで登録済み)
    @objc func editCell(recognizer: UILongPressGestureRecognizer) {
        
        // 長押しされたインデックス番号。
        let pressedIndex = table.indexPathForRow(at: recognizer.location(in: table))
        
        if pressedIndex != nil {
            if recognizer.state == UIGestureRecognizer.State.began {
                
                // indexPath?.row は Optional<Int> なのになぜか indexPath?.row! も indexPath?.row? もできない。
                // しかたないから Optional binding (条件式にのやつ)を使う。
                if let _i = pressedIndex?.row {
                    
                    // 押されたインデックスをクラス変数に保存。
                    longPressedIndex = _i
                    // segueを起動。
                    self.performSegue(withIdentifier: "edit", sender: nil)
                }
            }
        }
    }
    
    
    // segueで移動するとき呼ばれるやつだよねたぶん。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        // 次のViewにインデックスとメイン配列を送ります。
        if segue.identifier == "edit" {
            let nextView = segue.destination as! EditTableViewController
            nextView.longPressedIndex = self.longPressedIndex
        }
    }
    
    
    // セル編集画面の save を押すとここが実行されます。
    @IBAction func saveToMainViewController (segue:UIStoryboardSegue) {
        
        // 編集画面で変更のあったテキストをこちらのリストに適用します。
        let previousView = segue.source as! EditTableViewController
        Tasks.normals[previousView.longPressedIndex] = previousView.editedText
        table.reloadData()
        
        // 現在の状態をDropboxにアップロード。
        Tasks.uploadTasks(label: label)
    }
    
    
    // ===============================
    // タスク追加に関するもの
    // ===============================
    // セル追加画面の save を押すとここが実行されます。
    @IBAction func addToMainViewController (segue:UIStoryboardSegue) {
        
        // 追加画面で書かれたテキストをこちらのリストに適用します。
        let previousView = segue.source as! AddTableViewController
        Tasks.normals.insert(previousView.addedText, at: 0)
        table.reloadData()

        // 現在の状態をDropboxにアップロード。
        Tasks.uploadTasks(label: label)
    }
    
    
    // ===============================
    // スワイプデリートに関するもの
    // ===============================
    // テーブルにスワイプ削除機能を追加。
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    
    // スワイプ時のメッセージを変えたいときはこれ。
    func tableView(_ tableView: UITableView, titleForDeleteConfirmationButtonForRowAt indexPath: IndexPath) -> String? {
        return "これ消す"
    }
    
    
    // スワイプデリート時の処理です。
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == UITableViewCell.EditingStyle.delete {
            Tasks.normals.remove(at: indexPath.row)
            table.reloadData()
            
            // 現在の状態をDropboxにアップロード。
            Tasks.uploadTasks(label: label)
        }
    }
    
    
    // ===============================
    // タップでチェックをつけはずし
    // ===============================
    // セルがタップされたときの処理です。
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        // OKをつけはずし。
        let line:String = Tasks.normals[indexPath.row]
        Tasks.normals[indexPath.row] = Utils.isDoneTask(line:line) ? Utils.getRidOfOK(line: line) : "\(line)\n    OK"
        
        // セル生成時にチェックが付きます。
        table.reloadData()
        
        // 現在の状態をDropboxにアップロード。
        Tasks.uploadTasks(label: label)
    }
    
    
    // ===============================
    // フリックで更新
    // ===============================
    // テーブルがフリックされたとき起こる処理です。
    @objc func foo(_ sender: UIRefreshControl) {
        
        // Dropboxからデータを取得してテーブルに表示します。
        Tasks.downloadTasks(table:table)
        sender.endRefreshing()
    }
    
    
    // ===============================
    // ユーザーネーム表示
    // ===============================
    @IBOutlet weak var usernameLabel: UILabel!
    
    
    // Dropbox認証がされてないときは強制的に認証ページへ
    override func viewDidAppear(_ animated: Bool) {
        
        if DropboxClientsManager.authorizedClient == nil {
            DropboxClientsManager.authorizeFromController(
                UIApplication.shared, controller: self, openURL: {(url:URL) -> Void in UIApplication.shared.open(url)})
            // Dropboxからデータを取得してテーブルに表示します。
            Tasks.downloadTasks(table:table)
        }
        
        // ユーザ名表示。
        if let client = DropboxClientsManager.authorizedClient {
            client.users.getCurrentAccount().response { response, error in
                if let account = response {
                    self.usernameLabel.text = account.name.givenName
                } else {
                    print(error!)
                }
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Dropboxからデータを取得してテーブルに表示します。
        if DropboxClientsManager.authorizedClient != nil {
            Tasks.downloadTasks(table:table)
        }
        
        // テーブル長押し時のメソッドを定義します。
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(editCell))
        recognizer.delegate = self
        table.addGestureRecognizer(recognizer)
        
        // テーブルを一番上でフリックすることで指定したメソッドを実行します。
        let refreshControl = UIRefreshControl()
        refreshControl.addTarget(self, action: #selector(foo(_:)), for: .valueChanged)
        table.refreshControl = refreshControl
    }
}
