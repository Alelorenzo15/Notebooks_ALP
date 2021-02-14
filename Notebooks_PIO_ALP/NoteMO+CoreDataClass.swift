//
//  NoteMO+CoreDataClass.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 10/2/21.
//
//

import Foundation
import CoreData

@objc(NoteMO)
public class NoteMO: NSManagedObject {

    @discardableResult
    static func createNote(managedObjectContext: NSManagedObjectContext,
                           notebook: NotebookMO,
                           title: String,
                           createdAt: Date) -> NoteMO? {
        let note = NSEntityDescription.insertNewObject(forEntityName: "Note",
                                                       into: managedObjectContext) as? NoteMO
    
        note?.title = title
        note?.createdAt = createdAt
        note?.notebook = notebook
        
        return note
    }
}
