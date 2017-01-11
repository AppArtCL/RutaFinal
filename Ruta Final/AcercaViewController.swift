//
//  AcercaViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 30-12-16.
//  Copyright © 2016 AppArt. All rights reserved.
//

import UIKit

class AcercaViewController: ViewController {

    @IBOutlet weak var etiquetaVersion: UILabel!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        var versionApp = "Version: "
        let vs = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString")
        versionApp = versionApp + String(describing: vs!)
        etiquetaVersion.text = versionApp
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
