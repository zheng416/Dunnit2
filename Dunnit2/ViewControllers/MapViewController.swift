//
//  MapViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 4/25/21.
//

import UIKit
import MapKit
import FloatingPanel
import CoreLocation
import UserNotifications


protocol MapViewControllerDelegate: AnyObject {
    func mapViewController(_ vc: MapViewController, selectedLocationName: String, coordinates: CLLocationCoordinate2D?)
}

class MapViewController: UIViewController, MapSearchViewControllerDelegate {
    
    weak var delegate: MapViewControllerDelegate?
    let mapView = MKMapView()
    let panel = FloatingPanelController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // add AppleMaps to view
        view.addSubview(mapView)
        title = "Locations"
        
        let searchVC = MapSearchViewController()
        searchVC.delegate = self
        
        // Place a pin on users' current location
        let currentlocation = LocationManager.shared.getUserlocation()
        let pin = MKPointAnnotation()
        if currentlocation != nil{
            pin.coordinate = currentlocation!
            mapView.addAnnotation(pin)
            mapView.setRegion(MKCoordinateRegion(center: currentlocation!, span: MKCoordinateSpan(latitudeDelta: 0.005, longitudeDelta: 0.005)), animated: true)
        }

        // Make mapSearchViewController the popup panel
        panel.set(contentViewController: searchVC)
        panel.addPanel(toParent: self)
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        mapView.frame = view.bounds
    }
    
    func mapSearchViewController(_ vc: MapSearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?) {

        print("coordinates", coordinates)
        
        guard let coordinates = coordinates else {
            return
        }
        
        panel.move(to: .tip, animated: true)
        
        // Clear all pins from map
        mapView.removeAnnotations(mapView.annotations)
        
        // Hardcode location
        var favCoordinatesArray: CLLocationCoordinate2D  = CLLocationCoordinate2D(latitude: 37.422155, longitude: -122.134751)
        let pin = MKPointAnnotation()
        
        pin.coordinate = coordinates//favCoordinatesArray
        print("get coordinate search")
        let radius = 2
        let identifier = "times-square"
        //let region = CLCircularRegion(center: coordinates, radius: CLLocationDistance(radius),
           // identifier: identifier)
        let region = CLCircularRegion(center: favCoordinatesArray, radius: CLLocationDistance(radius),
            identifier: identifier)
        region.notifyOnEntry = true
        region.notifyOnExit = true
        let options: UNAuthorizationOptions = [.sound, .alert]
        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.removeAllPendingNotificationRequests()
        notificationCenter.removeAllDeliveredNotifications()
        notificationCenter.requestAuthorization(options: options){
            result, _ in
            print("request result\(result)")
        }
        let notification = UNMutableNotificationContent()
        notification.title = "Location Test"
        notification.body = "You arrived at Apple Park"
        notification.sound = .default
        let trigger = UNLocationNotificationTrigger(
            region: region, repeats: true
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: notification, trigger: trigger)
        notificationCenter.add(request){
            error in
            if error != nil{
                print("notification error \(error)")
            }
        }
        /*notificationCenter.add(request2){
            error in
            if error != nil{
                print("notification error \(error)")
            }
        }*/

        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: false)
        
        
        print("chosen location",vc.chosenLocationName)
        
//        completion?(vc.chosenLocationName)
        
        // TODO: Maybe add delay here to see animation?
        delegate?.mapViewController(self, selectedLocationName: vc.chosenLocationName, coordinates: coordinates)
        print("Done delegate?")
        
        // Remove pins from map to prevent memory leak
        mapView.removeAnnotations(mapView.annotations)
        
        // Redirect to previous vc
        navigationController?.popViewController(animated: true)
    }
}
