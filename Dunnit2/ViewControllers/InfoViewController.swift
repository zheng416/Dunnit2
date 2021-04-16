//
//  InfoViewController.swift
//  Dunnit2
//
//  Created by Jacky Zheng on 3/22/21.
//

import UIKit

class InfoViewController: UIViewController {
    
    
    @IBOutlet weak var ListTitle: UILabel!
    
    @IBOutlet weak var SharedBy: UILabel!
    
    @IBOutlet weak var Remove: UIButton!
    
    var owner: String?
    var id: String?
    var titleList: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ListTitle.text = titleList
        SharedBy.text = owner
        // Do any additional setup after loading the view.
    }
    
    @IBAction func removeTapped(_ sender: Any) {
        print("remove")
        print(titleList)
        print(owner)
        print(id)
        DataBaseHelper.shareInstance.removeSharedEntityDB(lid: id!, sharedBy: owner!, completion: {success in
            if success {
                DataBaseHelper.shareInstance.removedSharedLocal(title: self.titleList!, owner: self.owner!, id: self.id!,  completion: {success in
                    if success {
                        print("Success")
                        self.navigationController?.popToRootViewController(animated: true)
                     
                    }
                })
            }
        })
        
        
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
