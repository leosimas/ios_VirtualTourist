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
        
        listPins = TouristManager.sharedInstance().listPins()
    
        loadMap()
    }
    
    func loadMap() {
        mapView.addGestureRecognizer(UILongPressGestureRecognizer(target: self, action: #selector(onMapLongPress)))
        
        if let center = TouristManager.sharedInstance().loadMapCenter() {
            mapView.setRegion(center, animated: false)
        }
        
        mapView.removeAnnotations( mapView.annotations )
        if listPins == nil {
            return
        }
        
        for pin in listPins! {
            let albumPin = AlbumPin()
            albumPin.title = "AlbumPin"
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
        let albumPin = annotation as! AlbumPin
        
        var view = mapView.dequeueReusableAnnotationView(withIdentifier: id) as? MKPinAnnotationView
        if(view == nil) {
            view = MKPinAnnotationView(annotation: albumPin, reuseIdentifier: id)
            view!.animatesDrop = albumPin.animated
            view!.isDraggable = true
            albumPin.animated = false
        } else {
            view!.annotation = albumPin
        }
        
        return view
    }
    
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        let albumPin = view.annotation as! AlbumPin
        displayAlbum(pin: albumPin.pin!)
        mapView.deselectAnnotation(albumPin, animated: false)
    }
    
    func mapView(_ mapView: MKMapView, regionDidChangeAnimated animated: Bool) {
        TouristManager.sharedInstance().saveMapCenter(mapView.region)
    }
    
}

