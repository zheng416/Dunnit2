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

protocol MapViewControllerDelegate: AnyObject {
    func mapViewController(_ vc: MapViewController, selectedLocationName: String, coordinates: CLLocationCoordinate2D?)
}

class MapViewController: UIViewController, MapSearchViewControllerDelegate {
    
    weak var delegate: MapViewControllerDelegate?
    let mapView = MKMapView()
    let panel = FloatingPanelController()
    
//    public var completion: ((String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(mapView)
        title = "Locations"
        
        let searchVC = MapSearchViewController()
        searchVC.delegate = self
        
        
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
        
        mapView.removeAnnotations(mapView.annotations)

        let pin = MKPointAnnotation()
        pin.coordinate = coordinates

        mapView.addAnnotation(pin)
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: false)
        
        
        print("chosen location",vc.chosenLocationName)
        
//        completion?(vc.chosenLocationName)
        
        // TODO: Maybe add delay here to see animation?

        
        delegate?.mapViewController(self, selectedLocationName: vc.chosenLocationName, coordinates: coordinates)
        print("Done delegate?")
        
        // Save to DB
        
        
        
        // Remove pins from map to prevent memory leak
        mapView.removeAnnotations(mapView.annotations)
        
        
        navigationController?.popViewController(animated: true)
        
    }
}
