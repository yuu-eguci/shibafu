//
//  Utils.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit

class Utils {
    
    
    // DateFormats
    static let FORMAT_YMDHMS:String = "yyyy-MM-dd HH:mm:ss"
    static let FORMAT_YMD:String = "yyyy-MM-dd"
    static let FORMAT_M:String = "M"
    static let FORMAT_D:String = "d"
    
    
    // 継続タスクである。
    static func isKeepTask(line:String) -> Bool {
        return line.prefix(1) == "*"
    }
    
    
    // 日付タスクである。
    static func isScheduleTask(line:String) -> Bool {
        return line.prefix(1) == "-"
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
    
    
    // 色リスト
    private static let colors:[UIColor] = [
        UIColor( red: 228/255, green: 231/255, blue: 235/255, alpha: 1.0 ),
        UIColor( red: 179/255, green: 224/255, blue: 119/255, alpha: 1.0 ),
        UIColor( red: 87/255, green: 191/255, blue: 91/255, alpha: 1.0 ),
        UIColor( red: 0/255, green: 137/255, blue: 47/255, alpha: 1.0 ),
        UIColor( red: 0/255, green: 79/255, blue: 32/255, alpha: 1.0 ),
        ]
    
    
    // 数値を受け取って色を返します。
    static func getColorFromNum(num:Int) -> UIColor {
        if num >= 10 {
            return colors.last!
        }
        if num == 0 {
            return UIColor( red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0 )
        }
        return colors[num / 2]
    }
}
