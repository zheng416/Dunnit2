//
//  ListTaskViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/4/21.
//

import UIKit

class ListTaskViewController: UIViewController {

    var titleList: String?
    @IBOutlet var tableTaskView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = titleList
        // Do any additional setup after loading the view.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
