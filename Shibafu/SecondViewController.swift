//
//  SecondViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit

class SecondViewController: UIViewController, UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout {
    
    
    // ===============================
    // collectionView用メソッド
    // ===============================
    // コレクションビュー。
    @IBOutlet weak var collection: UICollectionView!
    
    
    // 個数。
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        
        return shibafuRows.count
    }
    
    
    // セルの大きさとか。
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        // 横方向のスペース調整。
        let horizontalSpace: CGFloat = 9
        let cellSize:CGFloat = collectionView.bounds.width / 8 - horizontalSpace

        // 正方形で返します。
        return CGSize(width: cellSize, height: cellSize)
    }
    
    
    // 描画中に使う: すでに月を書いた。
    private var wroteMonth:Bool = false
    // 描画中に使う: 一週間の月。
    private var thisMonth:String = ""
    
    
    // cellを作成します。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // このセルのdateとint。
        let date:Date = shibafuRows[indexPath.row].key
        let int:Int = shibafuRows[indexPath.row].value
        
        // storyboardで設定したidentifier.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        
        // このセルの列。0〜7
        let column:Int = indexPath.row % 8
        
        // tag番号を使ってLabelインスタンスを生成します。
        let label = cell.contentView.viewWithTag(1) as! UILabel
        
        // 曜日表記行の場合はここで終了。
        if int == WEEKDAY_ROW_VALUE {
            label.text = weekdays[column]
            return cell
        }
        
        // 月表記のための処理です。
        let month = monthFormatter.string(from: date)
        // column0から集計開始。
        if column == 0 {
            thisMonth = month
        } else if column <= 6 {
            // すでにこの月が書かれてたら現在月をチェンジ。
            if wroteMonth && thisMonth != month {
                thisMonth = month
                wroteMonth = false
            }
        }
        
        if column == 7 {
            cell.backgroundColor = UIColor( red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0 )
            if !wroteMonth {
                label.text = thisMonth
                wroteMonth = true
            }
        } else {
            cell.backgroundColor = Utils.getColorFromNum(num: int)
            label.text = dayFormatter.string(from: date)
        }
        
        return cell
    }
    
    
    // ============================================================
    // データを collectionView に反映するメソッド。
    // ============================================================
    // ページロードの瞬間だけ出すデフォルトのリストを定義します。そのあとちゃんとしたデータを取得してreloadDataするからね。
    private var shibafuRows:[(key: Date, value: Int)] = [
        (key: Date(), value: 0),
        ]
    
    
    // 特殊なセルであることを示すvalue値。うん、こういうのはよくないよね。でもラクだからやる。
    private let WEEKDAY_ROW_VALUE:Int = 68453
    
    
    // 曜日。
    private let weekdays:[String] = ["S", "F", "T", "W", "T", "M", "S", "", ]
    
    
    // 芝生リストデータを使って collectionView を更新します。
    func reloadShibafu() {
        
        let array:[(key: Date, value: Int)] = createShibafuRows(dones: Tasks.dones).sorted(by: {$0.0 > $1.0})
        
        // いちばん上の行に曜日をいれたいので、いれておきます。
        shibafuRows.removeAll()
        for _ in 1...8 {
            shibafuRows.append((key: Date(), value: WEEKDAY_ROW_VALUE))
        }
        
        // いちばん右に日付をいれたいので、7つおきに空っぽのデータをいれます。
        for (i,a) in array.enumerated() {
            shibafuRows.append(a)
            if i%7 == 6 {
                shibafuRows.append((key: Date(), value: 0))
            }
        }
        collection.reloadInputViews()
    }
    
    
    // 芝生リスト用のDoneタスクリストを作成します。[日付->達成タスク数]
    private func createShibafuRows(dones:[String:[String]]) -> [Date:Int] {
        
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
    
    
    // 日付だけを表示してくれるformatter。didLoadで中身をいれるよ。
    var dayFormatter:DateFormatter = DateFormatter()
    // 月だけを表示してくれるformatter。didLoadで中身をいれるよ。
    var monthFormatter:DateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayFormatter = Utils.createDateFormatter(format: Utils.FORMAT_D)
        monthFormatter = Utils.createDateFormatter(format: Utils.FORMAT_M)
        
        reloadShibafu()
    }


}

