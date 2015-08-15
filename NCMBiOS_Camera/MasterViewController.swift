//
//  MasterViewController.swift
//  NCMBiOS_Camera
//
//  Created by naokits on 6/18/15.
//

import UIKit

let kTodoClassName = "Photo"

class MasterViewController: UICollectionViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    var objects = [Photo]()
    var photoImages = [UIImage]()
    
    // ------------------------------------------------------------------------
    // MARK: - Life Cycle
    // ------------------------------------------------------------------------
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        //self.navigationItem.leftBarButtonItem = self.editButtonItem()
        
        // let addButton = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: "insertNewObject:")
        // self.navigationItem.rightBarButtonItem = addButton
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
        if self.objects.count == 0 {
            self.fetchAllPhotos()
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // ------------------------------------------------------------------------
    // MARK: - Segues
    // ------------------------------------------------------------------------
    
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        if segue.identifier == "showDetail" {
            let cell = sender as! PhotoCell
            
            if let indexPath = self.collectionView?.indexPathForCell(cell) {
                let photo = self.objects[indexPath.row]
                (segue.destinationViewController as! DetailViewController).detailItem = photo.filename
            }
        }
    }
   
    
    // ------------------------------------------------------------------------
    // MARK: - UICollectionView
    // ------------------------------------------------------------------------

    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return 1
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return objects.count
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell: PhotoCell = self.collectionView?.dequeueReusableCellWithReuseIdentifier("PhotoCell", forIndexPath: indexPath) as! PhotoCell

        let photo = objects[indexPath.row]
        cell.photoImageView?.image = nil
        
        if cell.photoImageView?.image == nil {
            UIApplication.sharedApplication().networkActivityIndicatorVisible = true
            
            let fileData = NCMBFile.fileWithName(photo.filename, data: nil) as! NCMBFile
            fileData.getDataInBackgroundWithBlock { (imageData: NSData?, error: NSError!) -> Void in
                UIApplication.sharedApplication().networkActivityIndicatorVisible = false
                
                if error != nil {
                    println("写真の取得失敗: \(error)")
                } else {
                    cell.photoImageView?.image = UIImage(data: imageData!)
                    cell.layoutSubviews()
                }
            }
        }
        return cell
    }
    
    // ------------------------------------------------------------------------
    // MARK: Actions
    // ------------------------------------------------------------------------

    /// カメラボタンをタップした時に呼ばれます。
    @IBAction func tappedCameraButton(sender: AnyObject) {
        self.startCamera()
    }
    
    /// カメラを起動します
    func startCamera() {
        // カメラが利用できるか確認
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.Camera) {
            dispatch_async(dispatch_get_main_queue(), { () -> Void in
                var ipc: UIImagePickerController = UIImagePickerController()
                ipc.delegate = self
                ipc.sourceType = UIImagePickerControllerSourceType.Camera
                //            ipc.allowsEditing = false
                ipc.showsCameraControls = true
                self.presentViewController(ipc, animated: true, completion: nil)
            })
        } else {
            println("カメラが利用できません。実機にて実行してください。")
        }
    }
    
    // ------------------------------------------------------------------------
    // MARK: UIImagePickerControllerDelegate
    // ------------------------------------------------------------------------
    
    /// 写真撮影終了時の処理を実行します
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [NSObject : AnyObject]) {
        println("撮影終了")
        if info[UIImagePickerControllerOriginalImage] != nil {
            if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
                println("端末のカメラロールに保存します: \(image)")
                UIImageWriteToSavedPhotosAlbum(image, self, "image:didFinishSavingWithError:contextInfo:", nil)
            }
        }
        
        picker.dismissViewControllerAnimated(true, completion: nil)
    }
    
    /// カメラロールへの保存終了時の処理を実行します
    func image(image: UIImage, didFinishSavingWithError error: NSError!, contextInfo: UnsafeMutablePointer<Void>) {
        if error == nil {
            println("写真の保存に成功しました: \(contextInfo)")
            println("NCMBに画像ファイルを送信します。")
            self.uploadPhotoWighImage(image)
        } else {
            println("保存できませんでした: \(error)")
            if error.code == -3310 {
                println("プライバシー設定不許可などの理由で書き込み失敗（ALAssetsLibraryDataUnavailableError）")
            }
        }
    }
    
    // ------------------------------------------------------------------------
    // MARK: Upload
    // ------------------------------------------------------------------------
    
    func uploadPhotoWighImage(image: UIImage) {
        let resizedImage = self.resizeImage(image, ratio: 0.1) // 10% に縮小
        let pngData = NSData(data: UIImagePNGRepresentation(resizedImage))
        println("データサイズ: \(pngData.length / 1024)")

        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        let file = NCMBFile.fileWithData(pngData) as! NCMBFile
        file.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if error == nil {
                let photo = Photo.object() as! Photo
                photo.filename = file.name
                println("保存完了: \(photo.filename)")
                photo.saveInBackgroundWithBlock({ (error: NSError!) -> Void in
                    if error == nil {
                        self.objects.insert(photo, atIndex: 0)
                        let indexPath = NSIndexPath(forRow: 0, inSection: 0)
                        self.collectionView?.insertItemsAtIndexPaths([indexPath])
                    } else {
                        println("写真情報をデータストアに保存失敗: \(error)")
                    }
                })
            } else {
                println("アップロード中にエラーが発生しました: \(error)")
                if error.code == 413001 {
                    println("ファイルサイズが大きすぎます")
                }
            }
        }, progressBlock: { (percentDone: Int32) -> Void in
            // 進捗状況を取得します。保存完了まで何度も呼ばれます
            println("進捗状況: \(percentDone)% アップロード済み")
        })
    }
    
    // ------------------------------------------------------------------------
    // MARK: Utility Mthods
    // ------------------------------------------------------------------------

    /// 画像を指定された比率に縮小して返します
    func resizeImage(image: UIImage, ratio: CGFloat) -> UIImage {
        let size = CGSizeMake(image.size.width * ratio, image.size.height * ratio)
        UIGraphicsBeginImageContext(size)
        
        image.drawInRect(CGRectMake(0, 0, size.width, size.height))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        
        UIGraphicsEndImageContext()
        
        return resizedImage
    }
    
    // ------------------------------------------------------------------------
    // MARK: 画像ファイルの取得関連
    // ------------------------------------------------------------------------
    
    /// 全ての写真情報を取得し、プロパティに格納します
    ///
    /// :param: None
    /// :returns: None
    func fetchAllPhotos() {
        var query = Photo.query() as NCMBQuery
        // タイトルにデータが含まれないものは除外
        query.whereKeyExists("filename")
        // 登録日の降順で取得
        query.orderByDescending("createDate")
        // 取得件数の指定
        query.limit = 20
        
        UIApplication.sharedApplication().networkActivityIndicatorVisible = true
        query.findObjectsInBackgroundWithBlock({(photos, error) in
            UIApplication.sharedApplication().networkActivityIndicatorVisible = false
            if (error == nil) {
                println("登録件数: \(photos.count)")
                for photo in photos as! [Photo] {
                    let filename = photo.objectForKey("filename") as! String!
                    println("--- オブジェクトID: \(photo.objectId) ファイル名: \(filename)")
                }
                self.objects = photos as! [Photo]
                self.collectionView?.reloadData()
            } else {
                println("Error: \(error)")
            }
        })
    }
}

