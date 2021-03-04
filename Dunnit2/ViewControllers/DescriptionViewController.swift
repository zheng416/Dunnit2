//
//  DescriptionViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/4/21.
//

import UIKit

class DescriptionViewController: UIViewController, UITextViewDelegate {

    var titleStr: String?
    
    var dateStr: String?
    
    var bodyStr: String?
    
    @IBOutlet var titleField: UITextView!
    
    @IBOutlet var dateField: UITextView!
    
    @IBOutlet var bodyField: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.text = titleStr
        dateField.text = dateStr
        bodyField.text = bodyStr
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
