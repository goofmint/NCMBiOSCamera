

# NCMBiOSCamera

ニフティクラウド mobile backendのファイルストアを使ったデモアプリです。Swift 1.2で記述しています。

## サンプルアプリケーション概要

- アプリ起動時に、NCMBのファイルストアに保存されている画像を取得し、一覧表示します。
- 写真をタップすると、ほぼ実サイズ（クロップしたサイズ）の写真が表示されます。
- 撮影した写真の画像データをクロップしてサイズダウンしてから、NCMBのファイルストアへ保存します。

## 事前知識

- CocoaPodsの利用の仕方やブリッジヘッダーの設定の仕方。
- [クイックスタート](http://mb.cloud.nifty.com/doc/quickstart_ios.html)の内容。

## 動作確認環境

- OS X Yosemite Version 10.10.4 (14E46)
- Xcode Version 6.4 (6E35b)
- ruby 2.1.5p273 (2014-11-13 revision 48405) [x86_64-darwin14.0]
- cocoppods 0.37.2


## 注意事項

Podfileは次のように設定してください。2015年7月14日時点では `use_frameworks!` オプションは利用できませんので注意してください。

### Podfile

```
platform :ios, '8.3'

inhibit_all_warnings!

# # 2015/07/14時点では、このオプションを指定するとビルドエラーが発生します。
# use_frameworks!

pod 'NCMB', :git => 'https://github.com/NIFTYCloud-mbaas/ncmb_ios.git'
```

### APIキー

`Settings.swift` の次の箇所をご自分の環境に合わせて書き換えてください。

```swift
/// アプリケーションキー
let kNCMBiOSApplicationKey = "YOUR_APPLICATION_KEY"
/// クライアントキー
let kNCMBiOSClientKey = "YOUR_CLIENT_KEY"
```

## 関連情報

- [ニフティクラウド mobile backend](http://mb.cloud.nifty.com/)

ファイルストア関連

- [機能ガイド : ファイルストア | ニフティクラウド mobile backend](http://mb.cloud.nifty.com/doc/current/fnguide/filestore.html)
- [ダッシュボードの使い方 : ファイルストア | ニフティクラウド mobile backend](http://mb.cloud.nifty.com/doc/current/dashboard/filestore.html)
- [SDKガイド (iOS) : ファイルストア | ニフティクラウド mobile backend](http://mb.cloud.nifty.com/doc/current/sdkguide/ios/filestore.html)

オブジェクト操作関連

- [SDKガイド (iOS) : オブジェクト操作 | ニフティクラウド mobile backend](http://mb.cloud.nifty.com/doc/current/sdkguide/ios/datastore.html)
- [SDKガイド (iOS) : クエリの使い方 | ニフティクラウド mobile backend](http://mb.cloud.nifty.com/doc/current/sdkguide/ios/query.html)
- [SDKガイド (iOS) : サブクラス | ニフティクラウド mobile backend](http://mb.cloud.nifty.com/doc/current/sdkguide/ios/subclass.html)


類似のサンプルアプリケーション
- [moongift/NCMBiOSTodo](https://github.com/moongift/NCMBiOSTodo)
- [moongift/NCMBiOSUser](https://github.com/moongift/NCMBiOSUser)
- [moongift/NCMBiOSFaceook](https://github.com/moongift/NCMBiOSFaceook  )
- [moongift/NCMBiOSTwitter](https://github.com/moongift/NCMBiOSTwitter)
- [moongift/NCMBiOSGoogle](https://github.com/moongift/NCMBiOSGoogle)

## ライセンス

The MIT License (MIT)
