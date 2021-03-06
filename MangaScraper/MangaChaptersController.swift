//
//  ChapterController.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/2/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class MangaChaptersController: BaseController {
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        
        collectionView?.contentInset = UIEdgeInsetsMake(0, 0, 58, 0)
        collectionView?.scrollIndicatorInsets = collectionView!.contentInset
        
        self.navigationItem.title = "Boku wa Mari no Naka"
        
        setupChapters()
        reloadCollectionView()
        
        setupDownloadButton()
    }
    
    private func setupChapters() {
        let documentsFolderPath = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)[0]
        
        let manager = NSFileManager.defaultManager()
        var isDir: ObjCBool = false
        
        var chapters = [String]()
        for element in manager.enumeratorAtURL(NSURL(string: documentsFolderPath)!, includingPropertiesForKeys: nil, options: .SkipsSubdirectoryDescendants, errorHandler: nil)!.allObjects {
            
            let fileName = (element as! NSURL).absoluteString.stringByReplacingOccurrencesOfString("file:///", withString: "")
            manager.fileExistsAtPath(fileName, isDirectory: &isDir)
            if isDir {
                let dirName = fileName.substringToIndex(fileName.startIndex.advancedBy(fileName.characters.count - 1)).componentsSeparatedByString("/").last!
                chapters.append(dirName)
                print(dirName)
            }
        }
        
        datasource = MangaChapters(chapters: chapters)
    }
    
    let downloadButton: UIButton = {
        let button = UIButton()
        button.setTitle("Download", forState: .Normal)
        button.backgroundColor = UIColor.rgb(0, green: 122, blue: 255)
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        button.layer.borderColor = UIColor(white: 0.4, alpha: 0.4).CGColor
        button.layer.borderWidth = 0.5
        button.layer.cornerRadius = 3
        return button
    }()
    
    func setupDownloadButton() {
        guard let containerView = collectionView?.superview else {
            return
        }
        
        downloadButton.addTarget(self, action: "downloadNextChapter", forControlEvents: .TouchUpInside)
        
        containerView.addSubview(downloadButton)
        containerView.addConstraintsWithFormat("H:|-8-[v0]-8-|", views: [downloadButton])
        containerView.addConstraintsWithFormat("V:[v0(50)]-8-|", views: [downloadButton])
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let chapter = datasource?.objectForIndexPath(indexPath) as? String else {
            return
        }
        
        let controller = ChapterController(nibName: nil, bundle: nil)
        controller.chapter = chapter
        navigationController?.pushViewController(controller, animated: true)
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((view.frame.width - 32) / 3, 200)
    }
    
    func downloadNextChapter() {
        downloadButton.enabled = false
        downloadButton.alpha = 0.5
        
        guard var chapters = (self.datasource as? MangaChapters)?.chapters! else {
            return
        }
        
        let downloader = MangaDownloader()
        let numChapters = chapters.count
        
        var chaptersWithDownloadingPlaceholder = chapters
        chaptersWithDownloadingPlaceholder.append("Downloading...")
        datasource = MangaChapters(chapters: chaptersWithDownloadingPlaceholder)
        collectionView?.insertItemsAtIndexPaths([NSIndexPath(forItem: chaptersWithDownloadingPlaceholder.count - 1, inSection: 0)])
        
        downloader.downloadChapter(numChapters + 1, page: 0, completion: { () -> () in
            self.downloadButton.enabled = true
            self.downloadButton.alpha = 1
            
            print("finished downloading")
            
            let chapterString = String(format: "%03d", numChapters + 1)
            let path = chapterString.stringByPrependingDocumentPath()
            for element in NSFileManager.defaultManager().enumeratorAtPath(path)!.allObjects {
                print(element)
            }
            
            chapters.append(chapterString)
            
            self.datasource = MangaChapters(chapters: chapters)
            self.collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: chapters.count - 1, inSection: 0)])
            
            }) { (pageNumber) -> () in
                self.updateDownloadStatusWithPageNumber(pageNumber)
        }
    }
    
    private func updateDownloadStatusWithPageNumber(pageNumber: Int) {
        guard let chapters = (datasource as? MangaChapters)?.chapters,
            lastChapter = chapters.last else {
            return
        }
        
        if lastChapter.containsString("Downloading") {
            var updatedChapters = chapters
            updatedChapters.removeLast()
            updatedChapters.append("Downloading \(pageNumber)")
            datasource = MangaChapters(chapters: updatedChapters)
            collectionView?.reloadItemsAtIndexPaths([NSIndexPath(forItem: updatedChapters.count - 1, inSection: 0)])
        }
    }

}

