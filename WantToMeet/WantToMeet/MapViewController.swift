//
//  MapViewController.swift
//  WantToMeet
//
//  Created by Rennan Bruno on 05/02/22.
//

import UIKit
import MapKit

class MapViewController: UIViewController {
    
    enum MapMessageType {
        case routError
        case authorizationWarning
    }
    //MARK - Outlets
    @IBOutlet weak var searchBar: UISearchBar!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var viInfo: UIView!
    @IBOutlet weak var lbName: UILabel!
    @IBOutlet weak var lbAddress: UILabel!
    @IBOutlet weak var loading: UIActivityIndicatorView!
    
    var places: [Place]!
    var poi: [MKAnnotation] = []
    lazy var locationManager = CLLocationManager()
    var btUserLocation: MKUserTrackingButton!
    var selectedAnnotation : PlaceAnnotation?
    override func viewDidLoad() {
        super.viewDidLoad()
        searchBar.isHidden = true
        mapView.mapType = .mutedStandard
        viInfo.isHidden = true
        mapView.delegate = self
        locationManager.delegate = self
        
        if places.count == 1 {
            title = places[0].name
        }else {
            title = "Meus Lugares"
        }
        
        for place in places {
            addToMap(place)
        }
        
        configureLocationButton()
        
        showPlaces()
        requestUserLocationAuthorization()
    }
    
    func configureLocationButton() {
        btUserLocation = MKUserTrackingButton(mapView: mapView)
        btUserLocation.backgroundColor = .white
        btUserLocation.frame.origin.x = 10
        btUserLocation.frame.origin.y = 10
        btUserLocation.layer.cornerRadius = 5
        btUserLocation.layer.borderWidth = 1
        btUserLocation.layer.borderColor = UIColor(named: "main")?.cgColor
        
    }
    
    func requestUserLocationAuthorization() {
        if CLLocationManager.locationServicesEnabled() {
            switch CLLocationManager.authorizationStatus() {
                case .authorizedAlways, .authorizedWhenInUse:
                mapView.addSubview(btUserLocation)
                case .denied:
                    showMessage(type: .authorizationWarning)
                case .notDetermined:
                    locationManager.requestWhenInUseAuthorization()
                case .restricted:
                    break
            }
        } else {
            //Não dá
        }
    }
    
    func addToMap(_ place: Place){
        let annotation = PlaceAnnotation(coordinate: place.coordinate, type: .place)
        annotation.title = place.name
        annotation.address = place.address
        mapView.addAnnotation(annotation)
    }
    
    func showPlaces() {
        mapView.showAnnotations(mapView.annotations, animated: true)
    }
    
    func showInfo() {
        lbName.text = selectedAnnotation!.title
        lbAddress.text = selectedAnnotation!.address
        viInfo.isHidden = false
    }
    
    @IBAction func showRoute(_ sender: UIButton) {
    }
    
    @IBAction func showSearchBar(_ sender: UIBarButtonItem) {
        searchBar.resignFirstResponder()
        searchBar.isHidden = !searchBar.isHidden
    }
    
    func showMessage(type: MapMessageType) {
        let title = type == .authorizationWarning ? "Aviso" : "Erro"
        let message = type == .authorizationWarning ? "Para usar os recursos de localicação do app, você precisa permitir o uso na tela de Ajustes" : "Não foi possível encontrar está rota"
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancelar", style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        if type == .authorizationWarning {
            let confirmAction = UIAlertAction(title: "ir para Ajustes", style: .default, handler: {
                (action) in
                
                if let appSettings = URL(string: UIApplication.openSettingsURLString ) {
                    UIApplication.shared.open(appSettings, options: [:], completionHandler: nil)
                }
            })
            alert.addAction(confirmAction)
        }
        present(alert, animated: true, completion: nil)
    }
    
}

extension MapViewController: MKMapViewDelegate {
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if !(annotation is PlaceAnnotation) {
            return nil
        }
        let type = (annotation as! PlaceAnnotation).type
        let identifier = "\(type)"
        var annotationView = mapView.dequeueReusableAnnotationView(withIdentifier: identifier) as? MKMarkerAnnotationView
        if annotationView == nil {
            annotationView = MKMarkerAnnotationView(annotation: annotation, reuseIdentifier: identifier)
        }
        annotationView?.annotation = annotation
        annotationView?.canShowCallout = true
        annotationView?.markerTintColor = type == .place ? UIColor(named: "main") : UIColor(named: "poi")
        annotationView?.glyphImage = type == .place ? UIImage(named: "placeGlyph.png") : UIImage(named: "poiGlyph.png")
        annotationView?.displayPriority = type == .place ? .required : .defaultHigh
        
        return annotationView
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        
        let camera = MKMapCamera()
        camera.centerCoordinate = view.annotation!.coordinate
        camera.pitch = 80
        camera.altitude = 100
        mapView.setCamera(camera, animated: true)
        
        selectedAnnotation = (view.annotation as! PlaceAnnotation)
        showInfo()
    }
    
}

extension MapViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.isHidden = true
        searchBar.resignFirstResponder()
        loading.startAnimating()
        
        let request = MKLocalSearch.Request()
        request.naturalLanguageQuery = searchBar.text
        request.region = mapView.region
        let search = MKLocalSearch(request: request)
        search.start { (response, error) in
            if error == nil {
                guard let response = response else {
                    self.loading.stopAnimating()
                    return
                }
                
                self.mapView.removeAnnotations(self.poi)
                self.poi.removeAll()
                for item in response.mapItems {
                    let annotation = PlaceAnnotation(coordinate: item.placemark.coordinate, type: .poi)
                    annotation.title = item.name
                    annotation.subtitle = item.phoneNumber
                    annotation.address = Place.getFormattedAddress(with: item.placemark)
                    self.poi.append(annotation)
                }
                
                self.mapView.addAnnotations(self.poi)
                self.mapView.showAnnotations(self.poi, animated: true)
                
            }
            self.loading.stopAnimating()
        }
        
    }
}

extension MapViewController: CLLocationManagerDelegate {
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        switch status{
        case .authorizedAlways, .authorizedWhenInUse:
            mapView.showsUserLocation = true
            mapView.addSubview(btUserLocation)
            locationManager.startUpdatingLocation()
        default :
            break
        }
        
    }
    
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        print(locations.last!)
    }
}

