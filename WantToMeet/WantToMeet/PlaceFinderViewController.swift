//
//  PlaceFinderViewController.swift
//  WantToMeet
//
//  Created by Rennan Bruno on 05/02/22.
//

import UIKit
import MapKit

class PlaceFinderViewController: UIViewController {

    @IBOutlet weak var tfCity: UITextField!
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var aiLoading: UIActivityIndicatorView!
    @IBOutlet weak var viLoading: UIView!
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
    }
    
    @IBAction func findCity(_ sender: UIButton) {
    }
    
    @IBAction func close(_ sender: UIButton) {
        dismiss(animated: true, completion: nil)
    }
    
    
}
