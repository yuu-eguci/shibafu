//
//  EditTableViewController.swift
//  Shibafu
//
//  Created by Midori on 2018/09/28.
//  Copyright © 2018年 Mate. All rights reserved.
//

import UIKit

class EditTableViewController: UITableViewController, UITextViewDelegate {
    
    
    @IBOutlet weak var textView: UITextView!
    @IBOutlet var table: UITableView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // テキストビューを高さ可変にします。
        table.rowHeight = UITableView.automaticDimension
        table.rowHeight = 10000
        textView.delegate = self
        
        // テキストビューにカーソルをあわせます。
        textView.becomeFirstResponder()
    }


    override func numberOfSections(in tableView: UITableView) -> Int {
        return 0
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 0
    }
}
