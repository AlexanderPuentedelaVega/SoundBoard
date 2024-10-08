//
//  SoundViewController.swift
//  PuentedelaVegaSoundBoard
//
//  Created by Alexander Puente de la Vega on 7/10/24.
//

import UIKit
import AVFoundation

class SoundViewController: UIViewController {
    
    @IBOutlet weak var grabarButton: UIButton!
    @IBOutlet weak var reproducirButton: UIButton!
    @IBOutlet weak var nombreTextField: UITextField!
    @IBOutlet weak var agregarButton: UIButton!
    
    @IBOutlet weak var volumenSlider: UISlider!
    @IBOutlet weak var tiempoLabel: UILabel!
    
    var grabarAudio: AVAudioRecorder?
    var reproducirAudio:AVAudioPlayer?
    var audioURL:URL?
    var timer: Timer?
    var tiempoGrabacion: Int = 0
    @NSManaged var duracion: Int32
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configurarGrabacion()
        reproducirButton.isEnabled = false
        agregarButton.isEnabled = false
        volumenSlider.value = 0.5
        reproducirAudio?.volume = volumenSlider.value

        // Do any additional setup after loading the view.
    }
    
    
    @IBAction func volumenSliderChanged(_ sender: UISlider) {
        if let audioPlayer = reproducirAudio {
                audioPlayer.volume = sender.value // Ajustar el volumen según el valor del slider
            }
    }
    
    
    @IBAction func grabarTapped(_ sender: Any) {
        if grabarAudio!.isRecording {
                grabarAudio?.stop()
                timer?.invalidate() // Detener el timer
                grabarButton.setTitle("GRABAR", for: .normal)
                reproducirButton.isEnabled = true
                agregarButton.isEnabled = true
            } else {
                grabarAudio?.record()
                tiempoGrabacion = 0 // Reiniciar tiempo
                tiempoLabel.text = "00:00" // Reiniciar label
                grabarButton.setTitle("DETENER", for: .normal)
                reproducirButton.isEnabled = false
                
                // Iniciar el timer
                timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(actualizarTiempo), userInfo: nil, repeats: true)
            }
    }
    
    @objc func actualizarTiempo() {
        tiempoGrabacion += 1
        let minutos = tiempoGrabacion / 60
        let segundos = tiempoGrabacion % 60
        tiempoLabel.text = String(format: "%02d:%02d", minutos, segundos)
    }
    
    @IBAction func reproducirTapped(_ sender: Any) {
        do {
                // Verificar si hay una grabación disponible en la URL y reproducir
                reproducirAudio = try AVAudioPlayer(contentsOf: audioURL!)
            reproducirAudio?.volume = volumenSlider.value // Establecer el volumen del audio player

                reproducirAudio?.play()
                print("Reproduciendo el audio grabado.")
            } catch let error as NSError {
                print("Error al reproducir el audio: \(error.localizedDescription)")
            }
    }
    
    @IBAction func agregarTapped(_ sender: Any) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        
        let grabacion = Grabacion(context: context)
        grabacion.nombre = nombreTextField.text
        grabacion.duracion = Int32(tiempoGrabacion) // Guarda la duración grabada

        if let audioData = NSData(contentsOf: audioURL!) as Data? {
            grabacion.audio = audioData
        }
             
        (UIApplication.shared.delegate as! AppDelegate).saveContext()
        navigationController!.popViewController(animated: true)
        
    }
    
    func configurarGrabacion() {
        do {
            // Creando sesión de audio
            let session = AVAudioSession.sharedInstance()
            try session.setCategory(.playAndRecord, mode: .default, options: [])
            try session.overrideOutputAudioPort(.speaker)
            try session.setActive(true)
            
            // Creando dirección para el archivo de audio
            let basePath: String = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true).first!
            let pathComponents = [basePath, "audio.m4a"]
            audioURL = NSURL.fileURL(withPathComponents: pathComponents)!
            
            // Impresión de ruta donde se guardan los archivos
            print("**********")
            print(audioURL!)
            print("**********")
            
            // Crear opciones para el grabador de audio
            var settings: [String: AnyObject] = [:]
            settings[AVFormatIDKey] = Int(kAudioFormatMPEG4AAC) as AnyObject?
            settings[AVSampleRateKey] = 44100.0 as AnyObject?
            settings[AVNumberOfChannelsKey] = 2 as AnyObject?
            
            // Crear el objeto de grabación de audio
            grabarAudio = try AVAudioRecorder(url: audioURL!, settings: settings)
            grabarAudio!.prepareToRecord()
        } catch let error as NSError {
            print("Error al configurar la grabación: \(error.localizedDescription)")
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
}
