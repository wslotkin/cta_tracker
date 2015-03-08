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
        var currentLocation : CLLocation? = locationManager.location
        
        let url : NSURL = self.getStopsUrl(currentLocation)
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            self.setText(NSString(data: data, encoding: NSUTF8StringEncoding)!)
        }
        
        task.resume()

    }
    
    func getStopsUrl(location : CLLocation?) -> NSURL {
        if (location != nil) {
            var actualLocation : CLLocationCoordinate2D = location!.coordinate
            return NSURL(string: NSString(format: "http://localhost:8888/stops/%.6f/%.6f", actualLocation.latitude, actualLocation.longitude))!
        } else {
            return NSURL(string: "http://localhost:8888/stops/41.9023999/-87.6310129")!
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

