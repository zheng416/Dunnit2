//
//  MapSearchViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 4/25/21.
//

import UIKit
import CoreLocation

protocol MapSearchViewControllerDelegate: AnyObject {
    func mapSearchViewController(_ vc: MapSearchViewController, didSelectLocationWith coordinates: CLLocationCoordinate2D?)
}

class MapSearchViewController: UIViewController, UITextFieldDelegate, UITableViewDelegate, UITableViewDataSource {
    
    weak var delegate: MapSearchViewControllerDelegate?
    public var chosenLocationName: String! = ""
    
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
        view.backgroundColor = .secondarySystemBackground
        view.addSubview(label)
        view.addSubview(field)
        view.addSubview(tableView)
        
        tableView.delegate = self
        tableView.dataSource = self
        tableView.backgroundColor = .secondarySystemBackground
        field.delegate = self
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        label.sizeToFit()
        label.frame = CGRect(x: 10, y: 10, width: label.frame.size.width, height: label.frame.size.height)
        
        field.frame = CGRect(x: 20, y: 20+label.frame.size.height, width: view.frame.size.width-20, height: 50)
        let tableY: CGFloat = field.frame.origin.y+field.frame.size.height+5
        tableView.frame = CGRect(x: 0, y: tableY, width: view.frame.size.width, height: view.frame.size.height - tableY)
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        field.resignFirstResponder()
        if let text = field.text, !text.isEmpty {
            LocationManager.shared.findLocations(with: text) { [weak self] locations in
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
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        
        cell.textLabel?.text = locations[indexPath.row].title
        cell.textLabel?.numberOfLines = 0
        cell.contentView.backgroundColor = .secondarySystemBackground
        cell.backgroundColor = .secondarySystemBackground
        
        chosenLocationName = locations[indexPath.row].title
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // Notify map controller to show pin at selected place
        
        let coordinate = locations[indexPath.row].coordinates
    
        print("coords", coordinate)
        
        delegate?.mapSearchViewController(self, didSelectLocationWith: coordinate)
        
        
    }
    
}
