//
//  EventoTableViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 01-01-17.
//  Copyright © 2017 AppArt. All rights reserved.
//

import UIKit

class EventoTableViewController: UITableViewController {

    // MARK: - Variables
    let direccionJSON = URL(string: "http://plataforma.promexico.gob.mx/sys/gateway.aspx?UID=d3e37eea-b6a1-416e-806d-ae90a5983600&formato=JSON")
    var eventos: NSArray = []
    var codigoError = 0
    var nombreEvento = ""
    var fechaEvento = ""
    var descripcionEvento = ""
    
    // MARK: - Conexiones
    @IBOutlet weak var indicadorActividad: UIActivityIndicatorView!
    
    // MARK: - Obtención de datos
    //Esta funcion es para conseguir la información del JSON
    func llamadaWebService(urlJSON: URL){
        // Bloqueo la pantalla para que no seleccionen nada mientras actualizo
        self.tableView.allowsSelection = false
        
        // Creo la conexion y bajo los datos
        let session = URLSession.shared
        let task = session.dataTask(with: urlJSON, completionHandler: {data, response, error -> Void in
            if(error != nil) {
                // Imprimir descripcion del error si es que error NO esta vacio
                print(error!.localizedDescription as Any)
                self.codigoError = 1
            } else {
                // Paso los datos para ser
                self.traducirJSON(data: data!)
            }
            self.refrescaPantalla()
        })
        task.resume()
    }
    
    //Esta función es para traducir el JSON
    func traducirJSON(data: Data){
        // Traducir a datos capturando errores
        do {
            let jsonEventos = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.mutableContainers)
            let listadoEventos = jsonEventos as! NSDictionary

            // reviso que el listado sea un arreglo
            if listadoEventos["caleventos"] is NSArray {
                // Transformo los datos en un arreglo
                self.eventos = listadoEventos["caleventos"] as! NSArray
                if self.eventos.count == 0 {
                    print("No hay eventos en línea.")
                } else {
                    print(self.eventos.count)
                }
            } else {
                print("No es arreglo")
            }
        } catch {
            print("Existió el error: \(error)")
        }
    }
    
    // Espera al termino de la cola y ejecuta los siguientes
    func refrescaPantalla() {
        DispatchQueue.main.async(execute: {
            self.indicadorActividad.stopAnimating()
            if self.codigoError == 1 {
                let alerta = UIAlertController(title: "Error en la obtención de información", message: "Existe problema con la conexión a Internet.", preferredStyle: UIAlertControllerStyle.alert)
                alerta.addAction(UIAlertAction(title: "OK", style: .default, handler: {(alertAction) -> Void in
                    // Acá puedo ahcer algo su hubo error

                }))
                self.present(alerta, animated: true, completion: nil)
            } else if self.codigoError == 0 {
                self.tableView.reloadData()
                self.tableView.allowsSelection = true
            }
            return
        })
    }
    
    
    // MARK: - Funciones
    override func viewDidLoad() {
        super.viewDidLoad()
        // Pongo en marcha el indicador de actividad
        self.indicadorActividad.startAnimating()
        
        // Bajo los datos de Internet.
        llamadaWebService(urlJSON: direccionJSON!)
        
        // Para mantener la última selección marcada en el TableView.
        self.clearsSelectionOnViewWillAppear = false
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source
    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.eventos.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Celda", for: indexPath)
        let eventoDetalle = self.eventos[indexPath.row] as! NSDictionary
        let nombre = eventoDetalle["FERIA"] as! String
        cell.textLabel?.text = nombre.capitalized
        let fecha = eventoDetalle["FECHA"] as! String
        cell.detailTextLabel?.text = fecha
        return cell
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let eventoDetalle = self.eventos[indexPath.row] as! NSDictionary
        self.nombreEvento = eventoDetalle["FERIA"] as! String
        self.fechaEvento = eventoDetalle["FECHA"] as! String
        self.descripcionEvento = eventoDetalle["CIUDAD_PAIS"] as! String
        performSegue(withIdentifier: "MostrarDetalleEvento", sender: self)
    }
    
    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        if segue.identifier == "MostrarDetalleEvento" {
            let destino = segue.destination as! DetalleEventoViewController
            destino.nombreTemp = self.nombreEvento
            destino.fechaTemp = self.fechaEvento
            destino.descripcionTemp = self.descripcionEvento
        }
    }
}
