//
//  ViewController.swift
//  Location
//
//  Created by Julian Haldimann on 20.10.20.
//  Copyright © 2020 Julian Haldimann. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate, UITextFieldDelegate {

    @IBOutlet var labelCoordinates: UILabel!
    @IBOutlet var outputlong: UITextField!
    @IBOutlet var outputlat: UITextField!
    @IBOutlet var outputDistance: UITextField!
    @IBOutlet var outputAngle: UITextField!
    @IBOutlet var inputLat: UITextField!
    @IBOutlet var inputLong: UITextField!
    @IBOutlet var outputCompass: UITextField!
    
    var manager: CLLocationManager?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Make a small delay at start
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {}
    }
    
    @IBAction func didTabButton() {
        guard let vc = storyboard?.instantiateViewController(identifier: "mapVC") as? MapViewController else {
            return
        }
        
        vc.inputLat = inputLat.text ?? "0.0"
        vc.inputLong = inputLong.text ?? "0.0"
        present(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Default values
        inputLat.text = "0.0"
        inputLong.text = "0.0"
        manager = CLLocationManager()
        outputlat.delegate = self
        outputlong.delegate = self
        inputLong.delegate = self
        inputLat.delegate = self
        manager?.delegate = self
        manager?.desiredAccuracy = kCLLocationAccuracyBest
        manager?.requestWhenInUseAuthorization()
        manager?.startUpdatingLocation()
        manager?.startUpdatingHeading()
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {

        guard let first = locations.first else {
            return
        }
        
        // Print the actual position into the textfields
        outputlat.text = "\(first.coordinate.latitude)"
        outputlong.text = "\(first.coordinate.longitude)"
        
        let val1 = Double(inputLat.text!) ?? 0.0
        let val2 = Double(inputLong.text!) ?? 0.0
        
        // Calculate the distance and angle everytime the coordinates change
        calcDistance(lat1: first.coordinate.latitude, long1: first.coordinate.longitude, lat2: val1, long2: val2)
        calcAngle(lat1: first.coordinate.latitude, long1: first.coordinate.longitude, lat2: val1, long2: val2)
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        // Print out the actual direction of the device
        outputCompass.text = "\(newHeading.magneticHeading.rounded())"
    }
    
    /**
     This function can be used to calculate the distance between two decimal coordinates

     - parameter lat1: Latitude of the first coordinate.
     - parameter long1: Longitude of the first  coordinate.
     - parameter lat2: Latitude of the second coordinate.
     - parameter long2: Longitude of the second coordinate.
     */
    func calcDistance(lat1: Double, long1: Double, lat2: Double, long2: Double) {
        let radius = 6371.0
        
        // Convert all radians to degrees
        let dLat = degreesToRadians(lat1 - lat2)
        let dLon = degreesToRadians(long1 - long2)
        let tmplat1 = degreesToRadians(lat1)
        let tmplat2 = degreesToRadians(lat2)
        
        let a = sin(dLat / 2) * sin(dLat/2) + sin(dLon / 2) * sin(dLon / 2) * cos(tmplat1) * cos(tmplat2)
        
        let c = 2 * atan2(sqrt(a), sqrt(1-a))
        
        let res = radius * c * 1000.0
        
        // Print the calculated distance inside the textfield
        outputDistance.text = "\(res.rounded()) Meter"
    }
    
    
    /**
     This function can be used to calculate the angle between two decimal coordinates

     - parameter lat1: Latitude of the first coordinate.
     - parameter long1: Longitude of the first  coordinate.
     - parameter lat2: Latitude of the second coordinate.
     - parameter long2: Longitude of the second coordinate.
     */
    func calcAngle(lat1: Double, long1: Double, lat2: Double, long2: Double) {
        // Convert all radians to degrees
        let dLon = degreesToRadians(long2 - long1)
        let latdest = degreesToRadians(lat2)
        let latpos = degreesToRadians(lat1)
        
        let x = cos(latdest) * sin(dLon)
        let y = cos(latpos) * sin(latdest) - sin(latpos) * cos(latdest) * cos(dLon)
        
        // Calculate the direction in radian
        let bearing = atan2(x, y)
        
        // Convert the radian to degrees and print it to th textfield
        outputAngle.text = "\(((radiansToDegrees(bearing) + 360).truncatingRemainder(dividingBy: 360)).rounded())"
    }
    
    
    /**
     This function can be used to convert a degree value to a radian value

     - parameter val: Degrees to convert
     - returns: Degrees as a double
     */
    let degreesToRadians = {(val: Double) -> Double in
        return val * .pi / 180
    }
    
    /**
     This function can be used to convert a radian value to a degree value

     - parameter val: Degrees to convert
     - returns: Radian as a double
     */
    let radiansToDegrees = {(val: Double) -> Double in
        return val * 180 / .pi
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
       // Try to find next responder
       if let nextField = textField.superview?.viewWithTag(textField.tag + 1) as? UITextField {
          nextField.becomeFirstResponder()
       } else {
          // Not found, so remove keyboard.
          textField.resignFirstResponder()
       }
       // Do not add a line break
       return false
    }

}
