//
//  ViewController.swift
//  FlikrSearch
//
//  Created by Laura Calinoiu on 15/09/15.
//  Copyright © 2015 3Smurfs. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titleForSearch: UITextField!
    @IBOutlet weak var latitudeForSearch: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var imgeLabelFromFlikr: UILabel!
    
  
    let url = "https://api.flickr.com/services/rest/"
    var dictionaryParameterString = ["method":"flickr.photos.search", "api_key":"ea3e25e77036b4f9fdca2dfd65a8b8fa", "text":"baby asian elephant", "format":"json", "nojsoncallback":"1", "extras":"url_m"]
    
    @IBAction func searchByImageTitleButtonTouchUpEvent(sender: UIButton) {
        let request = NSURLRequest(URL: getURLFormated())
        let urlSession: NSURLSession  = NSURLSession.sharedSession()
        
        taskForRequest(urlSession, request: request)
    }
    
    func taskForRequest(session: NSURLSession, request: NSURLRequest){
        let task = session.dataTaskWithRequest(request) {data, request, error in
            if let data = data{
                do{
                    let dictionaryFromRequest = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
                    print(dictionaryFromRequest)
                }catch let error as NSError{
                    print(error.description)
                }
            }else if let error = error{
                print(error.description)
            }
        }
        task.resume()
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
    
    @IBAction func searchByLatLongTitleButtonTouchUpEvent(sender: UIButton) {
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

