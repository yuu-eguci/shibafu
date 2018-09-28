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
        
        // テーブル長押し時のメソッドを定義します。
        let recognizer = UILongPressGestureRecognizer(target: self, action: #selector(editCell))
        recognizer.delegate = self
        table.addGestureRecognizer(recognizer)
    }
}

