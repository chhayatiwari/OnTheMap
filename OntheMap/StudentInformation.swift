//
//  StudentInformation.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 6/9/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import Foundation
struct StudentInformation {
    
    // MARK: Properties
    
    let lat:Double?
    let long:Double?
    let first:String
    let last:String
    let mediaURL:String?
    
    // MARK: Initializers
    
    init(dictionary: [String:AnyObject]) {
        lat = (dictionary[Student.StudentResponseKey.Latitude] as? Double)
        long = (dictionary[Student.StudentResponseKey.Longitude] as? Double)
        first = (dictionary[Student.StudentResponseKey.FirstName] as? String)!
        last = (dictionary[Student.StudentResponseKey.LastName] as? String)!
        mediaURL = (dictionary[Student.StudentResponseKey.MediaUrl] as? String)
    }
    
    static func dataFromResults(_ results: [[String:AnyObject]]) -> [StudentInformation] {
        
        var student = [StudentInformation]()
        
        // iterate through array of dictionaries, each Movie is a dictionary
        for result in results {
            student.append(StudentInformation(dictionary: result))
        }
        
        return student
    }
    
}
