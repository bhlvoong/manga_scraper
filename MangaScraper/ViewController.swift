//
//  ViewController.swift
//  MangaScraper
//
//  Created by Brian Voong on 10/31/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class ViewController: BaseController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Fetch Pages", style: .Plain, target: self, action: Selector("fetchPages"))
        
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((view.frame.width - 32) / 3, 160)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    var timer: NSTimer?
    
    func scheduleRefreshTimer() {
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.timer?.invalidate()
            self.timer = nil
            
            self.timer = NSTimer.scheduledTimerWithTimeInterval(1, target: self, selector: "refreshThumbnails", userInfo: nil, repeats: false)
        }
    }
    
    func refreshThumbnails() {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let fileManager = NSFileManager.defaultManager()
        
        var pages = [String]()
        for element in fileManager.enumeratorAtPath(documentsFolderPath)!.allObjects {
            guard let pagePath = element as? String where pagePath.containsString("thumbnail") else {
                continue
            }
            
            pages.append(pagePath)
        }
        
        pages = pages.sort()
        
        datasource = MangaPages(pages: pages)
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            self.collectionView?.reloadData()
        }
    }
    
    func fetchPages() {
        for pageUrl in getPageUrls() {
            getImageUrlFromPageUrl(pageUrl, completion: { (imageUrl, error) -> () in
                
                if error != nil {
                    print("Failed to get imageUrl from pageUrl \(pageUrl): \(error?.description)")
                    return
                }
                
                if imageUrl != nil {
                    self.saveImageForUrl(imageUrl!)
                    self.scheduleRefreshTimer()
                    
                } else {
                    print("Could not find imageUrl for page: \(pageUrl)")
                }
                
            })
        }
    }
    
    private func saveImageForUrl(url: String) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) -> Void in
            if error != nil {
                print("Failed fetching image \(url): \(error?.description)")
                return
            }
            
            if data != nil {
                let documentsFolderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
                let chapter = self.getChapterFromImageUrl(url)
                let fileName = self.getFilenameFromImageUrl(url)
                let path = NSString(string: documentsFolderPath).stringByAppendingPathComponent("\(chapter)_\(fileName)")
                data!.writeToFile(path, atomically: true)
                
                let image = UIImage(data: data!)
                let thumbnailSize = CGSizeMake(image!.size.width / 4, image!.size.height / 4)
                UIGraphicsBeginImageContext(thumbnailSize)
                image?.drawInRect(CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height))
                let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let thumbnailData = NSData(data: UIImagePNGRepresentation(thumbnailImage)!)
                let thumbnailPath = NSString(string: documentsFolderPath).stringByAppendingPathComponent("thumbnail_\(chapter)_\(fileName)")
                thumbnailData.writeToFile(thumbnailPath, atomically: true)
                
            }
        }.resume()
    }
    
    private func getChapterFromImageUrl(imageUrl: String) -> String {
        let regex = try!(NSRegularExpression(pattern: "/0.*/compressed/", options: NSRegularExpressionOptions()))
        
        let match = regex.firstMatchInString(imageUrl, options: NSMatchingOptions(), range: NSMakeRange(0, imageUrl.characters.count))
        
        return  NSString(string: imageUrl).substringWithRange(match!.range).stringByReplacingOccurrencesOfString("/compressed/", withString: "").stringByReplacingOccurrencesOfString("/", withString: "")
    }
    
    private func getFilenameFromImageUrl(imageUrl: String) -> String {
        let regex = try!(NSRegularExpression(pattern: "/compressed/.*.jpg", options: NSRegularExpressionOptions()))
        
        let match = regex.firstMatchInString(imageUrl, options: NSMatchingOptions(), range: NSMakeRange(0, imageUrl.characters.count))
        
        return  NSString(string: imageUrl).substringWithRange(match!.range).stringByReplacingOccurrencesOfString("/compressed/", withString: "")
    }
    
    private func getPageUrls() -> [String] {
        var urls = [String]()
        for i in 0...50 {
            urls.append("http://www.mangahere.co/manga/boku_wa_mari_no_naka/c001/\(i).html")
        }
        return urls
    }
    
    func getImageUrlFromPageUrl(pageUrl: String, completion: ((String?, NSError?) -> ())) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: pageUrl)!) { (data, response, error) -> Void in
            
            if error != nil {
                completion(nil, error)
                return
            } else {
                
            }
            
            guard let responseBody = String(data: data!, encoding: NSUTF8StringEncoding) else {
                return
            }
            let imageUrl = self.parseImageUrlForBody(responseBody)
            
            completion(imageUrl, nil)
        }.resume()
    }
    
    private func parseImageUrlForBody(body: String) -> String? {
        let regex = try!(NSRegularExpression(pattern: "http.*?compressed/.*?.jpg", options: NSRegularExpressionOptions()))
        guard let match = regex.firstMatchInString(body, options: NSMatchingOptions(), range: NSMakeRange(0, body.characters.count)) else {
            return nil
        }
        return NSString(string: body).substringWithRange(match.range)
    }
    
}

class MangaPages: Datasource {
    
    let pages: [String]
    
    init(pages: [String]) {
        self.pages = pages
    }
    
    override func numberOfItemsForSection(section: NSInteger) -> NSInteger {
        return pages.count
    }
    
    override func cellClasses() -> [AnyClass] {
        return [ThumbnailCell.self]
    }
    
    override func objectForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return pages[indexPath.item]
    }
    
}

class ThumbnailCell: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .ScaleAspectFill
        return iv
    }()
    
    var imageCache: [String: UIImage] = [String: UIImage]()
    
    override func setupViews() {
        super.setupViews()
        
        layer.masksToBounds = true
        layer.borderColor = UIColor(white: 0.3, alpha: 0.3).CGColor
        layer.borderWidth = 0.5
        
        addSubview(imageView)
        addConstraintsWithFormat("H:|[v0]|", views: [imageView])
        addConstraintsWithFormat("V:|[v0]|", views: [imageView])
    }
    
    override var datasourceItem: AnyObject? {
        didSet {
            guard let pagePath = datasourceItem as? String else {
                return
            }
            
            if let image = imageCache[pagePath] {
                imageView.image = image
            } else {
                imageForFilename(pagePath, completion: { (image) -> () in
                    self.imageCache[pagePath] = image
                    self.imageView.image = image
                })
            }
        }
    }
    
    private func imageForFilename(filename: String, completion: (UIImage) -> ()) {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        let path = NSString(string: documentsFolderPath).stringByAppendingPathComponent(filename)
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                completion(UIImage(contentsOfFile: path)!)
            }
        }
    }
    
}
