//
//  TouristManager.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 07/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import MapKit
import CoreData

class TouristManager {
    
    let stack = CoreDataStack(modelName: "Virtual_Tourist")!
    
    private static var shared : TouristManager?
    
    static func sharedInstance() -> TouristManager {
        if shared == nil {
            shared = TouristManager()
        }
        return shared!
    }
    
    func addPin(coordinate : CLLocationCoordinate2D) -> Pin {
        let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
        stack.save()
        return pin
    }
    
    func addPhotos(for pin : Pin, with urls : [String]) -> [Photo] {
        var photos : [Photo] = []
        
        for url in urls {
            let photo = Photo(pin : pin, url: url, context: stack.context)
            photos.append( photo )
            
            self.download(photo: photo)
        }
        stack.save()
        
        return photos
    }
    
    func listPins() -> [Pin] {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Pin")

        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "latitude", ascending: true),
            NSSortDescriptor(key: "longitude", ascending: true)
        ]
        
        do {
            return try stack.context.fetch(fetchRequest) as! [Pin]
        } catch {
            print("listPins error: \(error)")
            return []
        }
    }
    
    func deletePhotos(of pin : Pin) {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
        
        do{
            try stack.context.execute(deleteRequest)
        }catch {
            print("deletePhotos error: \(error)")
        }
    }
    
    func downloadAlbum(for pin : Pin, completion : @escaping( ([Photo]?, String?)->Void )) {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        FlickrClient.sharedInstance().requestPhotosFor(coordinate: coordinate) { (photosJsonArray, errorMessage) in
            if errorMessage != nil  {
                completion(nil, errorMessage)
                return
            }
            
            print("\(String(describing: photosJsonArray))")
            
            var urls : [String] = []
            
            for photoJson in photosJsonArray! {
                guard let urlString = photoJson[Constants.FlickrResponseKeys.MediumURL] as? String else {
                    completion(nil, Constants.ErrorMessages.ParseJson)
                    return
                }
                
                urls.append( urlString )
            }
            
            let photos = self.addPhotos(for: pin, with: urls)
            completion(photos, nil)
        }
    }
    
    func download(photo : Photo) {
        let url = URL(string: photo.url!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || data == nil {
                print("download photo \(url) error : \(String(describing: error))")
                return
            }
            
            photo.image = data! as NSData
            self.stack.save()
        }
        task.resume()
    }
    
}
