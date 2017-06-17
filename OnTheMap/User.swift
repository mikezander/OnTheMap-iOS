//
//  User.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/11/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

class User {
    
    var sessionID: String? = nil
    var uniqueKey: String? = nil
    var firstName: String? = nil
    var lastName: String? = nil
    
    static let sharedInstance = User()
    
}

