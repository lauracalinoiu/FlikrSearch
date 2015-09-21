//
//  ConnectionCooker.swift
//  FlikrSearch
//
//  Created by Laura Calinoiu on 21/09/15.
//  Copyright © 2015 3Smurfs. All rights reserved.
//

import Foundation


protocol ConnectionProtocol{
    var textToSearch: String? { get }
    var latitudeToSearch: String? { get }
    var longitudeToSearch: String? { get }
}

class ConnectionCooker: ConnectionProtocol{
    
    let URL = "https://api.flickr.com/services/rest/"
    var DICTIONARYPARAMETER = ["method":"flickr.photos.search",
        "api_key":"ea3e25e77036b4f9fdca2dfd65a8b8fa",
        "format":"json",
        "nojsoncallback":"1",
        "extras":"url_m"]
    
    var textToSearch: String?
    var latitudeToSearch: String?
    var longitudeToSearch: String?
    
    typealias BuildConnectionClosure = (ConnectionCooker) -> Void
    
    init(build : BuildConnectionClosure){
        build(self)
    }
    
    func prepareConnection() -> (NSURLRequest, NSURLSession){
        let request = NSURLRequest(URL: getURLFormated())
        let urlSession = NSURLSession.sharedSession()
        
        return (request, urlSession)
    }
    
    func getURLFormated() -> NSURL{
        if let textToSearch = textToSearch{
            DICTIONARYPARAMETER["text"]  =  textToSearch
        }
        if let latitudeToSearch = latitudeToSearch, longitudeToSearch = longitudeToSearch{
            let bbox = BboxCalculator(latitude: latitudeToSearch, longitude: longitudeToSearch)
            DICTIONARYPARAMETER["bbox"] = bbox.computeCalculation()
        }
        
        let parameterString = encodeParameters(DICTIONARYPARAMETER)
        return  NSURL(string: "\(URL)?\(parameterString)")!
    }
    
    func encodeParameters(param:[String: String]) -> String{
        let queryItems = param.map({NSURLQueryItem(name: $0, value: $1)})
        let components = NSURLComponents()
        components.queryItems = queryItems
        return components.percentEncodedQuery ?? ""
    }
    
}