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

import Foundation
import Alamofire

import StitchCore
import StitchRemoteMongoDBService





class ViewController: UIViewController, MKMapViewDelegate, MFMessageComposeViewControllerDelegate {
    
    private lazy var stitchClient = Stitch.defaultAppClient!
    private var mongoClient: RemoteMongoClient?
    
    
    func messageComposeViewController(_ controller: MFMessageComposeViewController, didFinishWith result: MessageComposeResult) {
        self.dismiss(animated: true, completion: nil)
    }
    var musicEffect: AVAudioPlayer = AVAudioPlayer()
    
//if let accountSID = ProcessInfo.processInfo.environment["ACb6c0bd9c0d0c11b1a3fdeb58155e9c26"],
//let authToken = ProcessInfo.processInfo.environment["cb0a0209127d60edc8deb39f696242e4"] {
    
    
//    let url = "https://api.twilio.com/2010-04-01/Accounts/\(ACb6c0bd9c0d0c11b1a3fdeb58155e9c26)/Messages"
//    let parameters = ["From": "4155490878", "To": "2488607630", "Body": "Hello from Swift!"]
    
//    Alamofire.request(url, method: .post, parameters: parameters)
//        .authenticate(user: ACb6c0bd9c0d0c11b1a3fdeb58155e9c26, password: cb0a0209127d60edc8deb39f696242e4)
//        .responseJSON { response in
//            debugPrint(response)
//    }
//
//    RunLoop.main.run()
//}
    
    
    @IBAction func messageButtonPressed(_ sender: UIButton) {
        let client = Stitch.defaultAppClient!
        
        client.auth.login(withCredential: AnonymousCredential()) { result in
            switch result {
            case .success(let user):
                print("logged in anonymous as user \(user.id)")
                DispatchQueue.main.async {
                    // update UI accordingly
                }
            case .failure(let error):
                print("Failed to log in: \(error)")
            }
        }

        
        
        
        
        
        let coordinate = locationManager.location?.coordinate
        
        let location = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
        let geocoder = CLGeocoder()
        var whole_address = ""
        geocoder.reverseGeocodeLocation(location) {(clPlacemarks, error) in
            if error != nil{
                print(error?.localizedDescription)
            } else if let placemarks = clPlacemarks, placemarks.count > 0{
                let placemark = placemarks[0]
                whole_address = "\(placemark.postalAddress!.street), \(placemark.postalAddress!.city), \(placemark.postalAddress!.state),  \(placemark.postalAddress!.postalCode), \(placemark.postalAddress!.country)"
                client.callFunction(withName: "sendlocation", withArgs: [whole_address], withRequestTimeout: 5.0
                ) { (result: StitchResult<String>) in
                    switch result {
                    case .success(let stringResult):
                        print("String result: \(stringResult)")
                    case .failure(let error):
                        print("Error retrieving String: \(String(describing: error))")
                    }
                }
                //                    "Latitude: \(coordinate.latitude) Longitude: \(coordinate.longitude)"
            }
        }

        
        
        
        print("logging in anonymously")
        

        
//
        
//        if MFMessageComposeViewController.canSendText(){
//            let controller = MFMessageComposeViewController()
//            controller.body = "HELP! I'm currently in a DangerZone!"
//            controller.recipients = ["2488609463"]
//            controller.messageComposeDelegate = self
//            self.present(controller, animated: true, completion: nil)
//        }else{
//            print("Cannot send text")
//        }
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
    
    func captureScreenshot(){
        let layer = UIApplication.shared.keyWindow!.layer
        let scale = UIScreen.main.scale
        // Creates UIImage of same size as view
        UIGraphicsBeginImageContextWithOptions(layer.frame.size, false, scale);
        layer.render(in: UIGraphicsGetCurrentContext()!)
        let screenshot = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        // THIS IS TO SAVE SCREENSHOT TO PHOTOS
        UIImageWriteToSavedPhotosAlbum(screenshot!, nil, nil, nil)
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
            let client = Stitch.defaultAppClient!
            
            client.auth.login(withCredential: AnonymousCredential()) { result in
                switch result {
                case .success(let user):
                    print("logged in anonymous as user \(user.id)")
                    DispatchQueue.main.async {
                        // update UI accordingly
                    }
                case .failure(let error):
                    print("Failed to log in: \(error)")
                }
            }
            
            
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
                    client.callFunction(withName: "update_pin", withArgs: [annotation.subtitle ?? "UPDATE"], withRequestTimeout: 5.0
                    ) { (result: StitchResult<String>) in
                        switch result {
                        case .success(let stringResult):
                            print("Safely sent new danger zone")
                        case .failure(let error):
                            print("Error retrieving String: \(String(describing: error))")
                        }
                    }
                
                }
            }
        
            let title = "Zone"
            
            
            client.callFunction(withName: "add_danger", withArgs: [title, coordinate.latitude.description, coordinate.longitude.description], withRequestTimeout: 5.0
            ) { (result: StitchResult<String>) in
                switch result {
                case .success(let stringResult):
                    print("String result: \(stringResult)")
                case .failure(let error):
                    print("Error retrieving String: \(String(describing: error))")
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


extension UIViewController {
    
    func hideKeyboardWhenTappedAround() {
        let tap: UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(UIViewController.dismissKeyboard))
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
}