class MangaChapters: Datasource {
    
    var chapters: [String]?
    
    init(chapters: [String]?) {
        self.chapters = chapters
    }
    
    override func numberOfItemsForSection(section: NSInteger) -> NSInteger {
        return chapters != nil ? chapters!.count : 0
    }
    
    override func cellClasses() -> [AnyClass] {
        return [MangaChapterCell.self, MangaChapterDownloadingCell.self]
    }
    
    override func cellClassForIndexPath(indexPath: NSIndexPath) -> AnyClass? {
        if chapters![indexPath.item].containsString("Downloading") {
            return MangaChapterDownloadingCell.self
        }
        return MangaChapterCell.self
    }
    
    override func objectForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return chapters?[indexPath.item]
    }
    
}

class MangaChapterCell: BaseCell {
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .ScaleAspectFill
        return iv
    }()
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.textAlignment = .Center
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        layer.masksToBounds = true
        imageView.layer.borderColor = UIColor(white: 0.4, alpha: 0.4).CGColor
        imageView.layer.borderWidth = 0.5
        imageView.layer.masksToBounds = true
        
        addSubview(imageView)
        addSubview(nameLabel)
        
        addConstraintsWithFormat("H:|[v0]|", views: [imageView])
        addConstraintsWithFormat("H:|[v0]|", views: [nameLabel])
        addConstraintsWithFormat("V:|[v0]-8-[v1(20)]-8-|", views: [imageView, nameLabel])
    }
    
    override var datasourceItem: AnyObject? {
        didSet {
            guard let chapter = datasourceItem as? String else {
                return
            }
            
            nameLabel.text = chapter
            
            guard let firstThumbnail = getFirstThumbnailName() else {
                return
            }
            
            let path = "\(chapter)/\(firstThumbnail)".stringByPrependingDocumentPath()
            dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) { () -> Void in
                let image = UIImage(contentsOfFile: path)
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.imageView.image = image
                })
            }
        }
    }
    
    private func getFirstThumbnailName() -> String? {
        guard let chapter = datasourceItem as? String else {
            return nil
        }
        
        let path = "\(chapter)".stringByPrependingDocumentPath()
        for element in NSFileManager.defaultManager().enumeratorAtPath(path)!.allObjects as! [String] {
            if element.containsString("thumbnail") {
                return element
            }
        }
        
        return nil
    }
    
}

class MangaChapterDownloadingCell: BaseCell {
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let aiv = UIActivityIndicatorView(activityIndicatorStyle: .WhiteLarge)
        aiv.startAnimating()
        aiv.hidesWhenStopped = true
        aiv.color = UIColor.darkGrayColor()
        return aiv
    }()
    
    let statusLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFontOfSize(14)
        label.text = "Downloading"
        label.textAlignment = .Center
        return label
    }()
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(activityIndicatorView)
        addSubview(statusLabel)
        
        addConstraintsWithFormat("H:|[v0]|", views: [activityIndicatorView])
        addConstraintsWithFormat("H:|[v0]|", views: [statusLabel])
        addConstraintsWithFormat("V:|[v0][v1(24)]|", views: [activityIndicatorView, statusLabel])
    }
    
    override var datasourceItem: AnyObject? {
        didSet {
            guard let status = datasourceItem as? String else {
                return
            }
            
            statusLabel.text = status
        }
    }
}