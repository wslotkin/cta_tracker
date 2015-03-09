//
//  HttpRequester.swift
//  cta_tracker
//
//  Created by Will Slotkin on 3/8/15.
//  Copyright (c) 2015 3005 Productions Studios. All rights reserved.
//

import Foundation

func getRequest(path: String, parameters: Dictionary<String, String>, resultHandler: Array<Dictionary<String, AnyObject>> -> Void) {
    var urlPath = Constants.URL.URL_PREFIX + Constants.URL.SERVER + path
    
    if (parameters.count > 0) {
        urlPath += "?"
    }
    
    for (key, value) in parameters {
        urlPath += key + "=" + value + "&"
    }
    
    let task = NSURLSession.sharedSession().dataTaskWithURL(NSURL(string: urlPath)!) {(data, response, error) in
        handleResult(data, resultHandler)
    }
    
    task.resume()
}

func handleResult(data : NSData, handler : Array<Dictionary<String, AnyObject>> -> Void) {
    var error : NSError?
    let rawJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
    let jsonDict = rawJson! as Array<Dictionary<String, AnyObject>>
    handler(jsonDict)
}