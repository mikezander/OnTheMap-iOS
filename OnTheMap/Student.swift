//
//  Student.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/11/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

import Foundation

struct Student{
    
    var firstName: String
    var lastName: String
    var latitude: Float
    var longitude: Float
    var mapString: String
    var mediaURL: String
    var objectId: String
    var uniqueKey: String
    var createdAt: NSString
    var updatedAt: NSString
    

    init(dictionary: [String:AnyObject]){

        firstName = dictionary["firstName"] as? String ?? ""
        lastName = dictionary["lastName"] as? String ?? ""
        latitude = dictionary["latitude"] as? Float ?? 0.0
        longitude = dictionary["longitude"] as? Float ?? 0.0
        mapString = dictionary["mapString"] as? String ?? ""
        mediaURL = dictionary["mediaURL"] as? String ?? ""
        objectId = dictionary["objectId"] as? String ?? ""
        uniqueKey = dictionary["uniqueKey"] as? String ?? ""
        createdAt = dictionary["createdAt"] as? NSString ?? ""
        updatedAt = dictionary["updatedAt"] as? NSString ?? ""
        
    }
    
    static func studentFromResult(results: [[String: AnyObject]]) -> [Student]{
        var students = [Student]()
        
        for result in results {
            students.append(Student(dictionary: result))
        }
        
        return students
}

}
    
