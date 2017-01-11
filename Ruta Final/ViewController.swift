//
//  ViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 29-12-16.
//  Copyright © 2016 AppArt. All rights reserved.
//

import UIKit
import CoreLocation

class ViewController: UIViewController, CLLocationManagerDelegate {

    var administradorUbicacion = CLLocationManager()

    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Conectar administrador
        self.administradorUbicacion.delegate = self
        self.administradorUbicacion.requestWhenInUseAuthorization()     // Pide autorización para el GPS.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

