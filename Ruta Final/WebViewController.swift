//
//  WebViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 31-12-16.
//  Copyright © 2016 AppArt. All rights reserved.
//

import UIKit

class WebViewController: ViewController, UIWebViewDelegate {

    // MARK: - Variables
    var direccionWeb: String?

    // MARK: - Conexiones
    @IBOutlet weak var visorWeb: UIWebView!
    
    // MARK: - Funciones
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.visorWeb.delegate = self
        
        print(self.direccionWeb!)
        let urlDireccion = URL(string: self.direccionWeb!)
        let cargaPagina = URLRequest(url: urlDireccion!)
        visorWeb.loadRequest(cargaPagina)
        let botonAbrir = UIBarButtonItem(title: "Abrir en browser", style: .plain, target: self, action: #selector(WebViewController.abrirEnSafari))
        self.navigationItem.setRightBarButton(botonAbrir, animated: true)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    // Abre en Safari la dirección del QR
    func abrirEnSafari(){
        UIApplication.shared.open(URL(string: direccionWeb!)!, completionHandler: nil)
    }

    // Revisa si cargó bien
    func webView(_ webView: UIWebView, didFailLoadWithError error: Error) {
        let avisoDireccion = UIAlertController(title: "Importante", message: "El QR Code no contiene una dirección web o el disposotivo no está conectado a la red.", preferredStyle: UIAlertControllerStyle.alert)
        avisoDireccion.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
        self.present(avisoDireccion, animated: true, completion: nil)
    }
}
