//
//  QRViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 31-12-16.
//  Copyright © 2016 AppArt. All rights reserved.
//

import UIKit
import AVFoundation

class QRViewController: ViewController, AVCaptureMetadataOutputObjectsDelegate {
    
    // MARK: - Variables
    var sesion: AVCaptureSession?
    var videoPreview: AVCaptureVideoPreviewLayer?
    var cuadroQR: UIView?
    var direccionWeb = ""
    var camaraLista = false

    // MARK: - Funciones
    override func viewDidAppear(_ animated: Bool) {
        if self.camaraLista {
            self.sesion?.startRunning()
            self.cuadroQR?.frame = CGRect.zero
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Scanner Código QR"
        // Inicializar la captura
        // Conectar dispositivo
        if let dispositivoCaptura =  AVCaptureDevice.defaultDevice(withMediaType: AVMediaTypeVideo) {
            // Comenzar a capturar
            do {
                let video = try AVCaptureDeviceInput(device: dispositivoCaptura)
                sesion = AVCaptureSession()
                sesion?.addInput(video)
                // Crear receptor de metadatos y conectarlo con la sesión
                let metaDatos = AVCaptureMetadataOutput()
                sesion?.addOutput(metaDatos)
                // Conectar a la cola principal y que sea QR Code
                metaDatos.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metaDatos.metadataObjectTypes = [AVMetadataObjectTypeQRCode]
                // Configuro el video y lo conecto a la sesion
                videoPreview = AVCaptureVideoPreviewLayer(session: sesion!)
                videoPreview?.videoGravity = AVLayerVideoGravityResizeAspectFill
                videoPreview?.frame = view.layer.bounds
                view.layer.addSublayer(videoPreview!)
                // Configuro el cuadro QR
                cuadroQR = UIView()
                cuadroQR?.layer.borderWidth = 3
                cuadroQR?.layer.borderColor = UIColor.blue.cgColor
                view.addSubview(cuadroQR!)
                // Empieza la captura
                self.camaraLista = true
                sesion?.startRunning()
            }
            catch {
                
            }
        } else {
            let aviso = UIAlertController(title: "Importante", message: "No hay cámara disponible para leer Código QR. Debe usar en dispositivo.", preferredStyle: UIAlertControllerStyle.alert)
            aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(aviso, animated: true, completion: nil)
        }
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func captureOutput(_ captureOutput: AVCaptureOutput!, didOutputMetadataObjects metadataObjects: [Any]!, from connection: AVCaptureConnection!) {
        // El cuadroQR queda de tamaño 0
        cuadroQR?.frame = CGRect.zero
        // Reviso si vienen los datos en los metadatos
        if (metadataObjects == nil || metadataObjects.count == 0) {
            return
        }
        // Si tenemos un dato, tengo que verificar que sea QR Code
        let metadatoCapturado = metadataObjects[0] as! AVMetadataMachineReadableCodeObject
        if (metadatoCapturado.type == AVMetadataObjectTypeQRCode) {
            let objetoEncontrado = videoPreview?.transformedMetadataObject(for: metadatoCapturado as AVMetadataMachineReadableCodeObject) as! AVMetadataMachineReadableCodeObject
            // Le doy al cuadroQR el tamaño del objetoEncontrado
            cuadroQR?.frame = objetoEncontrado.bounds
            // Reviso si el metadatoCapturado no es vacío y guardo la dirección
            if objetoEncontrado.stringValue != nil {
                self.direccionWeb = objetoEncontrado.stringValue
                //reviso que la dirección se pueda crear
                if NSURL(string: self.direccionWeb) != nil {
                    performSegue(withIdentifier: "MuestraWeb", sender: self)
                } else {
                    let avisoDireccion = UIAlertController(title: "Importante", message: "El QR Code no contiene una dirección web. Intente con otro.", preferredStyle: UIAlertControllerStyle.alert)
                    avisoDireccion.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(avisoDireccion, animated: true, completion: nil)
                }
            }
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        self.sesion?.stopRunning()
        if segue.identifier == "MuestraWeb" {
            let detalleWeb = segue.destination as! WebViewController
            detalleWeb.direccionWeb = self.direccionWeb
        }
    }
}
