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
    
    func saveMapCenter(_ region : MKCoordinateRegion) {
        UserDefaults.standard.set(region.center.latitude, forKey: Constants.UserDefaults.MapCenterLatitude)
        UserDefaults.standard.set(region.center.longitude, forKey: Constants.UserDefaults.MapCenterLongitude)
        UserDefaults.standard.set(region.span.latitudeDelta, forKey: Constants.UserDefaults.MapCenterLatitudeDelta)
        UserDefaults.standard.set(region.span.longitudeDelta, forKey: Constants.UserDefaults.MapCenterLongitudeDelta)
    }
    
    func loadMapCenter() -> MKCoordinateRegion? {
        guard let latitude = UserDefaults.standard.object(forKey: Constants.UserDefaults.MapCenterLatitude) as? Double, let longitude = UserDefaults.standard.object(forKey: Constants.UserDefaults.MapCenterLongitude) as? Double, let latitudeDelta = UserDefaults.standard.object(forKey: Constants.UserDefaults.MapCenterLatitudeDelta) as? Double, let longitudeDelta = UserDefaults.standard.object(forKey: Constants.UserDefaults.MapCenterLongitudeDelta) as? Double else {
            return nil
        }
        
        let coordinate = CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
        let span = MKCoordinateSpan(latitudeDelta: latitudeDelta, longitudeDelta: longitudeDelta)
        return MKCoordinateRegion(center: coordinate, span: span)
    }
    
    func addPin(coordinate : CLLocationCoordinate2D) -> Pin {
        let pin = Pin(latitude: coordinate.latitude, longitude: coordinate.longitude, context: stack.context)
        stack.save()
        return pin
    }
    
    func change(pin : Pin, coordinate : CLLocationCoordinate2D) {
        pin.latitude = coordinate.latitude
        pin.longitude = coordinate.longitude
        pin.photos = nil
        stack.save()
        
        downloadAlbum(for: pin) { (photos, errorMessage) in
            print("change pin \(pin), errorMessage = \(errorMessage)")
        }
    }
    
    func addPhotos(for pin : Pin, with jsonArray : [[String:AnyObject?]]) throws -> [Photo] {
        var photos : [Photo] = []
        
        for json in jsonArray {
            guard let id = json[Constants.FlickrResponseKeys.Id] as? String, let url = json[Constants.FlickrResponseKeys.MediumURL] as? String else {
                throw Exception.ParseJson(Constants.ErrorMessages.ParseJson)
            }
            
            stack.context.performAndWait {
                let photo = Photo(pin : pin, id : id, url: url, context: self.stack.context)
                photos.append( photo )
                
                self.download(photo: photo)
            }
        }
        stack.save()
        
        return photos
    }
    
    func createPinFetchController(pin : Pin) -> NSFetchedResultsController<NSFetchRequestResult> {
        let fr = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        fr.sortDescriptors = [NSSortDescriptor(key: "id", ascending: false)]
        fr.predicate = NSPredicate(format: "pin = %@", argumentArray: [pin])
        
        return NSFetchedResultsController(fetchRequest: fr, managedObjectContext:stack.context, sectionNameKeyPath: nil, cacheName: nil)
        
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
//        pin.photos = nil
//        stack.save()
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Photo")
        let deleteRequest = NSBatchDeleteRequest( fetchRequest: fetchRequest)
        fetchRequest.predicate = NSPredicate(format: "pin = %@", pin)
        
        do{
            try stack.context.execute(deleteRequest)
            stack.save()
        }catch {
            print("deletePhotos error: \(error)")
        }
    }
    
    func delete(photo : Photo) {
        stack.context.delete(photo)
        stack.save()
    }
    
    func downloadAlbum(for pin : Pin, completion : @escaping( ([Photo]?, String?)->Void )) {
        let coordinate = CLLocationCoordinate2D(latitude: pin.latitude, longitude: pin.longitude)
        
        FlickrClient.sharedInstance().requestPhotosFor(coordinate: coordinate) { (photosJsonArray, errorMessage) in
            if errorMessage != nil  {
                completion(nil, errorMessage)
                return
            }
            
            print("\(String(describing: photosJsonArray))")
            
            do {
                let photos = try self.addPhotos(for: pin, with: photosJsonArray!)
                completion(photos, nil)
            } catch Exception.ParseJson(let errorMessage) {
                completion(nil, errorMessage)
            } catch {
                completion(nil, "unknown error")
            }
            
        }
    }
    
    func download(photo : Photo) {
        let url = URL(string: photo.url!)!
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            if error != nil || data == nil {
                print("download photo \(url) error : \(String(describing: error))")
                return
            }
            
            self.stack.context.performAndWait {
                photo.image = data! as NSData
                self.stack.save()
            }
        }
        task.resume()
    }
    
    enum Exception : Error {
        case ParseJson(String)
    }
    
}
