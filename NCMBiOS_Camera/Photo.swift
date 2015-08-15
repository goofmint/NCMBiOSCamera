//
//  Photo.swift
//  NCMBiOS_Camera
//
//  Created by naokits on 6/22/15.
//  Copyright (c) 2015 Naoki Tsutsui. All rights reserved.
//

import UIKit

@objc(Photo) // <-- この宣言をしないと、ハングアップする
class Photo: NCMBObject, NCMBSubclassing {
    
    /// ニックネーム
    var filename: String! {
        get {
            return objectForKey("filename") as! String
        }
        set {
            setObject(newValue, forKey: "filename")
        }
    }
    
    // ------------------------------------------------------------------------
    // MARK: NCMBSubclassing Protocol
    // ------------------------------------------------------------------------
    
    /// mobile backend上のクラス名を返却する。
    ///
    /// :returns: サブクラスのデータストア上でのクラス名
    static func ncmbClassName() -> String! {
        return "Photo"
    }
}
