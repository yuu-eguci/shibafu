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
    
    
    static let filePath:String = "/reminder.txt"
    static var modifiedDate:Date = Date()
    static var normals:[String] = []
    static var dones:[String:[String]] = ["yyyy-MM-dd":["test","test"]]
    static var shibafuRows:[(key: Date, value: Int)] = []
    
    // 特殊なセルであることを示すvalue値。うん、これはよくないよね。でもラクだからやる。
    static let WEEKDAY_ROW_VALUE:Int = 68453
    // 曜日。
    static let weekdays:[String] = ["S", "F", "T", "W", "T", "M", "S", "", ]
    
    
    // DLしてnormals,keeps,donesを埋めて、テーブルあるいはcollectionViewを更新します。
    static func downloadTasks(table:UITableView?=nil, collection:UICollectionView?=nil, label:UILabel?=nil) {
        
        // Dropbox認証。
        guard let client:DropboxClient = DropboxClientsManager.authorizedClient else {
            print("User isn't authorized. Weird.")
            return
        }
        
        client.files.download(path: self.filePath).response { (response, error) in
            if let response = response {
                
                // ファイルの更新日付です。
                self.modifiedDate = response.0.clientModified
                //self.modifiedDate = Date(timeInterval: -60*60*24, since: Date())
                
                // ファイルの内容です。
                let originalText:String? = String(data:response.1, encoding:.utf8)
                
                // originalText -> lines
                let lines:[String] = self.convertTextToArray(text:originalText!)
                
                // normals作成。
                self.normals = self.pickNormalTasks(lines: lines)
                
                // dones作成。
                self.dones = self.pickDoneTasks(lines: lines)
                
                // 日付が変わってたら完了タスクをdoneへ送ります。
                let formatter:DateFormatter = Utils.createDateFormatter(format: Utils.FORMAT_YMD)
                if formatter.string(from: self.modifiedDate) != formatter.string(from: Date()) {
                    self.organizeTasks()
                    self.uploadTasks(label: label)
                }
                
                if table != nil {
                    table?.reloadData()
                }
                else if collection != nil {
                    // 芝生用リスト作成。
                    self.shibafuRows = self.createShibafuRows(dones: self.dones)
                    collection?.reloadData()
                }
            }
        }
    }
    
    
    // テキストをリストにします。
    private static func convertTextToArray(text:String) -> [String] {
        
        // 配列にしつつ空行削除。
        let lines:[String] = text.components(separatedBy: "\n").filter {$0 != ""}
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
            while lines.indices.contains(i+1) && !Utils.isDoneDateRow(line: lines[i+1]) && !Utils.isDoneDateRow(line: lines[i+1]) {
                i += 1
                tasks.append(lines[i])
            }
            if tasks.isEmpty {
                i += 1
                continue
            }
            ret[date] = tasks
        }
        return ret
    }
    
    
    // normalsから完了済みタスクをdonesへ送ります。
    private static func organizeTasks() {
        
        // normals整理。
        var lines:[String] = []
        for (i,line) in normals.enumerated() {
            if Utils.isDoneTask(line: line) {
                lines.append(Utils.getRidOfOK(line: line))
                if Utils.isKeepTask(line: line) {
                    normals[i] = Utils.getRidOfOK(line: line)
                } else {
                    normals[i] = ""
                }
            }
        }
        normals = normals.filter {!$0.isEmpty}
        if lines.isEmpty {
            return
        }
        
        // donesへ追加。
        let formatter:DateFormatter = Utils.createDateFormatter(format: Utils.FORMAT_YMD)
        dones[formatter.string(from: Date(timeInterval: -60*60*24, since: Date()))] = lines
    }
    
    
    // 芝生リストデータを使って collectionView を更新します。
    private static func createShibafuRows(dones:[String:[String]]) -> [(key: Date, value: Int)] {
        
        let array:[(key: Date, value: Int)] = createOriginalShibafuRows(dones: dones).sorted(by: {$0.0 > $1.0})
        
        // いちばん上の行に曜日をいれたいので、いれておきます。
        var shibafuRows:[(key: Date, value: Int)] = []
        for _ in 1...8 {
            shibafuRows.append((key: Date(), value: self.WEEKDAY_ROW_VALUE))
        }
        
        // いちばん右に日付をいれたいので、7つおきに空っぽのデータをいれます。
        for (i,a) in array.enumerated() {
            shibafuRows.append(a)
            if i%7 == 6 {
                shibafuRows.append((key: Date(), value: 0))
            }
        }
    
        return shibafuRows
    }
    
    
    // 芝生リスト用のDoneタスクリストを作成します。[日付->達成タスク数]
    private static func createOriginalShibafuRows(dones:[String:[String]]) -> [Date:Int] {
        
        // 1日足したりするためにキーをDateに直します。
        var a:[Date:Int] = [:]
        for (date, lines) in dones {
            a[Utils.getDateFromString(string:date)] = lines.count
        }
        
        // リスト内いちばん昔の日 〜 今日から未来の土曜日 までの歯抜け日を埋めます。
        let closeSaturday:Date = Utils.getCloseSaturday()
        
        // リスト内の歯抜けしてる日を埋めます。
        var d:Date = a.keys.min()!
        while d <= closeSaturday {
            if !a.keys.contains(d) {
                a[d] = 0
            }
            // +1日
            d = Date(timeInterval: 60*60*24, since: d)
        }
        
        return a
    }
    
    
    // 現在の状態をアップロードします。
    static func uploadTasks(label:UILabel?=nil) {
        
        // Dropbox認証。
        guard let client:DropboxClient = DropboxClientsManager.authorizedClient else {
            print("User isn't authorized. Weird.")
            return
        }
        
        // タスク配列をテキストにします。
        var text:String = "\n\n"
        text += self.convertListToText(lines: self.normals)
        text += self.convertDonesToText(dones: self.dones)
        text += "\n"
        let uploadData = text.data(using: String.Encoding.utf8, allowLossyConversion: false)!
        
        client.files.upload(path: filePath, mode: .overwrite, autorename: false, input: uploadData)
            .response {response, error in
            
            if let response = response {
                
                // ファイルの更新日付を更新します。
                if label != nil {
                    let formatter = Utils.createDateFormatter(format: Utils.FORMAT_YMDHMS)
                    label?.text = "Last modified:" + formatter.string(from: response.clientModified)
                }
            } else if let error = error {
                print(error)
            }
        }
        .progress { progressData in
            print(progressData)
        }
    }
    
    
    // リストを文字列にします。
    private static func convertListToText(lines:[String]) -> String {
        
        return lines.joined(separator: "\n\n")
    }
    
    
    // Doneタスクを文字列にします。
    private static func convertDonesToText(dones:[String:[String]]) -> String {
        
        var ret:String = "\n\n\n\n\n"
        
        // 日付降順にします。
        for (date, lines) in dones.sorted(by: {$0.0 > $1.0}) {
            ret += "\n=====\(date)\n" + lines.joined(separator: "\n")
        }
        return ret
    }
}
