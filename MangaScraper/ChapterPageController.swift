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
    
    let doneButton: UIButton = {
        let button = UIButton()
        button.setTitle("DONE", forState: .Normal)
        button.setTitleColor(UIColor.whiteColor(), forState: .Normal)
        button.layer.borderColor = UIColor.whiteColor().CGColor
        button.layer.borderWidth = 1
        button.layer.cornerRadius = 3
        button.titleLabel?.font = UIFont.boldSystemFontOfSize(14)
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(doneButton)
        view.addConstraintsWithFormat("H:[v0(60)]-12-|", views: [doneButton])
        view.addConstraintsWithFormat("V:|-20-[v0(30)]", views: [doneButton])
        
        doneButton.addTarget(self, action: "done", forControlEvents: .TouchUpInside)
        
        automaticallyAdjustsScrollViewInsets = false
        edgesForExtendedLayout = .None
        
        dataSource = self
        
        let pageController = PageController()
        pageController.chapter = chapter
        pageController.filename = filename
        setViewControllers([pageController], direction: .Forward, animated: true, completion: nil)
    }
    
    func done() {
        dismissViewControllerAnimated(true, completion: nil)
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
