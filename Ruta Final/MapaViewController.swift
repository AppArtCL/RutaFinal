//
//  MapaViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 01-01-17.
//  Copyright © 2017 AppArt. All rights reserved.
//

import UIKit
import MapKit
import CoreLocation
import CoreData

class MapaViewController: UIViewController, MKMapViewDelegate, CLLocationManagerDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate, ARDataSource {
    
    // MARK: - Variables
    var nombreRutaMapa = ""             //Guarda el nombre de la ruta
    var administradorUbicacion = CLLocationManager()
    var puntoInicial: CLLocation?       // Registra el punto de partida
    var ultimaUbicacion: CLLocation?    // Registra la ultima ubicacion centrada
    var ultimoPunto: MKMapItem?         // Registra el ultimo punto con PIN
    var nombreUltimoPunto = "Punto Inicial" // Registra el nombre del ultimo punto con PIN
    var existeAlMenosUnPunto = false
    var noEsRutaNueva = true
    var listaPuntos: [MKMapItem] = []

    // MARK: - Conexiones
    @IBOutlet weak var mapa: MKMapView!
    
    // Comparte los puntos del mapa
    @IBAction func compartirPuntos(_ sender: Any) {
        // Comparto sólo si hay puntos, si no, envío mensaje
        if self.listaPuntos.count > 0 {
            var coordenadas: [String] = []
            for puntito in self.listaPuntos {
                let texto = "\(puntito.name!): \(puntito.placemark.coordinate.latitude),\(puntito.placemark.coordinate.longitude)"
                coordenadas.append(texto)
            }
            let actividad = UIActivityViewController(activityItems: coordenadas, applicationActivities: nil)
            actividad.popoverPresentationController?.sourceView = self.view // para evitar que se caiga en iPad
            self.present(actividad, animated: true, completion: nil)
        } else {
            let avisoPuntos = UIAlertController(title: "Importante", message: "No hay puntos para compartir. Usted debe crear al menos uno.", preferredStyle: UIAlertControllerStyle.alert)
            avisoPuntos.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(avisoPuntos, animated: true, completion: nil)
        }
    }
    
    @IBAction func abrirAR(_ sender: Any) {
        
        
        if self.listaPuntos.count > 0 {
            // Creo la lista de los puntos para mostrar
            var listaPuntosAR: [ARAnnotation] = []
            for puntito in self.listaPuntos {
                let anotacion = ARAnnotation()
                anotacion.location = CLLocation(latitude: puntito.placemark.coordinate.latitude, longitude: puntito.placemark.coordinate.longitude)
                anotacion.title = puntito.name
                listaPuntosAR.append(anotacion)
            }
            
            
            let arViewController = ARViewController()
            arViewController.dataSource = self
            arViewController.maxDistance = 0
            arViewController.maxVisibleAnnotations = 100
            arViewController.maxVerticalLevel = 5
            arViewController.headingSmoothingFactor = 0.05
            arViewController.trackingManager.userDistanceFilter = 25
            arViewController.trackingManager.reloadDistanceFilter = 75
            arViewController.setAnnotations(listaPuntosAR)
            arViewController.uiOptions.debugEnabled = true
            arViewController.uiOptions.closeButtonEnabled = true
            //arViewController.interfaceOrientationMask = .landscape
            arViewController.onDidFailToFindLocation =
                {
                    [weak self, weak arViewController] elapsedSeconds, acquiredLocationBefore in
                    // Show alert and dismiss
            }
            self.present(arViewController, animated: true, completion: nil)
        }
    }
    
