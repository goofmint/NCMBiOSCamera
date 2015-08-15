//
//  DetailViewController.swift
//  NCMBiOS_Camera
//
//  Created by naokits on 6/18/15.
//  Copyright (c) 2015 Naoki Tsutsui. All rights reserved.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet weak var filenameLabel: UILabel!
    @IBOutlet weak var photoImageView: UIImageView!


    var detailItem: String? {
        didSet {
            // Update the view.
            self.configureView()
        }
    }

    func configureView() {
        // Update the user interface for the detail item.
        if let filename = self.detailItem {
            if let label = self.filenameLabel {
                label.text = filename
                let fileData = NCMBFile.fileWithName(label.text, data: nil) as! NCMBFile
                UIApplication.sharedApplication().networkActivityIndicatorVisible = true
                fileData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                    UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                    
                    if error != nil {
                        println("写真の取得失敗: \(error)")
                    } else {
                        self.photoImageView.image = UIImage(data: imageData!)
                    }
                }
            }
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.configureView()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
}
