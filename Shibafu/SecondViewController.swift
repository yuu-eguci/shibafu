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
        
        return Tasks.shibafuRows.count
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
    private var writtenMonths:[String] = []
    // 描画中に使う: 一週間の月。
    private var thisMonth:String = ""
    
    
    // cellを作成します。
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        // このセルのdateとint。
        let date:Date = Tasks.shibafuRows[indexPath.row].key
        let int:Int = Tasks.shibafuRows[indexPath.row].value
        
        // storyboardで設定したidentifier.
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath)
        cell.backgroundColor = UIColor( red: 255/255, green: 255/255, blue: 255/255, alpha: 1.0 )
        
        // このセルの列。0〜7
        let column:Int = indexPath.row % 8
        
        // tag番号を使ってLabelインスタンスを生成します。
        let label = cell.contentView.viewWithTag(1) as! UILabel
        label.text = ""
        
        // 曜日表記行の場合はここで終了。
        if int == Tasks.WEEKDAY_ROW_VALUE {
            label.text = Tasks.weekdays[column]
            return cell
        }
        
        // 月表記のための処理です。週に次の月がまじったところで月を表記します。
        if column == 7 {
            if !writtenMonths.contains(thisMonth) {
                label.text = thisMonth
                writtenMonths.append(thisMonth)
            }
        } else {
            thisMonth = monthFormatter.string(from: date)
            cell.backgroundColor = Utils.getColorFromNum(num: int)
            label.text = dayFormatter.string(from: date)
        }
        
        return cell
    }
    
    
    // ===============================
    // 手動更新
    // ===============================
    // 芝生リストを手動で更新します。
    @IBAction func updateButton(_ sender: Any) {
        
        // Dropboxからデータを取得してcollectionViewに表示します。
        Tasks.downloadTasks(collection:collection)
    }
    
    
    // 日付だけを表示してくれるformatter。didLoadで中身をいれるよ。
    var dayFormatter:DateFormatter = DateFormatter()
    // 月だけを表示してくれるformatter。didLoadで中身をいれるよ。
    var monthFormatter:DateFormatter = DateFormatter()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        dayFormatter = Utils.createDateFormatter(format: Utils.FORMAT_D)
        monthFormatter = Utils.createDateFormatter(format: Utils.FORMAT_M)
        
        // Dropboxからデータを取得してcollectionViewに表示します。
        Tasks.downloadTasks(collection:collection)
    }
}
