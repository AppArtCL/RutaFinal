//
//  DetalleEventoViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 01-01-17.
//  Copyright © 2017 AppArt. All rights reserved.
//

import UIKit

class DetalleEventoViewController: ViewController {

    // MARK: - Variables
    var nombreTemp = ""
    var fechaTemp = ""
    var descripcionTemp = ""
    
    // MARK: - Conexiones
    @IBOutlet weak var etiquetaFechaEvento: UILabel!
    @IBOutlet weak var etiquetaNombreEvento: UILabel!
    @IBOutlet weak var etiquetaDescripcionEvento: UILabel!
    
    // MARK: - Funciones
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Le doy el nombre a las etiquetas.
        etiquetaNombreEvento.text = nombreTemp.capitalized
        etiquetaFechaEvento.text = fechaTemp
        etiquetaDescripcionEvento.text = descripcionTemp

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
