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
    static var keeps:[String] = []
    static var dones:[Date:[String]] = [:]
    
    
    static func downloadTasks() {
        
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
                print(originalText)
            }
            
        }
    }
}