    // Muestra la ruta de los puntos favoritos
    @IBAction func mostrarRuta(_ sender: Any) {
        // Revisar si hay puntos para la ruta
        if listaPuntos.count < 2 {
            // Entrego mensaje que no se puede crear ruta con un punto
            let avisoPuntos = UIAlertController(title: "Importante", message: "Deben existir al menos dos puntos para crear una ruta. Usted sólo ha creado uno.", preferredStyle: UIAlertControllerStyle.alert)
            avisoPuntos.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(avisoPuntos, animated: true, completion: nil)
        } else {
            // Muestro la ruta con a lo menos dos puntos
            var iPuntos = 1
            while iPuntos < self.listaPuntos.count {
                let origenTemporal = listaPuntos[iPuntos-1]
                let destinoTemporal = listaPuntos[iPuntos]
                crearRuta(origen: origenTemporal, destino: destinoTemporal)
                iPuntos = iPuntos + 1
            }
            
            // Centro el mapa para que muesrte toda la ruta
            let centroMapa = self.listaPuntos[0].placemark.coordinate
            let region = MKCoordinateRegionMakeWithDistance(centroMapa, 3500, 3500)
            self.mapa.setRegion(region, animated: true)
        }
    }
    
    
    // Abre ventana para tomar fotografía
    @IBAction func tomaFotografia(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.camera) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.camera;
            imagePicker.allowsEditing = false
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let aviso = UIAlertController(title: "Importante", message: "No hay cámara disponible para tomar fotografía. Debe usar en dispositivo o usar una fotografía guardada.", preferredStyle: UIAlertControllerStyle.alert)
            aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(aviso, animated: true, completion: nil)
        }
    }
    
    // Abre ventana para capturar código
    @IBAction func capturarCodigoQR(_ sender: Any) {
        self.performSegue(withIdentifier: "IrAQR", sender: self)
    }
    
    // Agrega un chinche en la ubicación actual
    @IBAction func crearPunto(_ sender: Any) {
        let ubicacionActual = self.mapa.userLocation
        let chinche = MKPointAnnotation()
        chinche.title = String("Pendiente")
        chinche.coordinate = ubicacionActual.coordinate
        
        // Mensaje para pedir el nombre del punto y luego ejecuto agregarPunto
        let aviso = UIAlertController(title: "Nuevo Punto de Interés", message: "Ingrese el nombre del punto.", preferredStyle: UIAlertControllerStyle.alert)
        aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: {
            alert -> Void in
            let campoNombre = aviso.textFields![0] as UITextField
            if (campoNombre.text! == "") || (campoNombre.text == nil) {
                self.agregarPunto(punto: chinche, nombre: "Sin Nombre")
                self.nombreUltimoPunto = "Sin Nombre"
            } else {
                self.agregarPunto(punto: chinche, nombre: campoNombre.text!)
                self.nombreUltimoPunto = campoNombre.text!
            }
        }))
        aviso.addTextField(configurationHandler: {(campoTexto: UITextField!) -> Void in
            campoTexto.placeholder = "Nombre del punto..."
        })
        self.present(aviso, animated: true, completion: nil)
    }
    
    
    // MARK: - Funciones
    // Funcion para configurar info de AR
    func ar(_ arViewController: ARViewController, viewForAnnotation: ARAnnotation) -> ARAnnotationView {
        let vista = TestAnnotationView()
        vista.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        vista.frame = CGRect(x: 0, y: 0, width: 160, height: 60)
        return vista
    }
    
    // Agrego el punto al mapa
    func agregarPunto(punto: MKPointAnnotation, nombre: String) {
        punto.title = String(nombre)
        self.mapa.addAnnotation(punto)

        // Defino el punto de destino para la ruta
        let destino = MKMapItem(placemark: MKPlacemark(coordinate: punto.coordinate, addressDictionary: nil))

        // Agrego el punto en la lista de puntos
        self.listaPuntos.append(destino)
        
        
        // Si no hay punto anterior no creo ruta, si no, marco que hay punto
        if self.existeAlMenosUnPunto {
            // Crea ruta
//            crearRuta(origen: self.ultimoPunto!, destino: destino)
        } else {
            self.existeAlMenosUnPunto = true
        }
        
        // Actualizo el ultimoPunto
        self.ultimoPunto = destino
        
        // Preparo los datos para guardarlos
        let nombreRuta = self.nombreRutaMapa
        let nombrePunto = nombre
        let latitud = destino.placemark.coordinate.latitude
        let longitud = destino.placemark.coordinate.longitude
        
        // Conecto a Core Data
        let delegado = UIApplication.shared.delegate as! AppDelegate
        let contexto = delegado.persistentContainer.viewContext
        // Creo el registro
        let entidadRutas = NSEntityDescription.entity(forEntityName: "Puntos", in: contexto)
        let rutaManagedObject = NSManagedObject(entity: entidadRutas!, insertInto: contexto)
        // Asigno datos
        rutaManagedObject.setValue(nombreRuta, forKey: "nombre_ruta")
        rutaManagedObject.setValue(nombrePunto, forKey: "nombre_punto")
        rutaManagedObject.setValue(String(latitud), forKey: "latitud")
        rutaManagedObject.setValue(String(longitud), forKey: "longitud")
        // Guardar en el contexto
        do {
            try contexto.save()
        } catch {
            print("No se pudo guardar. El error es \(error)")
        }
    }
    
    // Hago la consulta al servidor y creo la ruta
    func crearRuta(origen: MKMapItem, destino: MKMapItem) {
        let solicitudRuta = MKDirectionsRequest()
        solicitudRuta.source = origen
        solicitudRuta.destination = destino
        solicitudRuta.transportType = .walking
        let detalleRuta = MKDirections(request: solicitudRuta)
        detalleRuta.calculate(completionHandler: {
            (respuestaRuta, error) -> Void in
            guard respuestaRuta != nil else {
                if let error = error {
                    print("")
                    print("")
                    print("Error: \(error)")
                }
                return
            }
            // Muestro la ruta en el mapa
            self.mostrarRuta(respuesta: respuestaRuta!)
        })
    }
    
    // Muestro la ruta obtenida en el mapa y la centro si es necesario
    func mostrarRuta(respuesta: MKDirectionsResponse) {
        self.mapa.add(respuesta.routes[0].polyline, level: MKOverlayLevel.aboveRoads)
    }
    
    // MARK: - Funciones de mapView
    // Opciones para dibujar la ruta
    func mapView(_ mapView: MKMapView, rendererFor overlay: MKOverlay) -> MKOverlayRenderer {
        let renderer = MKPolylineRenderer(overlay: overlay)
        renderer.strokeColor = UIColor.blue
        renderer.lineWidth = 4.0
        return renderer
    }
    
    // MARK: - Funciones de locationManager
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        let nuevaUbicacion = self.self.administradorUbicacion.location!
        let distancia = self.ultimaUbicacion!.distance(from: nuevaUbicacion)
        // Actualizar centro de mapa cada 100 metros
        if distancia > 100 {
            self.mapa.setCenter(nuevaUbicacion.coordinate, animated: true)
            self.ultimaUbicacion = nuevaUbicacion
        }
    }
    
    // Se activa por primera vez la lectura de GPS y se guarda el punto inicial
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        if (status == .authorizedAlways) || (status == .authorizedWhenInUse) {
            self.administradorUbicacion.startUpdatingLocation()
            var puntoInicialIncompleto = true
            while puntoInicialIncompleto {
                if self.administradorUbicacion.location != nil {
                    self.puntoInicial = self.administradorUbicacion.location!
                    puntoInicialIncompleto = false
                }
            }
            self.ultimaUbicacion = self.puntoInicial!
            
//            self.ultimoPunto = MKMapItem(placemark: MKPlacemark(coordinate: self.puntoInicial!.coordinate, addressDictionary: nil))
            
            // Guardar primer punto como inicial
//            let chinche = MKPointAnnotation()
//            chinche.title = "Punto Inicial"
//            chinche.coordinate = puntoInicial!.coordinate
//            self.mapa.addAnnotation(chinche)
            
            // Centrar el mapa y definir región
            
            self.mapa.setCenter(self.puntoInicial!.coordinate, animated: true)
            let zona = MKCoordinateSpan(latitudeDelta: 0.008, longitudeDelta: 0.008)
            let regionSeleccionada = MKCoordinateRegion(center: self.puntoInicial!.coordinate, span: zona)
            
            print(regionSeleccionada)
            
            self.mapa.setRegion(regionSeleccionada, animated: false)
        } else {
            self.administradorUbicacion.stopUpdatingLocation()
            self.mapa.showsUserLocation = false
        }
    }
    
    func cagarPuntosGuardados(nombreRutaGuardada: String)  {
        // Conecto a Core Data
        let delegado = UIApplication.shared.delegate as! AppDelegate
        let contexto = delegado.persistentContainer.viewContext
        
        // Reviso si hay datos y los cargo
        let consulta = NSFetchRequest<NSManagedObject>(entityName: "Puntos")
        let nombreConsulta =  nombreRutaGuardada
        consulta.predicate = NSPredicate(format: "nombre_ruta == %@", nombreConsulta)
        do {
            let resultado = try contexto.fetch(consulta)
            let resultadoPuntos = resultado
            if resultadoPuntos.count > 0 {
                print("")
                print("Puntos en la BD: \(resultadoPuntos.count)")
                
                // Control para crear la ruta
                var primerPuntoPuesto = false
                var origenTemp = MKMapItem()
                var destinoTemp = MKMapItem()
                
                // Poner los puntos en el mapa
                for punto in resultadoPuntos {
                    let chinche = MKPointAnnotation()
                    chinche.title = (punto.value(forKey: "nombre_punto") as! String)
                    chinche.coordinate.latitude = Double(punto.value(forKey: "latitud") as! String)!
                    chinche.coordinate.longitude = Double(punto.value(forKey: "longitud") as! String)!
                    self.mapa.addAnnotation(chinche)
                    
                    // Reviso si corresponde crear ruta o no.
                    if primerPuntoPuesto {
                        // Defino el punto de destino para la ruta
                        destinoTemp = MKMapItem(placemark: MKPlacemark(coordinate: chinche.coordinate, addressDictionary: nil))
//                        self.crearRuta(origen: origenTemp, destino: destinoTemp)
                        
                        // Actualizo el origen
                        origenTemp = destinoTemp
                    } else {
                        primerPuntoPuesto = true
                        origenTemp = MKMapItem(placemark: MKPlacemark(coordinate: chinche.coordinate, addressDictionary: nil))
                    }
                    
                    // Guardo el punto en la lista
                    origenTemp.name = chinche.title
                    self.listaPuntos.append(origenTemp)
                }
                // Indico que para el proximo punto puede crear la ruta y actualizo el origen
                self.existeAlMenosUnPunto = true
                self.ultimoPunto = destinoTemp
            } else {
                print("")
                print("No hay puntos.")
            }
        } catch let error as NSError {
            print("No pude recuperar datos, Error: \(error)")
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Poner nombre a la pantalla
        self.navigationItem.title = self.nombreRutaMapa
        
        // Inicializar el mapa
        self.mapa.delegate = self
        self.mapa.mapType = MKMapType.standard
        self.mapa.isZoomEnabled = true
        self.mapa.isRotateEnabled = false
        self.mapa.isScrollEnabled = true
        self.mapa.showsUserLocation = true
        
        // Conectar administrador
        self.administradorUbicacion.delegate = self
        self.administradorUbicacion.desiredAccuracy = kCLLocationAccuracyBest
        self.administradorUbicacion.requestWhenInUseAuthorization()     // Pide autorización para el GPS.
        
        // Cargar puntos guardados si no es nueva ruta
        if self.noEsRutaNueva {
            self.cagarPuntosGuardados(nombreRutaGuardada: self.nombreRutaMapa)
        } else {
            print("El mapa es nuevo, no hay puntos.")
        }
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
