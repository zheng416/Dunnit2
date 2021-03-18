//
//  SortingViewController.swift
//  Dunnit2
//
//  Created by Andrew T Lim on 3/11/21.
//

import Foundation
import UIKit

class SortingViewController: UIViewController{
    
    var tableViewController: SelectSortTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = UIColor.gray.withAlphaComponent(0.5)
        
        tableViewController = self.children[0] as? SelectSortTableViewController
        tableViewController?.delegate = self
    }
}

extension SortingViewController : SelectSortTableViewControllerDelegate {
    // do stuff here
    func logoutTapped() {
        print("logout tapped")
    }
}

class SelectSortTableViewController: UITableViewController {
    
    // this would be the parent view controller
    var delegate : SelectSortTableViewControllerDelegate?
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        print("selected \(indexPath)")
        tableView.deselectRow(at: indexPath, animated: true)
        
    }
    

}

protocol SelectSortTableViewControllerDelegate {
  func logoutTapped()
}
