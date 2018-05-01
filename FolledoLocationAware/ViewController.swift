//
//  ViewController.swift
//  FolledoLocationAware
//
//  Created by Samuel Folledo on 4/30/18.
//  Copyright © 2018 Samuel Folledo. All rights reserved.
//

/*
 TO GRAB USER'S LOCATION
 1) project -> Build Phase -> Link Binary with Libraries. Then add CoreLocation.framework
 2) Info.plist add 2 rows
 1. NSLocationWhenInUseUsageDescription = popup that will open if you ask to access the user's location while theyve got the app open
 - with a description of why you want to use the user's location
 2. NSLocationAlwaysUsageDescription = popup if you want to know the location all the time
 - with a description of why you always want to use the user's location
 */

import UIKit
import MapKit
import CoreLocation

class ViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate { //CLLocationManagerDelegate is added for user location
    @IBOutlet var mapView: MKMapView!
    
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var courseLabel: UILabel!
    @IBOutlet var speedLabel: UILabel!
    @IBOutlet var altitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    var locationManager = CLLocationManager()
    
    var myLatitude = CLLocationDegrees()
    var myLongitude = CLLocationDegrees()
    let mySpan = MKCoordinateSpan(latitudeDelta: CLLocationDegrees(0.03), longitudeDelta: CLLocationDegrees(0.03))
    
    var myCoordinates = CLLocationCoordinate2D()
    var myRegion = MKCoordinateRegion()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        myCoordinates = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        myRegion = MKCoordinateRegion(center: myCoordinates, span: mySpan)
        //mapView.setRegion(myRegion, animated: true)
        
//        let annotation = MKPointAnnotation()
//        annotation.title = "Kobe's House"
//        annotation.subtitle = "I eat, sleep, and code most of the time here"
//        annotation.coordinate = myCoordinates
//        mapView.addAnnotation(annotation)
        
        let uilpgr = UILongPressGestureRecognizer(target: self, action: #selector(ViewController.longPress(gestureRecognizer:))) //long press gesture
        uilpgr.minimumPressDuration = 2 //press it for 2 seconds
        mapView.addGestureRecognizer(uilpgr) //add that to the map
        
        //---------------These are for UserLocation------------------
        locationManager.delegate = self //it allows the ViewController to control the location manager
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
        
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    @objc func longPress(gestureRecognizer: UIGestureRecognizer) { //this is where our uilpgr's colon is important. It will still run our long press method when it recognizes a long press but it wont send any information along with it, and we need to know where the long press is so we can add the annotation in the right place on the map. So adding the code on there makes sure that the informaton gets sent and we can receive it in gestureRecognizer variable
        let touchPoint = gestureRecognizer.location(in: self.mapView)
        let coordinate = mapView.convert(touchPoint, toCoordinateFrom: self.mapView) //use the map to convert the touch point which shows us the location on the screen to coordinate and it's the map that does the converting for us because the map knows both where the gesture was and where the long press happened and where that is in terms of the coordinates space
        let annotation = MKPointAnnotation()
        annotation.coordinate = coordinate
        annotation.title = "New place"
        annotation.subtitle = "Maybe I'll go here..."
        mapView.addAnnotation(annotation)
    }
    
//---------------These are for UserLocation------------------
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) { //once locationManager is setup, request and updating location is approved, then every time the user's location updates as long as your app is running, the didUpdateLocation method will be called and youll be able to do something with those locations
        //        print(locations)
        let userLocation: CLLocation = locations[0] //most current location
        self.myLatitude = userLocation.coordinate.latitude
        self.myLongitude = userLocation.coordinate.longitude
        
        self.latitudeLabel.text = String(myLatitude)
        self.longitudeLabel.text = String(myLongitude)
        self.courseLabel.text = String(userLocation.course)
        self.speedLabel.text = String(userLocation.speed)
        self.altitudeLabel.text = String(userLocation.altitude)
        
        myCoordinates = CLLocationCoordinate2D(latitude: myLatitude, longitude: myLongitude)
        myRegion = MKCoordinateRegion(center: myCoordinates, span: mySpan)
        
        self.mapView.setRegion(myRegion, animated: true)
        
//---------------These are from User Location Aware------------------
        CLGeocoder().reverseGeocodeLocation(userLocation) { //CLGeocoder is the process of going from an address to a location so our lat ang long. We want to go to the other way around from a lat/long to an address //An interface for converting between geographic coordinates and place names. The CLGeocoder class provides services for converting between a coordinate (specified as a latitude and longitude) and the user-friendly representation of that coordinate. A user-friendly representation of the coordinate typically consists of the street, city, state, and country information corresponding to the given location, but it may also contain a relevant point of interest, landmarks, or other identifying information. A geocoder object is a single-shot object that works with a network-based service to look up placemark information for its specified coordinate value.
            (placemarks, error) in //in short it turns lat & long to an address and puts it into an array of placemarks
            
            if error != nil {
                print(error!)
            } else { //if no error, take the first placemark
                if let placemark = placemarks?[0] {
                    //print(placemark) //prints an address
                    
                    var subThoroughfare = "" //street number //Subthroughfares provide information such as the street number for the location. For example, if the placemark location is Apple’s headquarters (1 Infinite Loop), the value for this property would be the string “1”.
                    if placemark.subThoroughfare != nil {
                        subThoroughfare = placemark.subThoroughfare!
                    }
                    
                    var thoroughfare = "" //street name
                    if placemark.thoroughfare != nil {
                        thoroughfare = placemark.thoroughfare!
                    }
                    
                    var subLocality = "" //Additional city-level information for the placemark. This property contains additional information, such as the name of the neighborhood or landmark associated with the placemark. It might also refer to a common name that
                    if placemark.subLocality != nil {
                        subLocality = placemark.subLocality!
                    }
                    
                    var subAdministrativeArea = "" //Subadministrative areas typically correspond to counties or other regions that are then organized into a larger administrative area or state.
                    if placemark.subAdministrativeArea != nil {
                        subAdministrativeArea = placemark.subAdministrativeArea!
                    }
                    
                    var postalCode = "" //The postal code associated with the placemark.
                    if placemark.postalCode != nil {
                        postalCode = placemark.postalCode!
                    }
                    
                    var country = "" //The name of the country associated with the placemark
                    if placemark.country != nil {
                        country = placemark.country!
                    }
                    
                    self.addressLabel.text = String(subThoroughfare + " " + thoroughfare + "\n" + subLocality + "\n" + subAdministrativeArea + "\n" + postalCode + "\n" + country) //out puts 864Pavonia Ave \n Marion \n Hudson \n 07306 \n United States
                    
                }
            }
            
        }
    }
    
}

