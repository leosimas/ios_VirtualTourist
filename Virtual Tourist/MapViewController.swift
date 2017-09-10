//
//  MapViewController.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 05/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class MapViewController: UIViewController {

    @IBOutlet weak var mapView : MKMapView!
    
    fileprivate var listPins : [Pin]?
    
    @IBOutlet weak var constraintHideCollection: NSLayoutConstraint!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onMapLongPress)))
        
        listPins = TouristManager.sharedInstance().listPins()
    
        fillMap()
    }
    
    func fillMap() {
        mapView.removeAnnotations( mapView.annotations )
        if listPins == nil {
            return
        }
        
        for pin in listPins! {
            let albumPin = AlbumPin()
            albumPin.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
            albumPin.pin = pin
            
            mapView.addAnnotation( albumPin )
        }
    }
    
    func onMapLongPress(gesture : UIGestureRecognizer) {
        if gesture.state != .began {
            return
        }
        
        let viewLocation = gesture.location(in: mapView)
        let coordinate = mapView.convert(viewLocation, toCoordinateFrom: mapView)
        
        let albumPin = AlbumPin()
        albumPin.coordinate = coordinate
        albumPin.animated = true
        
        mapView.addAnnotation(albumPin)
        
        albumPin.pin = TouristManager.sharedInstance().addPin(coordinate: coordinate)
    }
    
    func displayAlbum(pin : Pin) {
        let photoAlbumVC = storyboard!.instantiateViewController(withIdentifier: "PhotoAlbumViewController") as! PhotoAlbumViewController
        photoAlbumVC.pin = pin
        navigationController!.pushViewController(photoAlbumVC, animated: true)
    }

}

// Mark: MapView delegate
extension MapViewController : MKMapViewDelegate {
    
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        let id = "pinView"
        
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if(view == nil) {
            let albumPin = annotation as! AlbumPin
            view = MKPinAnnotationView(annotation: albumPin, reuseIdentifier: id)
            view!.animatesDrop = albumPin.animated
            albumPin.animated = false
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let albumPin = view.annotation as! AlbumPin
        displayAlbum(pin: albumPin.pin!)
        mapView.deselectAnnotation(albumPin, animated: false)
    }
    
}

