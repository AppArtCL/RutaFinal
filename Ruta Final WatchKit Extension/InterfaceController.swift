//
//  InterfaceController.swift
//  Ruta Final WatchKit Extension
//
//  Created by Cristian Diaz on 29-12-16.
//  Copyright © 2016 AppArt. All rights reserved.
//

import WatchKit
import Foundation
import CoreLocation

class InterfaceController: WKInterfaceController, CLLocationManagerDelegate {

    var locationManager: CLLocationManager = CLLocationManager()
    var ubicacion: CLLocationCoordinate2D?
    
    @IBOutlet var mapa: WKInterfaceMap!
    
    @IBAction func hacerZoom(_ value: Float) {
        let grados: CLLocationDegrees = CLLocationDegrees(value/10)
        let span = MKCoordinateSpanMake(grados, grados)
        let region = MKCoordinateRegionMake(self.ubicacion!, span)
        self.mapa.setRegion(region)
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let currentLocation = locations[0]
        let lat = currentLocation.coordinate.latitude
        let long = currentLocation.coordinate.longitude
        self.ubicacion = CLLocationCoordinate2DMake(lat, long)
        let span = MKCoordinateSpanMake(0.1, 0.1)
        let region = MKCoordinateRegionMake(self.ubicacion!, span)
        self.mapa.setRegion(region)
        self.mapa.addAnnotation(self.ubicacion!, with: .red)
    }
    
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        print(Error.self)
    }
    
    override func awake(withContext context: Any?) {
        super.awake(withContext: context)
        
        self.locationManager.requestWhenInUseAuthorization()
        self.locationManager.desiredAccuracy = kCLLocationAccuracyBest
        self.locationManager.delegate = self
        self.locationManager.requestLocation()
    }
    
    override func willActivate() {
        // This method is called when watch view controller is about to be visible to user
        super.willActivate()
    }
    
    override func didDeactivate() {
        // This method is called when watch view controller is no longer visible
        super.didDeactivate()
    }

}
