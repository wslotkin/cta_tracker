//
//  ViewController.swift
//  cta_tracker
//
//  Created by Will Slotkin on 3/7/15.
//  Copyright (c) 2015 3005 Productions Studios. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    let locationManager = CLLocationManager()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    

        // Ask for Authorisation from the User.
        self.locationManager.requestAlwaysAuthorization()
        
        // For use in foreground
        self.locationManager.requestWhenInUseAuthorization()
        
        if CLLocationManager.locationServicesEnabled() {
            locationManager.delegate = self
            locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
            locationManager.startUpdatingLocation()
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var output: UITextView!

    @IBAction func go() {
        let currentLocation : CLLocationCoordinate2D = getCurrentLocation()
        
        let url : NSURL = NSURL(string: NSString(format: "http://" + Constants.SERVER + "/stops/%.6f/%.6f", currentLocation.latitude, currentLocation.longitude))!
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            self.setText(NSString(data: data, encoding: NSUTF8StringEncoding)!)
        }
        
        task.resume()
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D {
        var location : CLLocation? = locationManager.location
        if (location != nil) {
            return location!.coordinate
        } else {
           return CLLocationCoordinate2D(latitude: 41.9023999, longitude: -87.6310129)
        }
    }
    
    func setText(text : NSString) {
        dispatch_async(dispatch_get_main_queue(),{
            self.output.text = text
        })
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        var locValue:CLLocationCoordinate2D = manager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
    }
}

