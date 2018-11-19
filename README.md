
Shibafu
===

自分専用TODOアプリ。はじめてのiOSアプリ挑戦。

![1](media/Shibafu_1.jpg)

![2](media/Shibafu_2.jpg)

## Description

- ふつーのTODO機能
- タスクはプレーンテキストでDropbox上に置かれる
- ぱそこのエディタでも、アプリ上でも編集可能
- タスクをこなし模様をGitHub的芝生で閲覧

## Installation

- clone する
- `$ pod install` する。別途cocoapodが必要。
- SwiftyDropboxライブラリはお使いのSwiftバージョンと合ってない可能性があるので、もしエラー出たらそこを修正する。

## Issues

現在認識している問題、改善可能点。

- 入力の長押しでペーストとか出ない。へー、あれってアプリ側で出すのを設定していることだったのか…
- Activities で特定条件下で月の数字が消える。update押したときやスクロールしたとき。
- Add とか Edit の画面に Cancel があったほうがいい。優先度は低めだよね。
