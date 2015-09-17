//
//  ViewController.swift
//  FlikrSearch
//
//  Created by Laura Calinoiu on 15/09/15.
//  Copyright © 2015 3Smurfs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UXDelegate {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titleForSearch: UITextField!
    @IBOutlet weak var latitudeForSearch: UITextField!
    @IBOutlet weak var longitude: UITextField!
    @IBOutlet weak var imgeLabelFromFlikr: UILabel!
    
    var networkManagerInstance = NetworkManager.sharedInstance
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManagerInstance.uxDelegate = self
    }
    
    @IBAction func searchByImageTitleButtonTouchUpEvent(sender: UIButton) {
        networkManagerInstance.connectToAPIandGetDataWithCompletion()
    }
    
    @IBAction func searchByLatLongTitleButtonTouchUpEvent(sender: UIButton) {
        
    }
    
    func updateView(data: NSData, title: String) {
        self.imageview.image = UIImage(data: data)
        self.imgeLabelFromFlikr.text = title
    }
    
    func printErr(err: String) {
        self.imgeLabelFromFlikr.text = err
    }
}

