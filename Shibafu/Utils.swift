//
//  Utils.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import Foundation

class Utils {
    
    
    // 継続タスクである。
    static func isKeepTask(line:String) -> Bool {
        return line.prefix(1) == "*"
    }
    
    
    // Doneタスクである。
    static func isDoneDateRow(line:String) -> Bool {
        return line.prefix(5) == "====="
    }
    
    
    // 完了したタスクである。
    static func isDoneTask(line:String) -> Bool {
        return line.suffix(2) == "OK"
    }
    
    
    // 文字列からOKをとる。
    static func getRidOfOK(line:String) -> String {
        return line.replacingOccurrences(of: "\n    OK", with: "")
    }
    
    
    // yyyy-mm-ddからDate型を取得します。
    static func getDateFromString(string:String) -> Date {
        
        var s:String = string
        let year = Int(s.prefix(4))!
        s = s.replacingOccurrences(of: s.prefix(5), with: "")
        let month = Int(s.prefix(2))!
        s = s.replacingOccurrences(of: s.prefix(3), with: "")
        let day = Int(s)!
        return Calendar.current.date(from: DateComponents(year:year, month:month, day:day))!
    }
    
    
    // DateFormatterを作成します。
    static func createDateFormatter(format: String) -> DateFormatter {
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = format
        return formatter
    }
    
    
    // 今日から一番ちかい土曜を取得します。いま土曜ならそのまま返します。
    static func getCloseSaturday() -> Date {
        
        let formatter:DateFormatter = createDateFormatter(format: "EEE")
        var d:Date = Date()
        while formatter.string(from: d) != "Sat" {
            d = Date(timeInterval: 60*60*24, since: d)
        }
        return d
    }
}
