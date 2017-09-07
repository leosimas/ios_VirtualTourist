//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 07/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import UIKit
import MapKit

class PhotoAlbumViewController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    var pin : Pin?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pin = pin else {
            fatalError("PhotoAlbumViewController must have a Pin")
        }
        
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: false)
    }
    
    @IBAction func onNewCollection(_ sender: Any) {
    }
    
}
