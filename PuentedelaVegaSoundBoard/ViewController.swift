//
//  ViewController.swift
//  PuentedelaVegaSoundBoard
//
//  Created by Alexander Puente de la Vega on 7/10/24.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {

    
    
    @IBOutlet weak var tablaGrabaciones: UITableView!
    
    var grabaciones: [Grabacion] = []
    var reproducirAudio: AVAudioPlayer?

        override func viewDidLoad() {
            super.viewDidLoad()
            
            // Configurar el delegate y dataSource de la tabla
            tablaGrabaciones.dataSource = self
            tablaGrabaciones.delegate = self
        }

        func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return grabaciones.count
        }

        func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
            let cell = UITableViewCell()
                
                // Configurar la celda con la grabación correspondiente
                let grabacion = grabaciones[indexPath.row]
                cell.textLabel?.text = "\(grabacion.nombre!) - \(formatearDuracion(grabacion.duracion))"
                
                return cell
        }
    
    func formatearDuracion(_ duracion: Int32) -> String {
        let minutos = duracion / 60
        let segundos = duracion % 60
        return String(format: "%02d:%02d", minutos, segundos)
    }
        
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let grabacion = grabaciones[indexPath.row]

        do {
            reproducirAudio = try AVAudioPlayer(data: grabacion.audio! as Data)
            reproducirAudio?.play()
        } catch {
            // Manejo de errores vacío
        }

        tablaGrabaciones.deselectRow(at: indexPath, animated: true)
    }
    
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            let grabacion = grabaciones[indexPath.row]
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            
            context.delete(grabacion)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            
            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            } catch {
                // Manejo de errores vacío
            }
        }
    }

    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
            let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
            do {
                grabaciones = try context.fetch(Grabacion.fetchRequest())
                tablaGrabaciones.reloadData()
            } catch {
                // Manejo de errores vacío
            }
        
        
    }


}

