//
//  NotebookMO.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 8/2/21.
//

import Foundation
import CoreData

public class NotebookMO: NSManagedObject {
    
    public override func awakeFromInsert() {
        super.awakeFromInsert()
        
        print("se creo un notebook")
        
    }
    
    public override func didTurnIntoFault() {
        super.didTurnIntoFault()
        
        print("se creo un fault")
    }
    
    @discardableResult
    static func createNotebook(createdAt: Date,
                               title: String,
                               in managedObjectContext: NSManagedObjectContext) -> NotebookMO? {
        let notebook = NSEntityDescription.insertNewObject(forEntityName: "Notebook",
                                                           into: managedObjectContext) as? NotebookMO
        notebook?.createdAt = createdAt
        notebook?.title = title
        return notebook
    }
}
