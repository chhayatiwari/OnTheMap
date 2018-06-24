//
//  AppDelegate.swift
//  OntheMap
//
//  Created by Chhaya Tiwari on 4/30/18.
//  Copyright © 2018 ChhayaTiwari. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    var sharedSession = URLSession.shared
    
    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {
        // Override point for customization after application launch.
        return true
    }
}
// MARK: Create URL from Parameters

extension AppDelegate {
    
    func tmdbURLFromParameters(_ parameters: [String:AnyObject], withPathExtension: String? = nil) -> URL {
        
        var components = URLComponents()
        components.scheme = Student.Udacity.APIScheme//Constants.TMDB.ApiScheme
        components.host = Student.Udacity.APIHost
        components.path = Student.Udacity.APIPath + (withPathExtension ?? "")
        components.queryItems = [URLQueryItem]()
        
        for (key, value) in parameters {
            let queryItem = URLQueryItem(name: key, value: "\(value)")
            components.queryItems!.append(queryItem)
        }
        
        return components.url!
    }
}

