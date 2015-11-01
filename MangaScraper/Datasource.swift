//
//  Datasource.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/1/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class Datasource: NSObject {
    
    func numberOfSections() -> NSInteger {
        return 1
    }
    
    func numberOfItemsForSection(section: NSInteger) -> NSInteger {
        return NSInteger(0)
    }
    
    func cellClasses() -> [AnyClass] {
        return []
    }
    
    func cellClassForIndexPath(indexPath: NSIndexPath) -> AnyClass? {
        return nil
    }
    
    func objectForIndexPath(indexPath: NSIndexPath) -> AnyObject? {
        return nil
    }
    
    func objectForSection(section: NSInteger) -> AnyObject? {
        return nil
    }
    
    func headerClasses() -> [AnyClass] {
        return []
    }
    
    func headerClassForIndexPath(indexPath: NSIndexPath) -> AnyClass? {
        return nil
    }
    
    func footerClasses() -> [AnyClass] {
        return []
    }
    
    func footerClassForIndexPath(indexPath: NSIndexPath) -> AnyClass? {
        return nil
    }
    
}