//
//  RutaTableViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 01-01-17.
//  Copyright © 2017 AppArt. All rights reserved.
//

import UIKit
import CoreData

class RutaTableViewController: UITableViewController {
    // MARK: - Variables
    var rutas = [NSManagedObject]()
    var managedObjectContext: NSManagedObjectContext? = nil
    var nombreRutaSeleccionada = ""
    
    // MARK: - Conexiones
    @IBAction func crearNuevaRuta(_ sender: Any) {
        performSegue(withIdentifier: "CrearNuevaRuta", sender: self)
    }
    
    // MARK: - Funciones
    func cargarRutasExistentes() {
        // Conecto a Core Data
        let delegado = UIApplication.shared.delegate as! AppDelegate
        let contexto = delegado.persistentContainer.viewContext
        // Reviso si hay datos y los cargo
        let consulta = NSFetchRequest<NSManagedObject>(entityName: "Rutas")
        do {
            let resultado = try contexto.fetch(consulta)
            let resultadoRutas = resultado
            if resultadoRutas.count > 0 {
                print("")
                print("Rutas en la BD: \(resultadoRutas.count)")
                // Cargar datos en arreglo.
                self.rutas = resultadoRutas
                self.tableView.reloadData()
            } else {
                print("")
                print("No hay rutas.")
            }
        } catch let error as NSError {
            print("No pude recuperar datos, Error: \(error)")
        }
    }
    
    
    override func viewWillAppear(_ animated: Bool) {
        cargarRutasExistentes()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Quedará marcada la última ruta seleccionada
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
        return self.rutas.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Celda", for: indexPath)
        let detalleRuta = rutas[(indexPath as NSIndexPath).row]
        cell.textLabel?.text = detalleRuta.value(forKey: "nombre_ruta") as? String
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let detalleRuta = rutas[(indexPath as NSIndexPath).row]
        self.nombreRutaSeleccionada = (detalleRuta.value(forKey: "nombre_ruta") as? String)!
        performSegue(withIdentifier: "MostrarMapa", sender: self)
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
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MostrarMapa" {
            let destino = segue.destination as! MapaViewController
            destino.nombreRutaMapa = self.nombreRutaSeleccionada
        }
    }
}
