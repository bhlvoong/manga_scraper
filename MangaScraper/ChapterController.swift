//
//  ViewController.swift
//  MangaScraper
//
//  Created by Brian Voong on 10/31/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class ChapterController: BaseController {
    
    var chapter: String? {
        didSet {
            setupChapter()
        }
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        
        let layout = UICollectionViewFlowLayout()
        layout.minimumInteritemSpacing = 8
        collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
        collectionView?.alwaysBounceVertical = true
        view.layer.masksToBounds = true
    }
    
    private func setupChapter() {
        let fileManager = NSFileManager.defaultManager()
        
        var pages = [String]()
        for element in fileManager.enumeratorAtPath(chapter!.stringByPrependingDocumentPath())!.allObjects {
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

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake((view.frame.width - 32) / 3, 160)
    }
    
    override func collectionView(collectionView: UICollectionView, didSelectItemAtIndexPath indexPath: NSIndexPath) {
        guard let mangaPages = datasource as? MangaPages,
            let filename = mangaPages.objectForIndexPath(indexPath) as? String else {
            return
        }
        
        let controller = ChapterPageController(transitionStyle: UIPageViewControllerTransitionStyle.Scroll,
            navigationOrientation: UIPageViewControllerNavigationOrientation.Horizontal,
            options: nil)
        controller.chapter = chapter
        controller.filename = filename
        controller.pages = mangaPages.pages
        navigationController?.pushViewController(controller, animated: true)
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAtIndex section: Int) -> UIEdgeInsets {
        return UIEdgeInsetsMake(8, 8, 8, 8)
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
                setupImage()
            }
        }
    }
    
    private func setupImage() {
        guard let filename = datasourceItem as? String,
            chapter = (controller as? ChapterController)?.chapter else {
                return
        }
        let path = "\(chapter)/\(filename)".stringByPrependingDocumentPath()
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)) {
            let image = UIImage(contentsOfFile: path)
            self.imageCache[filename] = image
            
            dispatch_async(dispatch_get_main_queue()) { () -> Void in
                self.imageView.image = image
            }
        }
    }
    
}
