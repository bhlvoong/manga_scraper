//
//  ChapterPageController.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/2/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class ChapterPageController: UIPageViewController, UIPageViewControllerDataSource {
    
    var chapter: String?
    var filename: String?
    var pages: [String]?

    override func viewDidLoad() {
        super.viewDidLoad()
        
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .None
        
        dataSource = self
        
        let pageController = PageController()
        pageController.chapter = chapter
        pageController.filename = filename
        setViewControllers([pageController], direction: .Forward, animated: true, completion: nil)
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerBeforeViewController viewController: UIViewController) -> UIViewController? {
        
        guard let pageController = viewController as? PageController,
        let index = pages?.indexOf(pageController.filename!) where index > 0 else {
            return nil
        }
        
        let controller = PageController()
        controller.chapter = chapter
        controller.filename = pages![index - 1]
        return controller
    }
    
    func pageViewController(pageViewController: UIPageViewController, viewControllerAfterViewController viewController: UIViewController) -> UIViewController? {
        
        guard let pageController = viewController as? PageController,
            let index = pages?.indexOf(pageController.filename!) where index < pages!.count - 1 else {
                return nil
        }
        
        let controller = PageController()
        controller.chapter = chapter
        controller.filename = pages![index + 1]
        return controller
    }

}
