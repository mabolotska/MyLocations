//
//  ViewController.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 27/09/23.
//

import UIKit
import CoreLocation
import CoreData

class CurrentLocationViewController: UIViewController, CLLocationManagerDelegate {
    
    let locationManager = CLLocationManager()
    var managedObjectContext: NSManagedObjectContext!
    
    var location: CLLocation?
    var timer: Timer?
    
    
    var updatingLocation = false
    var lastLocationError: Error?
    
    let geocoder = CLGeocoder()
    var placemark: CLPlacemark?
    var performingReverseGeocoding = false
    var lastGeocodingError: Error?
    
    
    
    @IBOutlet weak var messageLabel: UILabel!
    @IBOutlet weak var latitudeLabel: UILabel!
    @IBOutlet weak var longitudeLabel: UILabel!
    @IBOutlet weak var addressLabel: UILabel!
    @IBOutlet weak var tagButton: UIButton!
    @IBOutlet weak var getButton: UIButton!
    
    
    override func viewWillAppear(_ animated: Bool) {
      super.viewWillAppear(animated)
      navigationController?.isNavigationBarHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
      super.viewWillDisappear(animated)
      navigationController?.isNavigationBarHidden = false
    }
    
    
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
        
        if updatingLocation {
          stopLocationManager()
        } else {
          location = nil
          lastLocationError = nil
          startLocationManager()
        }
        
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
            
            if !performingReverseGeocoding {
                print("*** Going to geocode")
                performingReverseGeocoding = true
                geocoder.reverseGeocodeLocation(newLocation) {placemarks,
                    error in
                    
                    
//                    if let error = error {
//                        print("*** Reverse Geocoding error: \(error.localizedDescription)")
//                        return
//                    }
//                    if let places = placemarks {
//                        print("*** Found places: \(places)")
//                    }
                    
                    self.lastGeocodingError = error
                    if error == nil, let places = placemarks, !places.isEmpty {
                      self.placemark = places.last!
                    } else {
                      self.placemark = nil
                    }
                    self.performingReverseGeocoding = false
                    self.updateLabels()
                }
                
                
            }
                          
                          
        }
        
        
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
            
            if let placemark = placemark {
                 addressLabel.text = string(from: placemark)
               } else if performingReverseGeocoding {
                 addressLabel.text = "Searching for Address..."
               } else if lastGeocodingError != nil {
                 addressLabel.text = "Error Finding Address"
           } else {
                 addressLabel.text = "No Address Found"
               }
         }
        
    
        else {
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
    
    override func prepare(for segue: UIStoryboardSegue, sender:
    Any?) {
      if segue.identifier == "TagLocation" {
        let controller = segue.destination as!
    LocationDetailsViewController
        controller.coordinate = location!.coordinate
        controller.placemark = placemark
          controller.managedObjectContext = managedObjectContext
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
          
          timer = Timer.scheduledTimer(
                timeInterval: 60,
                target: self,
                selector: #selector(didTimeOut),
                userInfo: nil,
                repeats: false)
      }
    }
 
    func stopLocationManager() {
      if updatingLocation {
        locationManager.stopUpdatingLocation()
        locationManager.delegate = nil
        updatingLocation = false
          
          if let timer = timer {
                timer.invalidate()
              }
    } }
    
    func string(from placemark: CLPlacemark) -> String {
      // 1
      var line1 = ""
      // 2
      if let tmp = placemark.subThoroughfare {
        line1 += tmp + " "
      }
    // 3
      if let tmp = placemark.thoroughfare {
    line1 += tmp }
    // 4
      var line2 = ""
      if let tmp = placemark.locality {
        line2 += tmp + " "
      }
      if let tmp = placemark.administrativeArea {
        line2 += tmp + " "
      }
      if let tmp = placemark.postalCode {
    line2 += tmp }
    // 5
      return line1 + "\n" + line2
    }
    
    @objc func didTimeOut() {
      print("*** Time out")
      if location == nil {
        stopLocationManager()
        lastLocationError = NSError(
          domain: "MyLocationsErrorDomain",
          code: 1,
          userInfo: nil)
        updateLabels()
      }
    }
}

