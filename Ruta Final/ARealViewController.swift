//
//  ARealViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 10-01-17.
//  Copyright © 2017 AppArt. All rights reserved.
//

import UIKit
import CoreLocation

class ARealViewController: UIViewController,ARDataSource {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let vista = TestAnnotationView()
        vista.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vista.frame = CGRect(x: 0, y: 0, width: 160, height: 60)
        return vista
    }
    
//    private func obtenAnotaciones( latitud: Double, longitud: Double, delta: Double, numeroDeElementos: Int) -> Array<ARAnnotation>{
//        var anotaciones: [ARAnnotation] = []
//        srand48(48)
//        for index in 1...numeroDeElementos {
//            let anotacion = ARAnnotation()
//            anotacion.location = self.obtenerPosiciones(latitud: latitud, longitud: longitud, delta: delta)
//            anotacion.title = "Punto de interés"
//            anotaciones.append(anotacion)
//        }
//        return anotaciones
//    }

    private func obtenerPosiciones( latitud: Double, longitud: Double, delta: Double )-> CLLocation{
        var lat = latitud
        var lon = longitud
        let latDelta = -(delta/2) + drand48() * delta
        let lonDelta = -(delta/2) + drand48() * delta
        lat = lat + latDelta
        lon = lon + lonDelta
        return CLLocation(latitude: lat, longitude: lon)
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
