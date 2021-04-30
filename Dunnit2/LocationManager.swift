//
//  LocationManager.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 4/25/21.
//

import Foundation
import CoreLocation
import UserNotifications
import MapKit

struct Location {
    let title: String
    let coordinates: CLLocationCoordinate2D?
    let address: String
}

class LocationManager: NSObject, CLLocationManagerDelegate{
    static let shared = LocationManager()
    let notificationCenter = UNUserNotificationCenter.current()
    let manager = CLLocationManager()
    
    var completion: ((CLLocation) -> Void)?
    public func getUserlocation()->CLLocationCoordinate2D? {
        self.startMonitoringLocation()
        return manager.location?.coordinate
        
    }
    public func startMonitoringLocation() {
        //self.completion = completion
        manager.requestAlwaysAuthorization()
        manager.delegate = self
        manager.startUpdatingLocation()
    }
    
    public func resolveLocationName(with location: CLLocation, completion: @escaping ((String?) -> Void)) {
        let geocoder = CLGeocoder()
        geocoder.reverseGeocodeLocation(location, preferredLocale: .current) {
            placemarks, error in
            guard let place = placemarks?.first, error == nil else {
                completion(nil)
                return
            }
            
            print(place)
            
            var name = ""
            
            if let locality = place.locality {
                name += locality
            }
            
            if let adminRegion = place.administrativeArea {
                name += ", \(adminRegion)"
            }
            
            completion(name)
        }
    }
    
    public func findLocations(with query: String, completion: @escaping (([Location]) -> Void)) {
        let geoCoder = CLGeocoder()
        
        geoCoder.geocodeAddressString(query) {places, error in
            guard let places = places, error == nil else {
                completion([])
                return
            }
            
            let models: [Location] = places.compactMap({ place in
                
                var name = ""
                
                if let locationName = place.name {
                    name += locationName
                }
                
                if let administrativeArea = place.administrativeArea {
                    name += ", \(administrativeArea)"
                }
                
                if let locality = place.locality {
                    name += ", \(locality)"
                }
                
                if let country = place.country {
                    name += ", \(country)"
                }
                
                print("\n\(place)\n\n")
                
                let result = Location(title: name, coordinates: place.location?.coordinate, address: name)
                
                return result
            })
            
            completion(models)
            
        }
    }
    public func notified(region: CLCircularRegion){
        let options: UNAuthorizationOptions = [.sound, .alert]
        notificationCenter.requestAuthorization(options: options){
            result, _ in
            print("request result\(result)")
        }
        let notification = UNMutableNotificationContent()
        notification.title = "Hello"
        notification.body = "Hi"
        notification.sound = .default
        let trigger = UNLocationNotificationTrigger(
            region: region, repeats: false
        )
        
        let request = UNNotificationRequest(
            identifier: UUID().uuidString, content: notification, trigger: trigger)
        notificationCenter.add(request){
            error in
            if error != nil{
                print("notification error \(error)")
            }
        }
        print("Set up notification \(region)")
        //manager.startMonitoring(for: region)
    }
    
    public func findNearbyLocations(with query: String, completion: @escaping (([Location]) -> Void)) {
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = query
//        request.region = mapView.region
        
        var locations = [Location]()
        
        let search = MKLocalSearch(request: request)
        search.start { response, _ in
            guard let response = response else {
                return
            }
            print("local area places", response.mapItems)
//            self.tableView.reloadData()
            
            locations = response.mapItems.map({place in print("place", place)
                
                print("name", place.name)
                print("name1", place.placemark.title)
                print("name2", place.placemark.coordinate)
                
                let locationName = place.name
                let address = place.placemark.title
                let coordinates = place.placemark.coordinate
                
                return Location(title: locationName ?? "", coordinates: coordinates ?? nil, address: address ?? "")
                
            })
            
            completion(locations)
        }
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.first else {
            return
        }
        completion?(location)
        manager.stopUpdatingLocation()
    }
    func locationManager(_ manager: CLLocationManager,
        didEnterRegion region: CLRegion) {
        print("Enter the region")
      // do something on entry
    }
}
