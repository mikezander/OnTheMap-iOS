//
//  LogInVC.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/7/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation
import UIKit

class LogInVC: UIViewController{

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
    }

    @IBAction func loginPressed(_ sender: Any) {
 
        UdacityClient.sharedInstance().authenticateWithViewController(email: emailTextField.text!, password: passwordTextField.text!, hostViewController: self) {(success, error) in
            performUIUpdatesOnMain {
                if success{
                    self.completeLogin()
                }else{
                    let alert = UIAlertController(title: "Login Failed", message: "Invalid username/password", preferredStyle: .alert)
                    let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                    
                    alert.addAction(action)
                    self.present(alert, animated: true, completion: nil)
                }
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
    
}

extension LogInVC: UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        self.view.endEditing(true)
        
    }
    
}

