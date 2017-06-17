//
//  LogInVC.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/7/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit
import SystemConfiguration

class LogInVC: UIViewController, UITextFieldDelegate{

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
 
    var session: URLSession!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        emailTextField.delegate = self
        passwordTextField.delegate = self
  
        passwordTextField.isSecureTextEntry = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        emailTextField.text = ""
        passwordTextField.text = ""
        
        subscribeToKeyboardNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        unsubscribeToKeyboardNotifications()
    }

    @IBAction func loginPressed(_ sender: Any) {
 
        UdacityClient.sharedInstance().authenticateWithViewController(email: emailTextField.text!, password: passwordTextField.text!, hostViewController: self) {(success, error) in

            if self.isInternetAvailable(){
           
                self.performUIUpdatesOnMain {
                if success{
                    self.completeLogin()
                }else{
                    self.errorAlert(title: "Login Failed", message: "Invalid username/password"); return
                }
            }
           
            }else{
                self.errorAlert(title: "Login Failed", message: "No network connection"); return
            }
        }
    
    }
    
    private func completeLogin(){
        let vc = storyboard!.instantiateViewController(withIdentifier: "tabBarController") as! UITabBarController
        present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signUpPressed(_ sender: Any) {
        if let url = NSURL(string: UdacityClient.Constants.SignUp){
            if #available(iOS 10, *) {
                UIApplication.shared.open(url as URL, options: [:],completionHandler:nil)
            } else {
                _ = UIApplication.shared.openURL(url as URL)
            }

        }
    }
    
    func isInternetAvailable() -> Bool {
        
        var zeroAddress = sockaddr_in()
        zeroAddress.sin_len = UInt8(MemoryLayout<sockaddr_in>.size)
        zeroAddress.sin_family = sa_family_t(AF_INET)
        
        guard let defaultRouteReachability = withUnsafePointer(to: &zeroAddress, {
            $0.withMemoryRebound(to: sockaddr.self, capacity: 1) {
                SCNetworkReachabilityCreateWithAddress(nil, $0)
            }
        }) else {
            return false
        }
        
        var flags: SCNetworkReachabilityFlags = []
        if !SCNetworkReachabilityGetFlags(defaultRouteReachability, &flags) {
            return false
        }
        
        let isReachable = flags.contains(.reachable)
        let needsConnection = flags.contains(.connectionRequired)
        
        return (isReachable && !needsConnection)
    }
    
}

extension LogInVC{

    // dismisses the keyboard when users hits return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        
        return true
    }
    
    //shifts the view up from text field to be visible
    func keyboardWillShow(notification: NSNotification){
        if passwordTextField.isFirstResponder || emailTextField.isFirstResponder{
            view.frame.origin.y = (-getKeyboardHeight(notification: notification) / 2)
        }
    }
    
    //shifts view down once done editing text field
    func keyboardWillHide(notification: NSNotification){
        if passwordTextField.isFirstResponder || emailTextField.isFirstResponder{
            view.frame.origin.y = 0
        }
    }
    
    //helper function for keyboardWillShow
    func getKeyboardHeight(notification: NSNotification) -> CGFloat{
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
    
    
    func subscribeToKeyboardNotifications(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
    
    func unsubscribeToKeyboardNotifications(){
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillShow, object: nil)
        
        NotificationCenter.default.removeObserver(self, name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        
    }
  
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
        
    }
    
}

