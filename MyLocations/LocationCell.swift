//
//  LocationCell.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 28/10/23.
//

import UIKit

class LocationCell: UITableViewCell {
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    
    // MARK: - Helper Method
    func configure(for location: Location) {
        if ((location.locationDescription?.isEmpty) != nil) {
        descriptionLabel.text = "(No Description)"
      } else {
        descriptionLabel.text = location.locationDescription
      }
      if let placemark = location.placemark {
        var text = ""
          if let tmp = placemark.subThoroughfare {
               text += tmp + " "
             }
             if let tmp = placemark.thoroughfare {
               text += tmp + ", "
             }
             if let tmp = placemark.locality {
         text += tmp }
             addressLabel.text = text
           } else {
             addressLabel.text = String(
               format: "Lat: %.8f, Long: %.8f",
               location.latitude,
               location.longitude)
         } }
}
