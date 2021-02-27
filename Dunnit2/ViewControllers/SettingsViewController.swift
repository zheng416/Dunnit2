//
//  SettingsViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 2/25/21.
//
import Foundation
import UIKit

class SettingsViewController: UITableViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("The selected section is \(indexPath.section)")
    }
    

    
}
