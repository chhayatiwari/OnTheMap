//
//  Student.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 4/30/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import Foundation

struct Student {
    
    struct Udacity {
        static let APIScheme = "https"
        static let APIHost = "parse.udacity.com"
        static let APIPath = "/parse/classes/StudentLocation"
        static let uniqueKey = "98765"
    }
    
    
    struct StudentParameterKey {
        static let Account = "account"
        static let Id = "id"
        static let Session = "session"
        static let UniqueId = "key"
    }
    struct StudentLocationKey {
        static let User = "user"
        static let FirstName = "first_name"
        static let LastName = "last_name"
        static let UniqueId = "key"
    }
    struct StudentResponseKey {
        static let ObjectId = "objectId"
        static let UniqueKey = "uniqueKey"
        static let FirstName = "firstName"
        static let LastName = "lastName"
        static let MapString = "mapString"
        static let MediaUrl = "mediaURL"
        static let Latitude = "latitude"
        static let Longitude = "longitude"
        static let CreatedAt = "createdAt"
        static let UpdatedAt = "updatedAt"
        static let ACL = "ACL"
    }
    
    
}
