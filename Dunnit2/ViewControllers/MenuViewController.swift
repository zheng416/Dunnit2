//
//  MenuViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/1/21.
//

import UIKit

enum MenuType: Int {
    case all
    case shared
    case myList
    case settings
    case progress
    
}

class MenuViewController: UITableViewController {
    
    var didTapMenuType: ((MenuType) -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let menuType = MenuType(rawValue: indexPath.row) else { return }
        dismiss(animated: true) { [weak self] in
            print("Dismissing: \(menuType)")
            self?.didTapMenuType?(menuType)
        }
    }

}
