//
//  UdacityClient.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/8/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//
import Foundation
import UIKit

class UdacityClient{
    
    // MARK: Properties
    
    // shared session
    var session = URLSession.shared
 
    
    func authenticateWithViewController(email: String, password: String, hostViewController: UIViewController, completionHandlerForAuth: @escaping (_ success: Bool, _ errorString: String?) -> Void){
        
        getCredentials(email: email, password: password) { (success, accountKey, sessionId, errorString) in
            
            if success {
                
                // successfully obtained accountKey and sessionId!
                User.sharedInstance.uniqueKey = accountKey
                User.sharedInstance.sessionID = sessionId
                
                completionHandlerForAuth(true, nil)
                
            } else {
                
                completionHandlerForAuth(false, errorString)
            }
        }
        
    } // end authenticateWithViewController
    
    private func getCredentials(email: String, password: String, completionHandlerForGetCredentials: @escaping (_ success: Bool, _ accountKey: String?, _ sessionId: String?, _ errorString: String?) -> Void) {
        
        //Build the URL, Configure the request
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Accept")
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = "{\"udacity\": {\"\(UdacityClient.JSONKeys.Email)\": \"\(email)\", \"\(UdacityClient.JSONKeys.Password)\": \"\(password)\"}}".data(using: String.Encoding.utf8)
        
        //Make the request
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            
            func sendError(_ error: String){
                print(error)
                completionHandlerForGetCredentials(false, nil, nil, error)
            }
            
            /* GUARD: Was there an error? */
            guard (error == nil) else {
                sendError("There was an error with your request: \(error!)")
                return
            }
            
            /* GUARD: Did we get a successful 2XX response? */
            guard let statusCode = (response as? HTTPURLResponse)?.statusCode, statusCode >= 200 && statusCode <= 299 else {
                sendError("Your request returned a status code other than 2xx!")
                return
            }
            
            /* GUARD: Was there any data returned? */
            guard let data = data else {
                sendError("No data was returned by the request!")
                return
            }
            
            let range = Range(5..<data.count) //deleted unwrap double check**
            let newData = data.subdata(in: range) /* subset response data! */
            print(NSString(data: newData, encoding: String.Encoding.utf8.rawValue)!)
            
            //Parse the data and use the data (happens in completion handler)
            var parsedResults: AnyObject! = nil
            
            do{
                parsedResults = try JSONSerialization.jsonObject(with: newData, options: .allowFragments) as AnyObject
                print(parsedResults)
            }catch{
                print("error parsing JSON \(LocalizedError.self)")
            }
            
            if let accountDicitionary = parsedResults["account"] as? [String:AnyObject],
                let sessionDictinary = parsedResults["session"] as? [String:AnyObject]{
                
                let key = accountDicitionary["key"] as! String?
                let id = sessionDictinary["id"] as! String?
                
                completionHandlerForGetCredentials(true, key, id, nil)
            }
        }
        
        //Start the request
        task.resume()
    }
    
    func logOutSession(completionHandlerForLogout:@escaping (_ success: Bool, _ error: Error?)-> Void){
        
        let request = NSMutableURLRequest(url: URL(string: "https://www.udacity.com/api/session")!)
        request.httpMethod = "DELETE"
        var xsrfCookie: HTTPCookie? = nil
        let sharedCookieStorage = HTTPCookieStorage.shared
        
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest) { data, response, error in
            if error != nil {
                completionHandlerForLogout(false,error)
                return
            }
            
            let range = Range(5..<data!.count)
            let newData = data?.subdata(in: range) /* subset response data! */
            print(NSString(data: newData!, encoding: String.Encoding.utf8.rawValue)!)
            
            completionHandlerForLogout(true,nil)
        }
        
        task.resume()
        
    }
    
    class func sharedInstance() -> UdacityClient {
        struct Singleton {
            static var sharedInstance = UdacityClient()
        }
        return Singleton.sharedInstance
    }
    
}
