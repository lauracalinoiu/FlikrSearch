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

class NetworkManager{
    
    class var sharedInstance: NetworkManager{
        struct Singleton{
            static let instance = NetworkManager()
        }
        return Singleton.instance
    }
    
    
    let url = "https://api.flickr.com/services/rest/"
    let dictionaryParameterString = ["method":"flickr.photos.search", "api_key":"ea3e25e77036b4f9fdca2dfd65a8b8fa", "text":"baby asian elephant", "format":"json", "nojsoncallback":"1", "extras":"url_m"]
    
    var request: NSURLRequest!
    var urlSession: NSURLSession!
    var uxDelegate: UXDelegate!
    
    func connectToAPIandGetDataWithCompletion(){
        prepareConnection()
        taskForRequest(urlSession, request: request)
    }
    
    func prepareConnection(){
        request = NSURLRequest(URL: getURLFormated())
        urlSession = NSURLSession.sharedSession()
    }
    
    func getURLFormated() -> NSURL{
        let parameterString = encodeParameters(dictionaryParameterString)
        return  NSURL(string: "\(url)?\(parameterString)")!
    }
    
    func encodeParameters(param:[String: String]) -> String{
        let queryItems = param.map({NSURLQueryItem(name: $0, value: $1)})
        let components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
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
        
        let photosFromRequest = dictionary.objectForKey("photos") as! [String: AnyObject]
        let howManyPhotos = photosFromRequest["total"] as? String
        
        if let _ = Int(howManyPhotos!){
            let photos = photosFromRequest["photo"] as! [[String:AnyObject]]
            let index = chooseOneRandomIndexWithMaximum(photos.count)
            
            let photoToBeShownWithAllData = photos[index] as [String:AnyObject]
            let photoToBeShownUrl = NSURL(string: photoToBeShownWithAllData["url_m"] as! String)
            
            let titleOfImage = photoToBeShownWithAllData["title"] as? String
            
            getDataFromURL(photoToBeShownUrl!){ data in
                dispatch_async(dispatch_get_main_queue(), { () -> Void in
                    self.uxDelegate.updateView(data!, title: titleOfImage!)
                })
            }
        }else {
            self.uxDelegate.printErr("Sorry, no photos! ")
        }
    }
    
    func chooseOneRandomIndexWithMaximum(max: Int) -> Int{
        return Int(arc4random_uniform(UInt32(max)))
    }
    
    func getDataFromURL(url: NSURL, completion: ((data: NSData?) -> Void)){
        NSURLSession.sharedSession().dataTaskWithURL(url){ (data, response, error) in
            completion(data: data)
            }.resume()
    }
    
}
