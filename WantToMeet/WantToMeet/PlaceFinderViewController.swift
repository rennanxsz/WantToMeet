//
//  PlaceFinderViewController.swift
//  WantToMeet
//
//  Created by Rennan Bruno on 05/02/22.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {
    
    enum PlaceFinderMessageType {
        case error(String)
        case confirmation(String)
    }

    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    var place: Place!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        let gesture = UILongPressGestureRecognizer(target: self, action: #selector(getLocation(_ :)))
        gesture.minimumPressDuration = 2.0
        mapView.addGestureRecognizer(gesture)
    }
    
    @objc func getLocation(_ gesture: UILongPressGestureRecognizer){
        if gesture.state == .began {
            load(show: true)
            let point = gesture.location(in: mapView)
            let coordinate = mapView.convert(point, toCoordinateFrom: mapView)
            let location = CLLocation(latitude: coordinate.latitude, longitude: coordinate.longitude)
            CLGeocoder().reverseGeocodeLocation(location, completionHandler: { (placemarks, error) in
                self.load(show: false)
                if error == nil {
                    if !self.savePlace(with: placemarks?.first) {
                        self.showMessage(type: .error("Não foi encontrado nenhum local com esse nume"))
                    }
                } else {
                    self.showMessage(type: .error("Erro desconhecido"))
                }
            })
        }
    }
    
    @IBAction func findCity(_ sender: UIButton) {
        
        tfCity.resignFirstResponder()
        let address = tfCity.text!
        load(show: true)
        let geoCoder = CLGeocoder()
        geoCoder.geocodeAddressString(address) { (placemarks, error) in
            self.load(show: false)
            if error == nil {
                if !self.savePlace(with: placemarks?.first){
                    self.showMessage(type: .error("Não foi encontrado nenhum local com esse nome"))
                }
            } else {
                self.showMessage(type: .error("Erro desconhecido"))
            }
            
        }
    }
    
    func savePlace(with placemark: CLPlacemark?) -> Bool {
        guard let placemark = placemark, let coordinate = placemark.location?.coordinate else {
            return false
        }
        let name = placemark.name ?? placemark.country ?? "Desconhecido"
        let address = Place.getFormattedAddress(with: placemark)
        place = Place(name: name, latitude: coordinate.latitude, longitude: coordinate.latitude, address: address)
        
        let region = MKCoordinateRegion(center: coordinate, latitudinalMeters: 3500, longitudinalMeters: 3500)
        mapView.setRegion(region, animated: true)
        
        self.showMessage(type: .confirmation(place.name))
        
        return true
    }
    
    func showMessage(type: PlaceFinderMessageType) {
        let title: String, message: String
        var hasConfirmation: Bool = false
        
        switch type {
            case .confirmation(let name):
                title = "Local Encontrado"
                message = "Deseja adicionar \(name) ?"
                hasConfirmation = true
            case .error(let errorMessage):
                title = "Erro"
                message = errorMessage
        }
        //Criando o Alert e configurando os botões
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        //Configurando e adicionando o botão de cancelamento
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        //Configurando e adicionando o botão de confirmação
        if hasConfirmation {
            let confirmAction = UIAlertAction(title: "OK", style: .default, handler: { (action) in
                print("OK!")
            })
            alert.addAction(confirmAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
    func load(show: Bool) {
        viLoading.isHidden = !show
        if show {
            aiLoading.startAnimating()
        
        } else {
            aiLoading.stopAnimating()
        }
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
   
}
