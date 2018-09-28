//
//  EditTableViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController, UITextViewDelegate {
    
    
    // メインViewで長押しされたインデックス。
    var longPressedIndex:Int!
    
    // 編集されたテキストを格納する。
    var editedText:String!
    
    // テキストビュー。
    @IBOutlet weak var textView: UITextView!
    
    // テーブル。
    @IBOutlet var table: UITableView!
    
    
    // DidLoad
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        // テキストビューを高さ可変にします。storyboardのほうでtextViewの四方に制約つけて、Scrolling enabledを外すこと。
        table.rowHeight = UITableView.automaticDimension
        table.estimatedRowHeight = 10000
        textView.delegate = self
        
        // これから編集するものをテキストビューに表示します。
        textView.text = Tasks.normals[longPressedIndex!]
        
        // テキストビューにカーソルをあわせます。
        textView.becomeFirstResponder()
    }
    
    
    // textViewが変更されるたびに実行されるとこ。
    // UITextViewDelegateの継承を忘れずに。
    func textViewDidChange(_ textView: UITextView) {
        
        table.beginUpdates()
        table.endUpdates()
    }
    
    
    // storyboardでsaveボタンからexit(上にみっつ並ぶボタンの右端)にsegueひくこと。(unwind segue)
    // unwind segueのidentifierはstoryboardのオブジェクト一覧から選択して設定する。
    // segue起動時に実行されるよここが。そんでFirstViewのsaveToMainViewControllerに飛ぶ。
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        if segue.identifier == "saveEdit" {
            // 変更テキストをセットします。
            editedText = textView.text
        }
    }
}
