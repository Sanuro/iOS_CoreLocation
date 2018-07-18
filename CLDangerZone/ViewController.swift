//
//  ViewController.swift
//  CLDangerZone
//
//  Created by Jennifer Ho on 7/17/18.
//  Copyright © 2018 Rodrigo Baluyot ii. All rights reserved.
//

import UIKit
import CoreLocation
import MapKit
import AVFoundation
import CallKit
import MessageUI

class ViewController: UIViewController,MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        if MFMessageComposeViewController.canSendText(){
            let controller = MFMessageComposeViewController()
            controller.body = "HELP! I'm currently in a DangerZone!"
            controller.recipients = ["2488609463"]
            controller.messageComposeDelegate = self
            self.present(controller, animated: true, completion: nil)
        }else{
            print("Cannot send text")
        }
    }
    @IBAction func callButtonPressed(_ sender: UIButton) {
        let url: NSURL = URL(string: "TEL://119")! as NSURL
        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
    }
    
    let locationManager = CLLocationManager()
    
    var x: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        enableBasicLocationServices()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.5
        self.mapView.addGestureRecognizer(longPressGesture)

    }
    
    
    @IBOutlet weak var mapView: MKMapView!
    
    
    
    func enableBasicLocationServices() {
        locationManager.delegate = self
        
        switch CLLocationManager.authorizationStatus() {
        case .notDetermined:
            // Request when-in-use authorization initially
            locationManager.requestWhenInUseAuthorization()
            break
            
        case .restricted, .denied:
            // Disable location features
            print("Disable Location Based Features")
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            print("Enable When In Use Features")
            startMonitoringLocation()
            break
        }
    }
    
    @objc func addAnnotationOnLongPress(gesture: UILongPressGestureRecognizer) {
        
        if gesture.state == .ended {
            let point = gesture.location(in: self.mapView)
            let coordinate = self.mapView.convert(point, toCoordinateFrom: self.mapView)
            print(coordinate)
            //Now use this coordinate to add annotation on map.
            var annotation = MKPointAnnotation()
            annotation.coordinate = coordinate
            //Set title and subtitle if you want
            annotation.title = "DANGER ZONE"
            annotation.subtitle = "details"
            self.mapView.addAnnotation(annotation)
        }
    }
    
    
    
    
    func startMonitoringLocation(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 1.0  // In meters.
        locationManager.startUpdatingLocation()
        locationManager.startUpdatingHeading()
    }
    
    @IBAction func longTouchPressed(_ sender: UILongPressGestureRecognizer) {
        
//        let pinLocation = sender.location(in: self.mapView)
//        let pinCoordinate = self.mapView.convert(pinLocation as! CLLocationCoordinate2D, toPointTo: self.mapView)
//
//        let annotation = MKPointAnnotation()
//
//        annotation.coordinate = pinCoordinate as! CLLocationCoordinate2D
//        annotation.title = "TITLE PLACEHOLDER"
//        annotation.subtitle = "description"
//
//        self.mapView.addAnnotation(annotation)
//
        
        
        
    }
    
    
}

extension ViewController: CLLocationManagerDelegate {
    
    func locationManager(_ manager: CLLocationManager,
                         didChangeAuthorization status: CLAuthorizationStatus) {
        switch status {
        case .restricted, .denied:
            // Disable location features
            print("Disable Location Based Features")
            break
            
        case .authorizedWhenInUse, .authorizedAlways:
            // Enable location features
            print("Enable When In Use Features")
            startMonitoringLocation()
            break
            
        case .notDetermined:
            print("Location Based Features notDetermined")
            break
        }
    }
    
    func locationManager(_ manager: CLLocationManager,  didUpdateLocations locations: [CLLocation]) {
        let lastLocation = locations.last!
        x = lastLocation
        
        print(lastLocation.coordinate.latitude)
        print(lastLocation.coordinate.longitude)
        // Do something with the location.
        
        
        
    mapView.setRegion(MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(lastLocation.coordinate.latitude, lastLocation.coordinate.longitude), 150, 150), animated: true)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        UIView.animate(withDuration: 0.5) {
            let angle = newHeading.trueHeading // convert from degrees to radians
       //     print(angle)
        }
    }
}

extension Double {
    var toRadians: Double { return self * .pi / 180 }
    var toDegrees: Double { return self * 180 / .pi }
}

