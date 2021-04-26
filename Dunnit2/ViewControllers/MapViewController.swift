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

class MapViewController: UIViewController, MapSearchViewControllerDelegate {
    
    let mapView = MKMapView()
    let panel = FloatingPanelController()
    
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
        mapView.setRegion(MKCoordinateRegion(center: coordinates, span: MKCoordinateSpan(latitudeDelta: 0.7, longitudeDelta: 0.7)), animated: true)
    }
}
