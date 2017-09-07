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
    
}
