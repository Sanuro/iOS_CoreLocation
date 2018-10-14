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
//import Alamofire

import StitchCore
import StitchRemoteMongoDBService





class ViewController: UIViewController, MKMapViewDelegate, MFMessageComposeViewControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    
    private lazy var stitchClient = Stitch.defaultAppClient!
    private var mongoClient: RemoteMongoClient?
    
    @IBOutlet weak var new_categoryView: UIView!
    @IBOutlet weak var category: UIPickerView!
    
    let category_option = ["Theft","Assault","Sexual Assault","Shooting", "Vandalism", "Alcohol", "Other"]
    var category_chosen = ""
    var coordinate_to_save: CLLocationCoordinate2D?
    var address_to_save: String?
    var annotation_to_save: MKPointAnnotation?
    
    
    
    
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
        coordinate_to_save = coordinate
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
//        let url: NSURL = URL(string: "TEL://119")! as NSURL
//        UIApplication.shared.open(url as URL, options: [:], completionHandler: nil)
        
        let coordinate = locationManager.location?.coordinate
        coordinate_to_save = coordinate
        let location = CLLocation(latitude: coordinate?.latitude ?? 0, longitude: coordinate?.longitude ?? 0)
        let geocoder = CLGeocoder()
        var whole_address = ""
        geocoder.reverseGeocodeLocation(location) {(clPlacemarks, error) in
            if error != nil{
                print(error?.localizedDescription)
            } else if let placemarks = clPlacemarks, placemarks.count > 0{
                let placemark = placemarks[0]
                whole_address = "\(placemark.postalAddress!.street), \(placemark.postalAddress!.city), \(placemark.postalAddress!.state),  \(placemark.postalAddress!.postalCode), \(placemark.postalAddress!.country)"
                var potential_message = "Hello. I am Katie. I am in danger at " + whole_address
                potential_message = potential_message.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) ?? ""
                
                var encoded_potential_msg_url = "https://danger-klee123.structure.sh/msg/" + potential_message
                
                let url = URL(string: encoded_potential_msg_url)
                // create a URLSession to handle the request tasks
                let session = URLSession.shared
                // create a "data task" to make the request and run completion handler
                let task = session.dataTask(with: url!, completionHandler: {
                    // see: Swift closure expression syntax
                    data, response, error in
                    // data -> JSON data, response -> headers and other meta-information, error-> if one occurred
                    // "do-try-catch" blocks execute a try statement and then use the catch statement for errors
                    do {
                        // try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
//                        if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
//                            print(jsonResult)
//                        }
                    } catch {
                        print(error)
                    }
                })
                // execute the task and then wait for the response
                // to run the completion handler. This is async!
                task.resume()
                

//                let url_call: NSURL = URL(string: encoded_potential_msg_url)! as NSURL
//                // create a URLSession to handle the request tasks
//                UIApplication.shared.open(url_call as URL, options: [:], completionHandler: nil)

//                client.callFunction(withName: "sendlocation", withArgs: [whole_address], withRequestTimeout: 5.0
//                ) { (result: StitchResult<String>) in
//                    switch result {
//                    case .success(let stringResult):
//                        print("String result: \(stringResult)")
//                    case .failure(let error):
//                        print("Error retrieving String: \(String(describing: error))")
//                    }
//                }
                //                    "Latitude: \(coordinate.latitude) Longitude: \(coordinate.longitude)"
            }
        }

        
        
        
        
        
//        let url_call: NSURL = URL(string: "https://dangerzone-klee123.structure.sh/msg/hello")! as NSURL
//        // create a URLSession to handle the request tasks
//        UIApplication.shared.open(url_call as URL, options: [:], completionHandler: nil)
        
//        let session = URLSession.shared
//        // create a "data task" to make the request and run completion handler
//        let task = session.dataTask(with: url_call!, completionHandler: {
//            // see: Swift closure expression syntax
//            data, response, error in
//            // data -> JSON data, response -> headers and other meta-information, error-> if one occurred
//            // "do-try-catch" blocks execute a try statement and then use the catch statement for errors
//            do {
//                // try converting the JSON object to "Foundation Types" (NSDictionary, NSArray, NSString, etc.)
//                if let jsonResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.mutableContainers) as? NSDictionary {
//                    print(jsonResult)
//                }
//            } catch {
//                print(error)
//            }
//        })
//        // execute the task and then wait for the response
//        // to run the completion handler. This is async!
//        task.resume()
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
        new_categoryView.isHidden = true
        category_chosen = "Theft"
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
//        pickerview is category
        category.dataSource = self
        category.delegate = self

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
            
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            let geocoder = CLGeocoder()
            geocoder.reverseGeocodeLocation(location) {(clPlacemarks, error) in
                if error != nil{
                    print(error?.localizedDescription)
                } else if let placemarks = clPlacemarks, placemarks.count > 0{
                    let placemark = placemarks[0]
                    annotation.subtitle = "\(placemark.postalAddress!.street), \(placemark.postalAddress!.city), \(placemark.postalAddress!.state),  \(placemark.postalAddress!.postalCode), \(placemark.postalAddress!.country)"
                    self.new_categoryView.isHidden = false
                    self.address_to_save = annotation.subtitle
                    self.annotation_to_save = annotation
                } 
            }
            
            
            
            
            
           
            
//            annotation.subtitle = "Latitude: \(coordinate.latitude) Longitude: \(coordinate.longitude)"
//            if (save_data) {
//                self.mapView.addAnnotation(annotation)
//            }
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
    
    @IBAction func cancelButtonPressed(_ sender: Any) {
        new_categoryView.isHidden = true
        
    }
    
    @IBAction func saveButtonPressed(_ sender: UIButton) {
        new_categoryView.isHidden = true
        annotation_to_save?.title = category_chosen
        self.mapView.addAnnotation(annotation_to_save!)
        
        
        
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
        
//      send text to others about update
        client.callFunction(withName: "notify_others", withArgs: [category_chosen, address_to_save ?? "UPDATE"], withRequestTimeout: 5.0) { (result: StitchResult<String>) in
            switch result {
            case .success(let stringResult):
                print("String result: \(stringResult)")
            case .failure(let error):
                print("Error retrieving String: \(String(describing: error))")
            }
        }
        
//        save to database
        client.callFunction(withName: "add_danger", withArgs: [category_chosen, coordinate_to_save?.latitude.description ?? "0", coordinate_to_save?.longitude.description ?? "0"], withRequestTimeout: 5.0
        ) { (result: StitchResult<String>) in
            switch result {
            case .success(let stringResult):
                print("String result: \(stringResult)")
            case .failure(let error):
                print("Error retrieving String: \(String(describing: error))")
            }
        }
        
        
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        category_chosen = category_option[row]
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
    
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return category_option.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return category_option[row]
    }
}

extension Double {
    var toRadians: Double { return self * .pi / 180 }
    var toDegrees: Double { return self * 180 / .pi }
}


