//
//  ViewController.swift
//  FlikrSearch
//
//  Created by Laura Calinoiu on 15/09/15.
//  Copyright © 2015 3Smurfs. All rights reserved.
//

import UIKit

class ViewController: UIViewController, UXDelegate, UITextFieldDelegate {
    
    @IBOutlet weak var imageview: UIImageView!
    @IBOutlet weak var titleTextField: UITextField!
    @IBOutlet weak var latitudeTextField: UITextField!
    @IBOutlet weak var longitudeTextField: UITextField!
    @IBOutlet weak var imgeLabelFromFlikr: UILabel!
    
    var networkManagerInstance = NetworkManager.sharedInstance
    var tapGesture: UITapGestureRecognizer!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        networkManagerInstance.uxDelegate = self
        titleTextField.delegate = self
        latitudeTextField.delegate = self
        longitudeTextField.delegate = self
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        registerToKeyboardNotificationCenter()
    }
    
    override func viewWillDisappear(animated: Bool) {
        unregisterFromKeyboardNotificationCenter()
    }
    
    func registerToKeyboardNotificationCenter(){
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillShow:"), name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: Selector("keyboardWillHide:"), name: UIKeyboardWillHideNotification, object: nil)
    }
    func unregisterFromKeyboardNotificationCenter(){
        NSNotificationCenter.defaultCenter().removeObserver (self, name: UIKeyboardWillShowNotification, object: nil)
        NSNotificationCenter.defaultCenter().removeObserver(self, name: UIKeyboardWillHideNotification, object: nil)
    }
    
    func addTapGesture(){
        if tapGesture == nil{
            tapGesture = UITapGestureRecognizer(target: self, action: "handleTap:")
        }
        self.view.addGestureRecognizer(tapGesture)
    }
    
    func removeTapGesture(){
        if tapGesture != nil{
            self.view.removeGestureRecognizer(tapGesture)
            tapGesture = nil
        }
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.state == .Ended {
            self.view.endEditing(true)
        }
    }
    
    func keyboardWillShow(keyboardNotification: NSNotification){
        addTapGesture()
        self.view.frame.origin.y -= getKeyboardHeight(keyboardNotification)
    }
    
    func getKeyboardHeight(keyboardNotification: NSNotification) -> CGFloat{
        return ((keyboardNotification.userInfo![UIKeyboardFrameBeginUserInfoKey] as? NSValue)?.CGRectValue().height)!
    }
    
    func keyboardWillHide(keyboardNotification: NSNotification){
        removeTapGesture()
        self.view.frame.origin.y += getKeyboardHeight(keyboardNotification)
    }
    
    func textFieldShouldReturn(textField: UITextField) -> Bool {
        titleTextField.resignFirstResponder()
        latitudeTextField.resignFirstResponder()
        longitudeTextField.resignFirstResponder()
        return true
    }
    
    @IBAction func searchByImageTitleButtonTouchUpEvent(sender: UIButton) {
        titleTextField.resignFirstResponder()
        networkManagerInstance.connectToAPIandGetDataWithCompletion({
            $0.textToSearch = self.titleTextField.text
        })
    }
    
    @IBAction func searchByLatLongTitleButtonTouchUpEvent(sender: UIButton) {
        latitudeTextField.resignFirstResponder()
        longitudeTextField.resignFirstResponder()
        networkManagerInstance.connectToAPIandGetDataWithCompletion({
            $0.latitudeToSearch = self.latitudeTextField.text
            $0.longitudeToSearch = self.longitudeTextField.text
        })
    }
    
    
    func updateView(data: NSData, title: String) {
        self.imageview.image = UIImage(data: data)
        self.imgeLabelFromFlikr.text = title
    }
    
    func printErr(err: String) {
        self.imgeLabelFromFlikr.text = err
        self.imageview.image = nil
    }
}

