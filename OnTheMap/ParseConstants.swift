//
//  ParseConstants.swift
//  OnTheMap
//
//  Created by Michael Alexander on 6/10/17.
//  Copyright © 2017 Michael Alexander. All rights reserved.
//

extension ParseClient{

    struct Constants {

        static let parseApplicationId = "QrX47CA9cyuGewLdsL7o5Eb8iug6Em8ye0dnAbIr"
        static let parseRESTApiKey = "QuWThTdiRmTux3YaDseUSEpUKo7aBYM737yKd4gY"

        static let ApiScheme = "https"
        static let ApiHost = "parse.udacity.com"
        static let ApiPath = "/parse/classes/StudentLocation"
        
    }
    
    struct JSONKeys {
        
        static let objectID = "objectId"
        static let uniqueKey = "uniqueKey"
        static let firstName = "firstName"
        static let lastName = "lastName"
        static let mapString = "mapString"
        static let mediaURL = "mediaURL"
        static let latitude = "latitude"
        static let longitude = "longitude"
        static let createdAt = "createdAt"
        static let updatedAt = "updatedAt"
    
    }

}
