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
import Contacts

class ViewController: UIViewController, MKMapViewDelegate, MFMessageComposeViewControllerDelegate {
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    var musicEffect: AVAudioPlayer = AVAudioPlayer()
    
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
    @IBAction func swipeRightGesture(_ sender: UISwipeGestureRecognizer) {
        performSegue(withIdentifier: "swipeRightSegue", sender: sender)
    }
    
    @IBAction func unwindToVC(segue: UIStoryboardSegue){
        
    }
    
    
    
    
    let locationManager = CLLocationManager()
    
    var x: CLLocation? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        enableBasicLocationServices()

        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(addAnnotationOnLongPress(gesture:)))
        longPressGesture.minimumPressDuration = 0.1
        self.mapView.addGestureRecognizer(longPressGesture)
        
        let musicFile = Bundle.main.path(forResource:"JYogurt", ofType:".mp3")
        
        do{
            try musicEffect = AVAudioPlayer(contentsOf: URL(fileURLWithPath: musicFile!))
        }
        catch{
            print(error)
        }

    }
    
    
    @IBAction func invisbleButtonPressed(_ sender: UIButton) {
        print("musicButton Pressed")
        musicEffect.play()

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
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {(clPlacemarks, error) in
                if error != nil{
                    print(error?.localizedDescription)
                } else if let placemarks = clPlacemarks, placemarks.count > 0{
                    let placemark = placemarks[0]
                    annotation.subtitle = "\(placemark.postalAddress!.street), \(placemark.postalAddress!.city), \(placemark.postalAddress!.state),  \(placemark.postalAddress!.postalCode), \(placemark.postalAddress!.country)"
//                    "Latitude: \(coordinate.latitude) Longitude: \(coordinate.longitude)"
                }
            }
           
            
//            annotation.subtitle = "Latitude: \(coordinate.latitude) Longitude: \(coordinate.longitude)"
            
            
            self.mapView.addAnnotation(annotation)
        }
    }
//    func getPlacemarkFromLocation(location: CLLocation){
//        CLGeocoder().reverseGeocodeLocation(location, completionHandler:
//            {(placemarks, error) in
//                if error {println("reverse geodcode fail: \(error.localizedDescription)")}
//                let pm = placemarks as [CLPlacemark]
//                if pm.count > 0 { self.showAddPinViewController(placemarks[0] as CLPlacemark) }
//        })
//    }
    
    
    
    func startMonitoringLocation(){
        locationManager.desiredAccuracy = kCLLocationAccuracyBest
        locationManager.distanceFilter = 10.0  // In meters.
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
        UIView.animate(withDuration: 0.1) {
            let angle = newHeading.trueHeading // convert from degrees to radians
       //     print(angle)
        }
    }
}

extension Double {
    var toRadians: Double { return self * .pi / 180 }
    var toDegrees: Double { return self * 180 / .pi }
}


