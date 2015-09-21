//
//  NetworkManager.swift
//  FlikrSearch
//
//  Created by Laura Calinoiu on 17/09/15.
//  Copyright © 2015 3Smurfs. All rights reserved.
//

import Foundation

protocol UXDelegate{
    func updateView(data: NSData, title: String)
    func printErr(err: String)
}


let URL = "https://api.flickr.com/services/rest/"
let DICTIONARYPARAMETER = ["method":"flickr.photos.search",
    "api_key":"ea3e25e77036b4f9fdca2dfd65a8b8fa",
    "text":"fdafda",
    "format":"json",
    "nojsoncallback":"1",
    "extras":"url_m"]

let PARSE_ERROR_MESSAGE = "Sorry, but there was an error getting data from API"
let NO_PHOTOS_MESSAGE = "Sorry, but there are no photos matching criteria"


struct ConnectionCooker{
    
    static func prepareConnection() -> (NSURLRequest, NSURLSession){
        let request = NSURLRequest(URL: getURLFormated())
        let urlSession = NSURLSession.sharedSession()
        
        return (request, urlSession)
    }
    
    static func getURLFormated() -> NSURL{
        let parameterString = encodeParameters(DICTIONARYPARAMETER)
        return  NSURL(string: "\(URL)?\(parameterString)")!
    }
    
    static func encodeParameters(param:[String: String]) -> String{
        let queryItems = param.map({NSURLQueryItem(name: $0, value: $1)})
        let components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
}

class NetworkManager{
    
    class var sharedInstance: NetworkManager{
        struct Singleton{
            static let instance = NetworkManager()
        }
        return Singleton.instance
    }
    
    var uxDelegate: UXDelegate!
    
    func connectToAPIandGetDataWithCompletion(){
        let (request, urlSession) = ConnectionCooker.prepareConnection()
        taskForRequest(urlSession, request: request)
    }
    
    func taskForRequest(session: NSURLSession, request: NSURLRequest){
        let task = session.dataTaskWithRequest(request) {data, request, error in
            if let data = data{
                do {
                    let JSON = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments) as? NSDictionary
                    self.parseJSON(JSON!)
                }
                catch let ex as NSError{
                    print(ex.description)
                }
            }
        }
        task.resume()
    }
    
    func parseJSON(dictionary: NSDictionary){
        
        guard let photosFromRequest = dictionary.objectForKey("photos") as? [String: AnyObject] else{
            dealWithMessagesToMainQueue(PARSE_ERROR_MESSAGE)
            print("Err with photos tag ")
            return
        }
        
        guard let howManyPhotos = Int(photosFromRequest["total"] as! String) else{
            dealWithMessagesToMainQueue(PARSE_ERROR_MESSAGE)
            print("Err with getting total tag")
            return
        }
        
        print("total photos \(howManyPhotos)")
        if howManyPhotos != 0{
            
            guard let photos = photosFromRequest["photo"] as? [[String:AnyObject]] else{
                dealWithMessagesToMainQueue(PARSE_ERROR_MESSAGE)
                print("Err with getting photo tag")
                return
            }
            let index = Int(arc4random_uniform(UInt32(photos.count)))
            let photoToBeShownWithAllData = photos[index]
        
            guard let photoToBeShownUrl = NSURL(string: photoToBeShownWithAllData["url_m"] as! String) else{
                dealWithMessagesToMainQueue(PARSE_ERROR_MESSAGE)
                print("Err with getting random photo url")
                return
            }
            
            guard let titleOfImage = photoToBeShownWithAllData["title"] as? String else{
                dealWithMessagesToMainQueue(PARSE_ERROR_MESSAGE)
                print("Err with getting title of random photo")
                return
            }
            
            if let imageData = NSData(contentsOfURL: photoToBeShownUrl){
                dispatch_async(dispatch_get_main_queue(), {
                    self.uxDelegate.updateView(imageData, title: titleOfImage)
                })
            } else {
                print("image does not exist at \(photoToBeShownUrl)")
                dealWithMessagesToMainQueue(PARSE_ERROR_MESSAGE)
            }
        }
        else{
            dealWithMessagesToMainQueue(NO_PHOTOS_MESSAGE)
        }
    }
    
    func dealWithMessagesToMainQueue(message: String){
        dispatch_async(dispatch_get_main_queue(), {
            self.uxDelegate.printErr(message)
        })
        
    }
}
