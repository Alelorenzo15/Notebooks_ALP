//
//  PhotographMO+CoreDataClass.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 14/2/21.
//
//

import Foundation
import CoreData

@objc(PhotographMO)
public class PhotographMO: NSManagedObject {

    static func createPhoto(imageData: Data,
                            managedObjectContext: NSManagedObjectContext) -> PhotographMO? {
        let photograph = NSEntityDescription.insertNewObject(forEntityName: "Photograph",
                                                             into: managedObjectContext) as? PhotographMO
        
        photograph?.imageData = imageData
        
        return photograph
    }
    
}
