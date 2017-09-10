//
//  PhotoAlbumViewController.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 07/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import UIKit
import MapKit
import CoreData

class PhotoAlbumViewController : UIViewController {
    
    @IBOutlet weak var mapView: MKMapView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    @IBOutlet weak var newCollectionButton: UIBarButtonItem!
    @IBOutlet weak var flowLayout: UICollectionViewFlowLayout!
    
    var pin : Pin?
    fileprivate var fetchController : NSFetchedResultsController<NSFetchRequestResult>?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let pin = pin else {
            fatalError("PhotoAlbumViewController must have a Pin")
        }
        
        //
        let space:CGFloat = 3.0
        let dimension  = (view.frame.size.width - (2 * space)) / 3.0
        flowLayout.minimumInteritemSpacing = space
        flowLayout.minimumLineSpacing = space
        flowLayout.itemSize = CGSize(width: dimension, height: dimension)
        
        // selected pin
        let annotation = MKPointAnnotation()
        annotation.coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        mapView.addAnnotation(annotation)
        mapView.showAnnotations(mapView.annotations, animated: false)
        
        configureFetchController()
        
        if pin.photos == nil || pin.photos!.count == 0 {
            newCollection()
        } else {
            executeSearch()
            setEnableUI(true)
        }
        
    }
    
    private func configureFetchController() {
        fetchController = TouristManager.sharedInstance().createPinFetchController(pin: pin!)
        fetchController!.delegate = self
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
                self.executeSearch()
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

// Mark: UICollectionViewDataSource
extension PhotoAlbumViewController : UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let fetch = fetchController, let sections = fetch.sections else {
            return 0
        }
        
        return sections[section].numberOfObjects
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let photo = fetchController!.object(at: indexPath) as! Photo
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PhotoViewCell", for: indexPath) as! PhotoViewCell
        cell.setupCellWith(photo)
        return cell
    }
    
}

// Mark: fetch results
extension PhotoAlbumViewController : NSFetchedResultsControllerDelegate {
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        collectionView.reloadData()
    }
    
    func executeSearch() {
        if let fc = fetchController {
            do {
                try fc.performFetch()
            } catch let e as NSError {
                print("Error while trying to perform a search: \n\(e)\n\(String(describing: fetchController))")
            }
        }
    }
    
}
