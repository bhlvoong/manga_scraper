//
//  BaseCell.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/1/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class BaseCell: UICollectionViewCell {
    
    var controller: UIViewController?
    var datasourceItem: AnyObject?
    
    let topBorder: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.2, alpha: 0.2)
        return v
    }()
    let bottomBorder: UIView = {
        let v = UIView()
        v.backgroundColor = UIColor(white: 0.2, alpha: 0.3)
        return v
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupViews()
    }
    
    func setupViews() {
        
    }
    
    func setupBorders() {
        addSubview(topBorder)
        addConstraintsWithFormat("H:|[v0]|", views: [topBorder])
        addConstraintsWithFormat("V:|[v0(0.5)]", views: [topBorder])
        
        addSubview(bottomBorder)
        addConstraintsWithFormat("H:|[v0]|", views: [bottomBorder])
        addConstraintsWithFormat("V:[v0(0.5)]|", views: [bottomBorder])
    }
    
    func setTopBorderHidden(hide: Bool) {
        topBorder.hidden = hide
    }
    
    func setBottomBorderHidden(hide: Bool) {
        bottomBorder.hidden = hide
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func preferredLayoutAttributesFittingAttributes(layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        return layoutAttributes
    }
}