//
//  MangaDownloader.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/2/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class MangaDownloader: NSObject {

    func downloadChapter(chapter: Int, page: Int, completion: () ->()) {
        
//        if page == 10 {
//            completion()
//            return
//        }
        
        print("Downloading page: \(page)")
        let pageUrl = "http://www.mangahere.co/manga/boku_wa_mari_no_naka/c00\(chapter)/\(page).html"
        
        getImageUrlFromPageUrl(pageUrl, completion: { (imageUrl, error) -> () in
            
            if error != nil {
                print("Failed to get imageUrl from pageUrl \(pageUrl): \(error?.description)")
                completion()
            }
            
            if imageUrl != nil {
                if page == 0 {
                    self.createDirectoryForChapter(chapter)
                }
                
                self.saveImageForUrl(imageUrl!, chapter: chapter)
                
                self.downloadChapter(chapter, page: page + 1, completion: completion)
                
            } else {
                print("Could not find imageUrl for page: \(pageUrl)")
                //assume we are done
                completion()
            }
            
        })
    }
    
    private func createDirectoryForChapter(chapter: Int) {
        let fileManager = NSFileManager.defaultManager()
        try!fileManager.createDirectoryAtPath("chapter\(chapter)".stringByPrependingDocumentPath(), withIntermediateDirectories: true, attributes: nil)
    }
    
    private func saveImageForUrl(url: String, chapter: Int) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) -> Void in
            if error != nil {
                print("Failed fetching image \(url): \(error?.description)")
                return
            }
            
            if data != nil {
                let fileName = self.getFilenameFromImageUrl(url)
                let path = "chapter\(chapter)/\(fileName)".stringByPrependingDocumentPath()
                data!.writeToFile(path, atomically: true)
                
                let image = UIImage(data: data!)
                let thumbnailSize = CGSizeMake(image!.size.width / 4, image!.size.height / 4)
                UIGraphicsBeginImageContext(thumbnailSize)
                image?.drawInRect(CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height))
                let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
                UIGraphicsEndImageContext()
                
                let thumbnailData = NSData(data: UIImagePNGRepresentation(thumbnailImage)!)
                let thumbnailPath = "chapter\(chapter)/thumbnail_\(fileName)".stringByPrependingDocumentPath()
                thumbnailData.writeToFile(thumbnailPath, atomically: true)
                
            }
            }.resume()
    }
    
    private func getFilenameFromImageUrl(imageUrl: String) -> String {
        let regex = try!(NSRegularExpression(pattern: "/compressed/.*.jpg", options: NSRegularExpressionOptions()))
        
        let match = regex.firstMatchInString(imageUrl, options: NSMatchingOptions(), range: NSMakeRange(0, imageUrl.characters.count))
        
        return NSString(string: imageUrl).substringWithRange(match!.range).stringByReplacingOccurrencesOfString("/compressed/", withString: "")
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
