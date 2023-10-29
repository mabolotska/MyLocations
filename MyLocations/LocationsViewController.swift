//
//  LocationsViewController.swift
//  MyLocations
//
//  Created by Maryna Bolotska on 26/10/23.
//

import UIKit
import CoreData
import CoreLocation


class LocationsViewController: UITableViewController {
    //var locations = [Location]()
    
    lazy var fetchedResultsController:
    NSFetchedResultsController<Location> = {
      let fetchRequest = NSFetchRequest<Location>()
      let entity = Location.entity()
      fetchRequest.entity = entity
      let sortDescriptor = NSSortDescriptor(
        key: "date",
        ascending: true)
      fetchRequest.sortDescriptors = [sortDescriptor]
      fetchRequest.fetchBatchSize = 20
      let fetchedResultsController = NSFetchedResultsController(
        fetchRequest: fetchRequest,
        managedObjectContext: self.managedObjectContext,
        sectionNameKeyPath: nil,
        cacheName: "Locations")
      fetchedResultsController.delegate = self
      return fetchedResultsController
    }()
    
    let fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
      managedObjectContext: self.managedObjectContext,
      sectionNameKeyPath: nil,
      cacheName: "Locations")
    
    
  var managedObjectContext: NSManagedObjectContext!
    
//    override func viewDidLoad() {
//      super.viewDidLoad()
//      // 1
//      let fetchRequest = NSFetchRequest<Location>()
//      // 2
//      let entity = Location.entity()
//      fetchRequest.entity = entity
//      // 3
//      let sortDescriptor = NSSortDescriptor(key: "date",
//        ascending: true)
//      fetchRequest.sortDescriptors = [sortDescriptor]
//      do {
//    // 4
//        locations = try managedObjectContext.fetch(fetchRequest)
//      } catch {
//        fatalCoreDataError(error)
//      }
//    }
    
    override func viewDidLoad() {
      super.viewDidLoad()
      performFetch()
    }
    // MARK: - Helper methods
    func performFetch() {
      do {
        try fetchedResultsController.performFetch()
      } catch {
        fatalCoreDataError(error)
      }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender:
    Any?) {
      if segue.identifier == "EditLocation" {
        let controller = segue.destination  as!
    LocationDetailsViewController
        controller.managedObjectContext = managedObjectContext
        if let indexPath = tableView.indexPath(
          for: sender as! UITableViewCell) {
          let location = locations[indexPath.row]
          controller.locationToEdit = location
    } }
    }
    
    
  // MARK: - Table View Delegates
    override func tableView(
      _ tableView: UITableView,
      numberOfRowsInSection section: Int
    ) -> Int {
      let sectionInfo = fetchedResultsController.sections![section]
      return sectionInfo.numberOfObjects
    }
    
    
//    
//    override func tableView(
//      _ tableView: UITableView,
//      cellForRowAt indexPath: IndexPath
//    ) -> UITableViewCell {
        //      let cell = tableView.dequeueReusableCell(
        //        withIdentifier: "LocationCell",
        //        for: indexPath)
        //      let location = locations[indexPath.row]
        //      let descriptionLabel = cell.viewWithTag(100) as! UILabel
        //      descriptionLabel.text = location.locationDescription
        //      let addressLabel = cell.viewWithTag(101) as! UILabel
        //      if let placemark = location.placemark {
        //        var text = ""
        //        if let tmp = placemark.subThoroughfare {
        //          text += tmp + " "
        //        }
        //        if let tmp = placemark.thoroughfare {
        //          text += tmp + ", "
        //        }
        //        if let tmp = placemark.locality {
        //    text += tmp }
        //          addressLabel.text = text
        //          } else {
        //            addressLabel.text = ""
        //          }
        //        return cell
//        let cell = tableView.dequeueReusableCell(
//           withIdentifier: "LocationCell",
//           for: indexPath) as! LocationCell
//         let location = locations[indexPath.row]
//         cell.configure(for: location)
//       return cell
//    }
    
    override func tableView(
      _ tableView: UITableView,
      cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
      let cell = tableView.dequeueReusableCell(
        withIdentifier: "LocationCell",
        for: indexPath) as! LocationCell
        let location = fetchedResultsController.object(at: indexPath)
         cell.configure(for: location)
       return cell }
        
        
        
        
    deinit {
      fetchedResultsController.delegate = nil
    }
}

// MARK: - NSFetchedResultsController Delegate Extension
extension LocationsViewController:
    NSFetchedResultsControllerDelegate {
    func controllerWillChangeContent(
      _ controller:
  NSFetchedResultsController<NSFetchRequestResult> ){
      print("*** controllerWillChangeContent")
      tableView.beginUpdates()
    }
    func controller(
      _ controller:
  NSFetchedResultsController<NSFetchRequestResult>,
      didChange anObject: Any,
      at indexPath: IndexPath?,
      for type: NSFetchedResultsChangeType,
      newIndexPath: IndexPath?
  ){
  switch type { case .insert:
        print("*** NSFetchedResultsChangeInsert (object)")
        tableView.insertRows(at: [newIndexPath!], with: .fade)
      case .delete:
        print("*** NSFetchedResultsChangeDelete (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)
      case .update:
        print("*** NSFetchedResultsChangeUpdate (object)")
        if let cell = tableView.cellForRow(
          at: indexPath!) as? LocationCell {
          let location = controller.object(
            at: indexPath!) as! Location
          cell.configure(for: location)
  }
      case .move:
        print("*** NSFetchedResultsChangeMove (object)")
        tableView.deleteRows(at: [indexPath!], with: .fade)
        tableView.insertRows(at: [newIndexPath!], with: .fade)
      @unknown default:
        print("*** NSFetchedResults unknown type")
      }
  }
    func controller(
      _ controller:
  NSFetchedResultsController<NSFetchRequestResult>,
      didChange sectionInfo: NSFetchedResultsSectionInfo,
      atSectionIndex sectionIndex: Int,
      for type: NSFetchedResultsChangeType
  ){
      switch type { case .insert:
          print("*** NSFetchedResultsChangeInsert (section)")
          tableView.insertSections(
            IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
          print("*** NSFetchedResultsChangeDelete (section)")
          tableView.deleteSections(
            IndexSet(integer: sectionIndex), with: .fade)
        case .update:
          print("*** NSFetchedResultsChangeUpdate (section)")
        case .move:
          print("*** NSFetchedResultsChangeMove (section)")
        @unknown default:
          print("*** NSFetchedResults unknown type")
        }
    }
      func controllerDidChangeContent(
        _ controller:
    NSFetchedResultsController<NSFetchRequestResult> ){
        print("*** controllerDidChangeContent")
        tableView.endUpdates()
      }
    }
