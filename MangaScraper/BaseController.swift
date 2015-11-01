//
//  BaseController.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/1/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class BaseController: UICollectionViewController, UICollectionViewDelegateFlowLayout {
    
    let refreshControl: UIRefreshControl = {
        let rc = UIRefreshControl()
        return rc
    }()
    
    var datasource: Datasource? {
        didSet {
            if datasource != nil {
                for clazz in datasource!.cellClasses() {
                    collectionView?.registerClass(clazz)
                }
                
                for clazz in datasource!.headerClasses() {
                    collectionView?.registerHeaderClass(clazz)
                }
                
                for clazz in datasource!.footerClasses() {
                    collectionView?.registerFooterClass(clazz)
                }
            }
        }
    }
    
    let activityIndicatorView: UIActivityIndicatorView = {
        let indicatorView = UIActivityIndicatorView()
        indicatorView.hidesWhenStopped = true
        indicatorView.startAnimating()
        indicatorView.color = UIColor.darkGrayColor()
        return indicatorView
    }()
    
    var shouldRefreshOnDidAppear: Bool = false
    
    func refresh() {
        
    }
    
    func reloadCollectionView() {
        collectionView?.reloadData()
        activityIndicatorView.stopAnimating()
    }
    
    func setupBackButton() {
        let backButton = UIButton()
        backButton.setImage(UIImage(named: "arrow_back_wht"), forState: UIControlState.Normal)
        backButton.frame = CGRectMake(0, 0, 14, 44)
        backButton.addTarget(self, action: Selector("back"), forControlEvents: UIControlEvents.TouchUpInside)
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: backButton)
    }
    
    func back() {
        navigationController?.popViewControllerAnimated(true)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    override init(collectionViewLayout layout: UICollectionViewLayout) {
        super.init(collectionViewLayout: layout)
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        let layout = UICollectionViewFlowLayout()
        layout.minimumLineSpacing = 0
        collectionView = UICollectionView(frame: CGRect.zero, collectionViewLayout: layout)
        collectionView?.alwaysBounceVertical = true
        collectionView?.backgroundColor = UIColor(white: 0.95, alpha: 1)
    }
    
    func setupActivityIndicatorView() {
        collectionView?.superview?.addSubview(activityIndicatorView)
        collectionView?.superview?.addConstraintsWithFormat("H:[v0(30)]", views: [activityIndicatorView])
        collectionView?.superview?.addConstraintsWithFormat("V:[v0(30)]", views: [activityIndicatorView])
        collectionView?.superview?.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.CenterX, relatedBy: NSLayoutRelation.Equal, toItem: collectionView?.superview, attribute: NSLayoutAttribute.CenterX, multiplier: 1, constant: 0))
        collectionView?.superview?.addConstraint(NSLayoutConstraint(item: activityIndicatorView, attribute: NSLayoutAttribute.CenterY, relatedBy: NSLayoutRelation.Equal, toItem: collectionView?.superview, attribute: NSLayoutAttribute.CenterY, multiplier: 1, constant: 0))
    }
    
    func collectionView(collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: NSIndexPath) -> CGSize {
        return CGSizeMake(view.frame.width, 50)
    }
    
    override func numberOfSectionsInCollectionView(collectionView: UICollectionView) -> Int {
        return datasource != nil ? datasource!.numberOfSections() : 0
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return datasource!.numberOfItemsForSection(section)
    }
    
    override func collectionView(collectionView: UICollectionView, cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        
        var cellClass: AnyClass? = datasource!.cellClassForIndexPath(indexPath)
        if cellClass == nil {
            cellClass = datasource!.cellClasses()[indexPath.section]
        }
        let cell = collectionView.dequeueReusableCellWithReuseIdentifier(NSStringFromClass(cellClass!), forIndexPath: indexPath) as! BaseCell
        cell.controller = self
        cell.datasourceItem = datasource!.objectForIndexPath(indexPath)
        return cell
    }
    
    override func collectionView(collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, atIndexPath indexPath: NSIndexPath) -> UICollectionReusableView {
        
        if kind == UICollectionElementKindSectionHeader {
            var headerClass : AnyClass? = datasource!.headerClassForIndexPath(indexPath)
            if headerClass == nil {
                headerClass = datasource!.headerClasses()[indexPath.section]
            }
            
            let header = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(headerClass!), forIndexPath: indexPath) as! BaseCell
            header.controller = self
            header.setBottomBorderHidden(true)
            header.datasourceItem = datasource?.objectForSection(indexPath.section)
            return header
        } else {
            var footerClass : AnyClass? = datasource!.footerClassForIndexPath(indexPath)
            if footerClass == nil {
                footerClass = datasource!.footerClasses()[indexPath.section]
            }
            
            let footer = collectionView.dequeueReusableSupplementaryViewOfKind(kind, withReuseIdentifier: NSStringFromClass(footerClass!), forIndexPath: indexPath) as! BaseCell
            footer.controller = self
            footer.setTopBorderHidden(true)
            return footer
        }
    }
    
    override func willAnimateRotationToInterfaceOrientation(toInterfaceOrientation: UIInterfaceOrientation, duration: NSTimeInterval) {
        super.willAnimateRotationToInterfaceOrientation(toInterfaceOrientation, duration: duration)
        collectionView?.collectionViewLayout.invalidateLayout()
    }
    
    func errorHandler(error: NSError) -> () {
        showError(error)
        refreshControl.endRefreshing()
        print(error.description)
    }
    
    func showError(error: NSError) {
        UIAlertView(title: "Login failed", message: error.description, delegate: nil, cancelButtonTitle: "OK").show()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
}
