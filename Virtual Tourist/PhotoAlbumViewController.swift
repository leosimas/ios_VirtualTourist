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
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    
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
        
        if pin.photos == nil || pin.photos!.count == 0 {
            newCollection()
        }
    }
    
    private func newCollection()  {
        let pin = self.pin!
        
        if pin.photos != nil && pin.photos!.count > 0 {
            TouristManager.sharedInstance().deletePhotos(of: pin)
        }
        
        setEnableUI(false)
        
        TouristManager.sharedInstance().downloadAlbum(for: pin) { (photos, errorMessage) in
            if errorMessage != nil {
                Dialogs.alert(controller: self, title: "Error", message: errorMessage!, completion: { (action) in
                    self.setEnableUI(true)
                })
                return
            }
            
            DispatchQueue.main.async {
                self.setEnableUI(true)
            }
            
        }
    }
    
    private func setEnableUI(_ enable : Bool) {
        newCollectionButton.isEnabled = enable
        loadingView.isHidden = enable
    }
    
    @IBAction func onNewCollection(_ sender: Any) {
        newCollection()
    }
    
}
