//
//  ViewController.swift
//  cta_tracker
//
//  Created by Will Slotkin on 3/7/15.
//  Copyright (c) 2015 3005 Productions Studios. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit

class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate {

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
        
        mapView.delegate = self
        let location = CLLocationCoordinate2D(latitude: 41.9023999, longitude: -87.6310129)
        let span = MKCoordinateSpanMake(0.05, 0.05)
        let region = MKCoordinateRegion(center: location, span: span)
        mapView.setRegion(region, animated: true)
        
        self.addUserLocationToMap(location)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBOutlet var mapView : MKMapView!

    @IBAction func go() {
        let currentLocation = getCurrentLocation()
        self.mapView.removeAnnotations(self.mapView.annotations)
        self.addUserLocationToMap(currentLocation)
        
        let url = NSURL(string: String(format: "http://" + Constants.SERVER + "/stops?lat=%.6f&lon=%.6f&stops=10", currentLocation.latitude, currentLocation.longitude))!
        
        
        let task = NSURLSession.sharedSession().dataTaskWithURL(url) {(data, response, error) in
            self.handleResult(data, handler: self.handle)
        }
        
        task.resume()
    }
    
    func addUserLocationToMap(location : CLLocationCoordinate2D) {
        let userLocation = MKUserLocation()
        userLocation.setCoordinate(location)
        mapView.addAnnotation(userLocation)
    }
    
    func getCurrentLocation() -> CLLocationCoordinate2D {
        let location = locationManager.location
        if (location != nil) {
            return location!.coordinate
        } else {
           return self.mapView.centerCoordinate
        }
    }
    
    func handle(jsonData : Array<Dictionary<String, AnyObject>>) {
        dispatch_async(dispatch_get_main_queue(),{
            for stop : Dictionary<String, AnyObject> in jsonData {
                var lat = stop["stop_lat"]! as Double
                var lon = stop["stop_lon"]! as Double
                let annotation = MKPointAnnotation()
                annotation.setCoordinate(CLLocationCoordinate2D(latitude: lat, longitude: lon))
                self.mapView.addAnnotation(annotation)
            }
        })
    }
    
    func handleResult(data : NSData, handler : Array<Dictionary<String, AnyObject>> -> Void) {
        var error : NSError?
        let rawJson: AnyObject? = NSJSONSerialization.JSONObjectWithData(data, options: nil, error: &error)
        let jsonDict = rawJson! as Array<Dictionary<String, AnyObject>>
        handler(jsonDict)
    }

    func locationManager(manager: CLLocationManager!, didUpdateLocations locations: [AnyObject]!) {
        let locValue = manager.location.coordinate
        println("locations = \(locValue.latitude) \(locValue.longitude)")
    }
    
    func view(mapView: MKMapView!, viewForAnnotation annotation: MKAnnotation!) -> MKAnnotationView! {
        var view : MKAnnotationView? = nil
        if !(annotation is MKUserLocation) {
            let defaultPin = "pinIdentifier"
            view = mapView.dequeueReusableAnnotationViewWithIdentifier(defaultPin) as? MKPinAnnotationView
            if(view == nil) {
                view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: defaultPin)
            }
            var pinView = view! as MKPinAnnotationView
            pinView.animatesDrop = true
        }
        return view
    }
}

