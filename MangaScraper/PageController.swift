//
//  PageController.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/1/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class PageController: UIViewController {
    
    var chapter: String?
    var filename: String? {
        didSet {
            let path = "\(chapter!)/\(filename!)".stringByReplacingOccurrencesOfString("thumbnail_", withString: "").stringByPrependingDocumentPath()
            imageView.image = UIImage(contentsOfFile: path)
        }
    }
    
    let imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .ScaleAspectFit
        return iv
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()

        view.addSubview(imageView)
        view.addConstraintsWithFormat("H:|[v0]|", views: [imageView])
        view.addConstraintsWithFormat("V:|[v0]|", views: [imageView])
    }

}
