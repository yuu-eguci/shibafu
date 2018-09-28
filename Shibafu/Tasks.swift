//
//  Tasks.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import Foundation
import SwiftyDropbox

class Tasks {
    
    
    static let filePath:String = "/test-reminder.txt"
    static var modifiedDate:Date = Date()
    static var normals:[String] = []
    static var dones:[String:[String]] = ["yyyy-MM-dd":["test","test"]]
    
    
    // DLしてnormals,keeps,donesを埋めて、テーブルを更新します。
    static func downloadTasks(table:UITableView) {
        
        // Dropbox認証。
        guard let client = DropboxClientsManager.authorizedClient else {
            print("User isn't authorized. Weird.")
            return
        }
        
        client.files.download(path: self.filePath).response { (response, error) in
            if let response = response {
                
                // ファイルの更新日付です。
                self.modifiedDate = response.0.clientModified
                
                // ファイルの内容です。
                let originalText:String? = String(data:response.1, encoding:.utf8)
                
                // originalText -> lines
                let lines:[String] = self.convertTextToArray(text:originalText!)
                
                // normals作成。
                self.normals = self.pickNormalTasks(lines: lines)
                
                // dones作成。
                self.dones = self.pickDoneTasks(lines: lines)
                
                table.reloadData()
            }
            
        }
    }
    
    
    // テキストをリストにします。
    private static func convertTextToArray(text:String) -> [String] {
        
        // 配列にしつつ空行削除。
        var lines:[String] = text.components(separatedBy: "\n").filter {$0 != ""}
        var lines2:[String] = []
        var i = 0
        while lines.indices.contains(i) {
            
            // インデント行はタスク行に統合します。
            var line:String = lines[i]
            while lines.indices.contains(i+1) && lines[i+1].prefix(1)==" " {
                i += 1
                line += "\n" + lines[i]
            }
            lines2.append(line)
            i += 1
        }
        return lines2
    }
    
    
    // リストからノーマル・継続タスク取り出します。
    private static func pickNormalTasks(lines:[String]) -> [String] {
        
        var ret:[String] = []
        for line in lines {
            
            if Utils.isDoneDateRow(line: line) {
                return ret
            }
            ret.append(line)
        }
        return ret
    }
    
    
    // リストからDoneタスク取り出します。
    private static func pickDoneTasks(lines:[String]) -> [String:[String]] {
        
        var ret:[String:[String]] = [:]
        var i = 0
        while lines.indices.contains(i) {
            
            if !Utils.isDoneDateRow(line: lines[i]) {
                i += 1
                continue
            }
            let date:String = String(lines[i].suffix(10))
            var tasks:[String] = []
            while lines.indices.contains(i+1) && !Utils.isDoneDateRow(line: lines[i+1]) {
                i += 1
                tasks.append(lines[i])
            }
            ret[date] = tasks
        }
        return ret
    }
}
