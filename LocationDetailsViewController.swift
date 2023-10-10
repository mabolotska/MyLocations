//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 09/10/23.
//

import UIKit

class LocationDetailsViewController: UITableViewController {

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    // MARK: - Actions
    @IBAction func done() {
      navigationController?.popViewController(animated: true)
    }
    @IBAction func cancel() {
      navigationController?.popViewController(animated: true)
    }

}
