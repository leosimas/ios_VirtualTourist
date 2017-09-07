//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 05/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import UIKit
import MapKit

class MapViewController: UIViewController {

    @IBOutlet weak var mapView : MKMapView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onMapLongPress)))
    }
    
    func onMapLongPress(gesture : UIGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        
        let viewLocation = gesture.location(in: mapView)
        let coordinate = mapView.convert(viewLocation, toCoordinateFrom: mapView)
        
        let pin = MKPointAnnotation()
        pin.coordinate = coordinate
        
        mapView.addAnnotation(pin)
    }

}

extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pinView"
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if(view == nil) {
            view = MKPinAnnotationView(annotation: annotation, reuseIdentifier: id)
            view!.animatesDrop = true
        }
        return view
    }
    
}

