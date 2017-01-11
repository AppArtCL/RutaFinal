//
//  CrearRutaViewController.swift
//  Ruta Final
//
//  Created by Cristian Diaz on 01-01-17.
//  Copyright © 2017 AppArt. All rights reserved.
//

import UIKit
import CoreData

class CrearRutaViewController: UIViewController, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    // MARK: - Variables
    
    
    // MARK: - Conexiones
    @IBOutlet weak var textoNombreRuta: UITextField!
    @IBOutlet weak var textoDescripcionRuta: UITextField!
    @IBOutlet weak var imagenRuta: UIImageView!
    @IBOutlet weak var botonTomarFotoRuta: UIButton!
    @IBOutlet weak var botonAbrirBiblioImagenes: UIButton!
 
    // Función para activar la cámara y tomar la foto
    @IBAction func tomarFotoRuta(_ sender: Any) {
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
            self.botonTomarFotoRuta.isEnabled = false
        }
    }
    
    // Función para seleccionar imagen de la biblioteca
    @IBAction func abrirBilbioImagenes(_ sender: Any) {
        if UIImagePickerController.isSourceTypeAvailable(UIImagePickerControllerSourceType.photoLibrary) {
            let imagePicker = UIImagePickerController()
            imagePicker.delegate = self
            imagePicker.sourceType = UIImagePickerControllerSourceType.photoLibrary;
            imagePicker.allowsEditing = true
            self.present(imagePicker, animated: true, completion: nil)
        } else {
            let aviso = UIAlertController(title: "Importante", message: "No hay biblioteca de imagenes disponible.", preferredStyle: UIAlertControllerStyle.alert)
            aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(aviso, animated: true, completion: nil)
            self.botonAbrirBiblioImagenes.isEnabled = false
        }
    }
    
    // Creo la ruta
    @IBAction func crearRuta(_ sender: Any) {
        var todoOK = true
        var mensaje = ""
        if self.textoNombreRuta.text == "" {
            todoOK = false
            mensaje = "Falta Nombre"
        }
        if textoDescripcionRuta.text == "" {
            todoOK = false
            if mensaje == "" {
                mensaje = "Falta Descripción"
            } else {
                mensaje = mensaje + ", Descripción"
            }
        }
        if imagenRuta.image == nil {
            todoOK = false
            if mensaje == "" {
                mensaje = "Falta Fotografía"
            } else {
                mensaje = mensaje + ", Fotografía"
            }
        }
        if todoOK {
            // Conecto a Core Data
            let delegado = UIApplication.shared.delegate as! AppDelegate
            let contexto = delegado.persistentContainer.viewContext
            
            // Reviso si existe la ruta
            let consulta = NSFetchRequest<NSManagedObject>(entityName: "Rutas")
            let nombreConsulta =  textoNombreRuta.text
            consulta.predicate = NSPredicate(format: "nombre_ruta == %@", nombreConsulta!)
            do {
                let resultado = try contexto.fetch(consulta)
                let resultadoRutas = resultado
                if resultadoRutas.count == 0 {
                    // No existe ruta con ese nombre, lo guardo.
                    
                    // Creo el registro
                    let entidadRutas = NSEntityDescription.entity(forEntityName: "Rutas", in: contexto)
                    let equipoManagedObject = NSManagedObject(entity: entidadRutas!, insertInto: contexto)
                    // Asigno datos
                    equipoManagedObject.setValue(self.textoNombreRuta.text, forKey: "nombre_ruta")
                    equipoManagedObject.setValue(self.textoDescripcionRuta.text, forKey: "descripcion")
                    // Guardar en el contexto
                    do {
                        try contexto.save()
                    } catch {
                        print("No se pudo guardar. El error es \(error)")
                    }
                    
                    // Me voy a la ventana del  mapas
                    performSegue(withIdentifier: "MostrarMapaNuevo", sender: self)
                    
                } else {
                    // Existe una ruta con ese nombre
                    let aviso = UIAlertController(title: "Importante", message: "El nombre de ruta ya existe. Por favor, intente con uno nuevo.", preferredStyle: UIAlertControllerStyle.alert)
                    aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                    self.present(aviso, animated: true, completion: nil)
                }
            } catch let error as NSError {
                print("No pude recuperar datos, Error: \(error)")
                
                // Mensaje de error de conexion a la BD.
                let aviso = UIAlertController(title: "Importante", message: "Error en la conexión a los datos.", preferredStyle: UIAlertControllerStyle.alert)
                aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
                self.present(aviso, animated: true, completion: nil)
            }
        } else {
            // poner mensaje
            mensaje = mensaje + " de la ruta. Complete todos los datos antes de guardar."
            let aviso = UIAlertController(title: "Importante", message: mensaje, preferredStyle: UIAlertControllerStyle.alert)
            aviso.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: nil))
            self.present(aviso, animated: true, completion: nil)
        }
    }
    
    @IBAction func botonTemporal(_ sender: Any) {
        // Conecto a Core Data
        let delegado = UIApplication.shared.delegate as! AppDelegate
        let contexto = delegado.persistentContainer.viewContext
        // Creo el registro
        let entidadRutas = NSEntityDescription.entity(forEntityName: "Rutas", in: contexto)
        let equipoManagedObject = NSManagedObject(entity: entidadRutas!, insertInto: contexto)
        // Asigno datos
        equipoManagedObject.setValue(self.textoNombreRuta.text, forKey: "nombre_ruta")
        equipoManagedObject.setValue(self.textoDescripcionRuta.text, forKey: "descripcion")
        // Guardar en el contexto
        do {
            try contexto.save()
        } catch {
            print("No se pudo guardar. El error es \(error)")
        }
        
        performSegue(withIdentifier: "MostrarMapaNuevo", sender: self)
    }
    
    // MARK: - Funciones
    //Termino de seleccionar o tomar la foto y la muestro
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingImage image: UIImage!, editingInfo: [NSObject: Any]!) {
        imagenRuta.image = image
        self.dismiss(animated: true, completion: nil);
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.textoDescripcionRuta.resignFirstResponder()
        self.textoNombreRuta.resignFirstResponder()
        return true
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Configuro para que desaparezcan al apretar el Enter
        self.textoDescripcionRuta.delegate = self
        self.textoNombreRuta.delegate = self
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "MostrarMapaNuevo" {
            let destinoSegue = segue.destination as! MapaViewController
            destinoSegue.noEsRutaNueva = false
            destinoSegue.nombreRutaMapa = self.textoNombreRuta.text!
        }
    }
 

}
