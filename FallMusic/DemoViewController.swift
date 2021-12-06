//
//  DemoViewController.swift
//  FallMusic
//
//  Created by 俞佳兴 on 2021/12/5.
//

import UIKit

class DemoViewController: UIViewController {
    @IBOutlet var desLabel: UILabel!
    @IBOutlet var peakLabel: UILabel!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        self.desLabel.text = desURL
        var str = ""
        for i in peaks {
            str += String(i.position) + " "
        }
        self.peakLabel.text = str
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
