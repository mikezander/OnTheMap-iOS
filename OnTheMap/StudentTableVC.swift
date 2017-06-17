//
//  StudentTableVC.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/13/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import UIKit

class StudentTableVC: UITableViewController{

    @IBOutlet var studentTableView: UITableView!
    
    var studentURL: [String]?

    func getStudentList(){
        
        ParseClient.sharedInstance.getStudents { (result, error) in
            guard (result != nil || error == nil) else {
                print("Unable to get student list")
                return
            }
    
        ParseClient.sharedInstance.students = result!
            
            performUIUpdatesOnMain {
                self.studentTableView.reloadData()
            }
            
           
        }
    }
    
    @IBAction func refreshPressed(_ sender: Any) {
        getStudentList()
    }
    
    @IBAction func logoutPressed(_ sender: Any) {
        
        UdacityClient.sharedInstance().logOutSession(completionHandlerForLogout: {(success, error) in
            
            guard success && error == nil else{
                print("logout failed")
                return
            }
            performUIUpdatesOnMain {
                self.dismiss(animated: true, completion: nil)
            }
            
        })

    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return ParseClient.sharedInstance.students.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StudentCell", for: indexPath)
        let student = ParseClient.sharedInstance.students[indexPath.row]
        
        cell.imageView?.image = UIImage(named: "pin")
        cell.textLabel?.text = student.firstName + " " + student.lastName
        cell.detailTextLabel?.text = student.mediaURL
        cell.detailTextLabel?.textColor = UIColor.white
        

        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        guard let mediaURL = tableView.cellForRow(at: indexPath)?.detailTextLabel?.text else{
            performUIUpdatesOnMain {
                let alertController = UIAlertController(title: "Error", message: "Invalid Link", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
            return
        }
        
        if let refrenceURL = NSURL(string: mediaURL){
            if #available(iOS 10, *) {
                UIApplication.shared.open(refrenceURL as URL, options: [:],completionHandler:nil)
            } else {
                _ = UIApplication.shared.openURL(refrenceURL as URL)
            }
            
        }else{
            performUIUpdatesOnMain {
                let alert = UIAlertController(title: "Error", message: "Unable to open media url", preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default, handler: nil)
                alert.addAction(action)
                self.present(alert, animated: true, completion: nil)
            }
            
                
            }
    
    }

}
