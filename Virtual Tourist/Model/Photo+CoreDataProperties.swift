//
//  Photo+CoreDataProperties.swift
//  Virtual Tourist
//
//  Created by SoSucesso on 07/09/17.
//  Copyright © 2017 Leonardo Simas. All rights reserved.
//

import Foundation
import CoreData


extension Photo {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Photo> {
        return NSFetchRequest<Photo>(entityName: "Photo")
    }

    @NSManaged public var id: String?
    @NSManaged public var image: NSData?
    @NSManaged public var url: String?
    @NSManaged public var pin: Pin?

}
