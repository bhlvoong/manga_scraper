//
//  Extension.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/1/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

extension UIView {
    func addConstraintsWithFormat(format: String, views: [UIView]) {
        var viewDictionary = [String: AnyObject]()
        for (index, view) in views.enumerate() {
            let key = "v\(index)"
            viewDictionary[key] = view
            view.translatesAutoresizingMaskIntoConstraints = false
        }
        addConstraints(NSLayoutConstraint.constraintsWithVisualFormat(format, options: NSLayoutFormatOptions(), metrics: nil, views: viewDictionary))
    }
}

extension UICollectionView {
    func registerClass(clazz: AnyClass) {
        registerClass(clazz, forCellWithReuseIdentifier: NSStringFromClass(clazz))
    }
    
    func registerHeaderClass(clazz: AnyClass) {
        registerClass(clazz, forSupplementaryViewOfKind: UICollectionElementKindSectionHeader, withReuseIdentifier: NSStringFromClass(clazz))
    }
    
    func registerFooterClass(clazz: AnyClass) {
        registerClass(clazz, forSupplementaryViewOfKind: UICollectionElementKindSectionFooter, withReuseIdentifier: NSStringFromClass(clazz))
    }
}

extension UIColor {
    static func rgb(red: CGFloat, green: CGFloat, blue: CGFloat) -> UIColor {
        return UIColor(red: red/255.0, green: green/255.0, blue: blue/255.0, alpha: 1)
    }
}
