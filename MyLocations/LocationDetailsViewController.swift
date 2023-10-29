//
//  LocationDetailsViewController.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 09/10/23.
//

import UIKit
//import Date
import CoreLocation
import CoreData

class LocationDetailsViewController: UITableViewController {
    var date = Date()
    
    var locationToEdit: Location? {
      didSet {
        if let location = locationToEdit {
            descriptionText = location.locationDescription ?? ""
            categoryName = location.category ?? ""
          date = location.date
          coordinate = CLLocationCoordinate2DMake(
            location.latitude,
            location.longitude)
          placemark = location.placemark
    } }
    }
    
    
    var descriptionText = ""
    
    var categoryName = "No Category"
    var managedObjectContext: NSManagedObjectContext!

    @IBOutlet var descriptionTextView: UITextView!
    @IBOutlet var categoryLabel: UILabel!
    @IBOutlet var latitudeLabel: UILabel!
    @IBOutlet var longitudeLabel: UILabel!
    @IBOutlet var addressLabel: UILabel!
    @IBOutlet var dateLabel: UILabel!
    
    private let dateFormatter: DateFormatter = {
      let formatter = DateFormatter()
      formatter.dateStyle = .medium
      formatter.timeStyle = .short
      return formatter
    }()
    
    
    // MARK: - Actions
    @IBAction func done() {
        guard let mainView = navigationController?.parent?.view
         else { return }
         let hudView = HudView.hud(inView: mainView, animated: true)
         hudView.text = "Tagged"
         // 1
        let location: Location
        if let temp = locationToEdit {
          hudView.text = "Updated"
          location = temp
        } else {
          hudView.text = "Tagged"
          location = Location(context: managedObjectContext)
        }
      location.locationDescription = descriptionTextView.text
//         let location = Location(context: managedObjectContext)
//         // 2
//         location.locationDescription = descriptionTextView.text
         location.category = categoryName
         location.latitude = coordinate.latitude
         location.longitude = coordinate.longitude
         location.date = date
         location.placemark = placemark
        
       
        if let temp = locationToEdit {
          hudView.text = "Updated"
          location = temp
        } else {
          hudView.text = "Tagged"
          location = Location(context: managedObjectContext)
        }
      location.locationDescription = descriptionTextView.text
         // 3
         do {
           try managedObjectContext.save()
           afterDelay(0.6) {
             hudView.hide()
             self.navigationController?.popViewController(
               animated: true)
           }
       } catch { // 4
           fatalCoreDataError(error)
         }
    }
    @IBAction func cancel() {
      navigationController?.popViewController(animated: true)
    }

    
    var coordinate = CLLocationCoordinate2D(
      latitude: 0,
      longitude: 0)
    var placemark: CLPlacemark?
    
    override func viewDidLoad() {
      super.viewDidLoad()
        
        if let location = locationToEdit {
          title = "Edit Location"
        }
        
        
        dateLabel.text = format(date: date)
        
        categoryLabel.text = categoryName
        
        
        descriptionTextView.text = descriptionText
      categoryLabel.text = ""
      latitudeLabel.text = String(
        format: "%.8f",
        coordinate.latitude)
      longitudeLabel.text = String(
        format: "%.8f",
        coordinate.longitude)
      if let placemark = placemark {
        addressLabel.text = string(from: placemark)
    } else {
        addressLabel.text = "No Address Found"
      }
      dateLabel.text = format(date: Date())
        
        
        // Hide keyboard
        let gestureRecognizer = UITapGestureRecognizer(
          target: self,
          action: #selector(hideKeyboard))
        gestureRecognizer.cancelsTouchesInView = false
        tableView.addGestureRecognizer(gestureRecognizer)
    }
    
    // MARK: - Helper Methods
    func string(from placemark: CLPlacemark) -> String {
      var text = ""
      if let tmp = placemark.subThoroughfare {
        text += tmp + " "
      }
      if let tmp = placemark.thoroughfare {
        text += tmp + ", "
      }
      if let tmp = placemark.locality {
        text += tmp + ", "
      }
      if let tmp = placemark.administrativeArea {
        text += tmp + " "
      }
      if let tmp = placemark.postalCode {
        text += tmp + ", "
      }
       if let tmp = placemark.country {
     text += tmp }
     return text }
    
    
    func format(date: Date) -> String {
      return dateFormatter.string(from: date)
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
      if segue.identifier == "PickCategory" {
        let controller = segue.destination as! CategoryPickerViewController
        controller.selectedCategoryName = categoryName
      }
    }
    

    
    @IBAction func categoryPickerDidPickCategory(
      _ segue: UIStoryboardSegue
    ){
    let controller = segue.source as! CategoryPickerViewController 
        categoryName = controller.selectedCategoryName
        categoryLabel.text = categoryName
    }
    
    // MARK: - Table View Delegates
    override func tableView(
      _ tableView: UITableView,
      willSelectRowAt indexPath: IndexPath
    ) -> IndexPath? {
      if indexPath.section == 0 || indexPath.section == 1 {
        return indexPath
      } else {
    return nil
    } }
    
    
    override func tableView(  _ tableView: UITableView,
                              didSelectRowAt indexPath: IndexPath ){
                                if indexPath.section == 0 && indexPath.row == 0 {
                                  descriptionTextView.becomeFirstResponder()
                                }
                              }
    

    
    @objc func hideKeyboard(
      _ gestureRecognizer: UIGestureRecognizer
    ){
    let point = gestureRecognizer.location(in: tableView) 
        let indexPath = tableView.indexPathForRow(at: point)
      if indexPath != nil && indexPath!.section == 0 &&
      indexPath!.row == 0 {
    return
    }
      descriptionTextView.resignFirstResponder()
    }
    
 
}
