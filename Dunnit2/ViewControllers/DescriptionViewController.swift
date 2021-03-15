//
//  DescriptionViewController.swift
//  Dunnit2
//
//  Created by Jason Tong on 3/4/21.
//

import UIKit

class DescriptionViewController: UIViewController, UITextViewDelegate {

    var titleStr: String?
    
    var dateVal: Date?
    
    var bodyStr: String?
    
    var topicStr: String?
    
    @IBOutlet var titleField: UITextView!
    
    @IBOutlet var dateField: UITextView!
    
    @IBOutlet var bodyField: UITextView!
    
    @IBOutlet var topicField: UITextView!
    
    public var completion: ((String, String, Date, String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        titleField.text = titleStr
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM dd, YYYY"
        dateField.text = formatter.string(from: self.dateVal!)
        bodyField.text = bodyStr
        topicField.text = topicStr
        // Do any additional setup after loading the view.
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapEditButton))

    }
    
    @objc func didTapEditButton(){
        let storyboard = UIStoryboard(name: "Home", bundle: nil)
        guard let vc = storyboard.instantiateViewController(identifier: "editTask") as? EditViewController else {
            return
        }
        vc.titleStr = self.titleStr
        vc.dateVal = self.dateVal
        vc.bodyStr = self.bodyStr
        vc.topicStr = self.topicStr
        vc.title = "Edit"
        vc.navigationItem.largeTitleDisplayMode = .never
        vc.completion = {title, body, date, color in
            DispatchQueue.main.async {
                self.titleField.text = title
                let formatter = DateFormatter()
                formatter.dateFormat = "MMM dd, YYYY"
                self.dateField.text = formatter.string(from: date)
                self.bodyField.text = body
                self.topicField.text = color
                /*DataBaseHelper.shareInstance.save(title: title, body: body, date: date, isDone: false)*/
                self.completion?(title, body, date, color)
            }
        }
        navigationController?.pushViewController(vc, animated: true)
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
