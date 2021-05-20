//
//  MapSearchViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 4/25/21.
//

import UIKit
import MapKit
import CoreLocation

// Delegate to handle passing data back to MapViewController when click on row
protocol MapSearchViewControllerDelegate: AnyObject {
    func mapSearchViewController(_ vc: MapSearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

class MapSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    weak var delegate: MapSearchViewControllerDelegate?
    public var chosenLocationName: String! = ""
    
    // Setup labels and table view
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Where To?"
        label.font = .systemFont(ofSize: 24, weight: .semibold)
        return label
    }()
    
    private let field: UITextField = {
        let field = UITextField()
        field.placeholder = "Enter Destination"
        field.layer.cornerRadius = 9
        field.backgroundColor = .tertiarySystemBackground
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 50))
        return field
    }()
    
    private let tableView: UITableView = {
        let table = UITableView()
        table.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        return table
    }()
    
    var locations = [Location]()
    
    override func viewDidLoad(){
        super.viewDidLoad()
        // Style vc
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(label)
        view.addSubview(field)
        view.addSubview(tableView)
        
        // Link delegates and data sources for table view
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .secondarySystemBackground
        field.delegate = self
    }
    
    // Setup labels on VC programitically
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        
        field.frame = CGRect(x: 20, y: 20+label.frame.size.height, width: view.frame.size.width-20, height: 50)
        let tableY: CGFloat = field.frame.origin.y+field.frame.size.height+5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height - tableY)
    }
    
    // When clicked on cell should return
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        if let text = field.text, !text.isEmpty {
            LocationManager.shared.findNearbyLocations(with: text) {
                [weak self] locations in
                    self?.locations = locations
                    self?.tableView.reloadData()
            }
        }
        return true
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return locations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell = UITableViewCell(style: UITableViewCell.CellStyle.subtitle, reuseIdentifier: "cell")
        
        cell.textLabel?.text = locations[indexPath.row].title
        cell.detailTextLabel?.text = locations[indexPath.row].address
        cell.textLabel?.numberOfLines = 0
        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
        
        // Save chosen cell for passing back to mapVC
        chosenLocationName = locations[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        /// When a row is selected ...
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Get the coordinates of that selected location
        let coordinate = locations[indexPath.row].coordinates
        print("coords", coordinate)
        
        // Pass coordinates back to mapVC
        delegate?.mapSearchViewController(self, didSelectLocationWith: coordinate)
        
        
    }
    
}
