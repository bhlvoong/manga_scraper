//
//  MangaDownloader.swift
//  MangaScraper
//
//  Created by Brian Voong on 11/2/15.
//  Copyright © 2015 statsallday. All rights reserved.
//

import UIKit

class MangaDownloader: NSObject {

    func downloadChapter(chapter: Int, page: Int, completion: () ->(), progress: (pageNumber: Int) -> ()) {
        
        dispatch_async(dispatch_get_main_queue()) { () -> Void in
            progress(pageNumber: page)
        }
        
        print("Downloading page: \(page)")
        let chapterString = String(format: "%03d", chapter)
        let pageUrl = "http://www.mangahere.co/manga/boku_wa_mari_no_naka/c\(chapterString)/\(page).html"
        
        getImageUrlFromPageUrl(pageUrl, completion: { (imageUrl, error) -> () in
            
            if error != nil {
                print("Failed to get imageUrl from pageUrl \(pageUrl): \(error?.description)")
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion()
                })
            }
            
            if imageUrl != nil {
                if page == 0 {
                    self.createDirectoryForChapter(chapter)
                }
                
                self.saveImageForUrl(imageUrl!, chapter: chapter)
                
                self.downloadChapter(chapter, page: page + 1, completion: completion, progress: progress)
                
            } else {
                print("Could not find imageUrl for page: \(pageUrl)")
                //assume we are done
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    completion()
                })
            }
            
        })
    }
    
    private func createDirectoryForChapter(chapter: Int) {
        let fileManager = NSFileManager.defaultManager()
        let chapterString = String(format: "%03d", chapter)
        try!fileManager.createDirectoryAtPath(chapterString.stringByPrependingDocumentPath(), withIntermediateDirectories: true, attributes: nil)
    }
    
    private func saveImageForUrl(url: String, chapter: Int) {
        NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: url)!) { (data, response, error) -> Void in
            if error != nil {
                print("Failed fetching image \(url): \(error?.description)")
                return
            }
            
            if data != nil {
                let fileName = self.getFilenameFromImageUrl(url)
                let chapterString = String(format: "%03d", chapter)
                let path = "\(chapterString)/\(fileName)".stringByPrependingDocumentPath()
                data!.writeToFile(path, atomically: true)
                
                let image = UIImage(data: data!)
                let thumbnailImage = self.generateThumbnailForImage(image!)
                
                let thumbnailData = NSData(data: UIImagePNGRepresentation(thumbnailImage)!)
                let thumbnailPath = "\(chapterString)/thumbnail_\(fileName)".stringByPrependingDocumentPath()
                thumbnailData.writeToFile(thumbnailPath, atomically: true)
                
            }
            }.resume()
    }
    
    private func generateThumbnailForImage(image: UIImage) -> UIImage {
        let thumbnailSize = CGSizeMake(image.size.width / 3, image.size.height / 3)
        UIGraphicsBeginImageContext(thumbnailSize)
        image.drawInRect(CGRectMake(0, 0, thumbnailSize.width, thumbnailSize.height))
        let thumbnailImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return thumbnailImage
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
