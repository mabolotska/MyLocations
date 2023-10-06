//
//  ViewController.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 27/09/23.
//

import UIKit
import CoreLocation

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    
    var location: CLLocation?
    
    
    
    var updatingLocation = false
    var lastLocationError: Error?
    
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        updateLabels()
    }
    
    // MARK: - Actions
    @IBAction func getLocation() {
        
        let authStatus = locationManager.authorizationStatus
        if authStatus == .notDetermined {
            locationManager.requestWhenInUseAuthorization()
            return
        }
        
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        
        if authStatus == .denied || authStatus == .restricted {
            showLocationServicesDeniedAlert()
            return
        }
        
        startLocationManager()
        updateLabels()
    }
    
    // MARK: - CLLocationManagerDelegate
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error
    ){
        print("didFailWithError \(error.localizedDescription)")
        if (error as NSError).code == CLError.locationUnknown.rawValue
        {
            return
        }
        lastLocationError = error
        stopLocationManager()
        updateLabels()
    }
    
    
    func locationManager(
      _ manager: CLLocationManager,
      didUpdateLocations locations: [CLLocation]
    ){
       
        let newLocation = locations.last!
        print("didUpdateLocations \(newLocation)")
        // 1
          if newLocation.timestamp.timeIntervalSinceNow < -5 {
        return
        }
        // 2
          if newLocation.horizontalAccuracy < 0 {
        return
        }
        
        if location == nil || location!.horizontalAccuracy >
      newLocation.horizontalAccuracy {
      // 4
          lastLocationError = nil
          location = newLocation
      // 5
          if newLocation.horizontalAccuracy <=
      locationManager.desiredAccuracy {
            print("*** We're done!")
            stopLocationManager()
          }
          updateLabels()
        }
        location = newLocation    
        
        lastLocationError = nil
        
         updateLabels()
        
        
    }
    
    func configureGetButton() {
      if updatingLocation {
        getButton.setTitle("Stop", for: .normal)
      } else {
          getButton.setTitle("Get My Location", for: .normal)
           }
         }
    
    func updateLabels() {
        //      if let location = location {
        //        latitudeLabel.text = String(
        //          format: "%.8f",
        //          location.coordinate.latitude)
        //        longitudeLabel.text = String(
        //          format: "%.8f",
        //          location.coordinate.longitude)
        //        tagButton.isHidden = false
        //        messageLabel.text = ""
        //      } else {
        //        latitudeLabel.text = ""
        //        longitudeLabel.text = ""
        //        addressLabel.text = ""
        //        tagButton.isHidden = true
        //        messageLabel.text = "Tap 'Get My Location' to Start"
        //          configureGetButton()
        //    }
        
        
        if let location = location {
           latitudeLabel.text = String(
             format: "%.8f",
             location.coordinate.latitude)
           longitudeLabel.text = String(
             format: "%.8f",
             location.coordinate.longitude)
           tagButton.isHidden = false
           messageLabel.text = ""
         } else {
           latitudeLabel.text = ""
           longitudeLabel.text = ""
           addressLabel.text = ""
           tagButton.isHidden = true
          
             let statusMessage: String
                if let error = lastLocationError as NSError? {
                  if error.domain == kCLErrorDomain && error.code == CLError.denied.rawValue {
                    statusMessage = "Location Services Disabled"
                  } else {
                    statusMessage = "Error Getting Location"
                  }
                } else if !CLLocationManager.locationServicesEnabled() {
                  statusMessage = "Location Services Disabled"
                } else if updatingLocation {
                  statusMessage = "Searching..."
            } else {
                  statusMessage = "Tap 'Get My Location' to Start"
                }
                messageLabel.text = statusMessage
              }
       }
    
    // MARK: - Helper Methods
    func showLocationServicesDeniedAlert() {
      let alert = UIAlertController(
        title: "Location Services Disabled",
        message: "Please enable location services for this app in Settings.",
        preferredStyle: .alert)
      let okAction = UIAlertAction(
        title: "OK",
        style: .default,
        handler: nil)
      alert.addAction(okAction)
      present(alert, animated: true, completion: nil)
    }
    
    func startLocationManager() {
      if CLLocationManager.locationServicesEnabled() {
        locationManager.delegate = self
        locationManager.desiredAccuracy =
    kCLLocationAccuracyNearestTenMeters
        locationManager.startUpdatingLocation()
        updatingLocation = true
      }
    }
 
    func stopLocationManager() {
      if updatingLocation {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        updatingLocation = false
    } }
    

}

