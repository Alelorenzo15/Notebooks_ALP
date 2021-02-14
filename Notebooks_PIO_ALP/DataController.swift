//
//  DataController.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 6/2/21.
//
import Foundation
import CoreData
import UIKit

class DataController: NSObject {
    let persistentContainer: NSPersistentContainer
    

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    
    
    @discardableResult
    init(modelName: String, optionalStoreName: String?, completionHandler: (@escaping (NSPersistentContainer?) -> ())) {
        if let optionalStoreName = optionalStoreName {
            let managedObjectModel = Self.manageObjectModel(with: modelName)
            self.persistentContainer = NSPersistentContainer(name: optionalStoreName,
                                                             managedObjectModel: managedObjectModel)
            super.init()
            
            persistentContainer.loadPersistentStores { [weak self] (description, error) in
                if let error = error {
                    fatalError("Couldn't load CoreData Stack \(error.localizedDescription)")
                }
                
                completionHandler(self?.persistentContainer)
            }
            
            persistentContainer.performBackgroundTask { (privateMOC) in
            }
            
        } else {
            
            self.persistentContainer = NSPersistentContainer(name: modelName)
            
            super.init()
            
            DispatchQueue.global(qos: .userInitiated).async { [weak self] in
                self?.persistentContainer.loadPersistentStores { [weak self] (description, error) in
                    if let error = error {
                        fatalError("Couldn't load CoreData Stack \(error.localizedDescription)")
                    }
                    
                    DispatchQueue.main.async {
                        completionHandler(self?.persistentContainer)
                    }
                }
            }
        }
    }
   
    func fetchNotebooks(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NotebookMO]? {
        do {
            return try persistentContainer.viewContext.fetch(fetchRequest) as? [NotebookMO]
        } catch {
            fatalError("fFailure to fech notebooks with contect: \(fetchRequest), \(error)")
        }
    }
    
    func fetchNotes(using fetchRequest: NSFetchRequest<NSFetchRequestResult>) -> [NoteMO]? {
        do {
            return try viewContext.fetch(fetchRequest) as? [NoteMO]
        } catch {
            fatalError("Failure to fetch Notes")
        }
    }

    
    func save() {
        do {
            try persistentContainer.viewContext.save()
        } catch {
            print("=== could not save view context ===")
            print("error: \(error.localizedDescription)")
        }
    }
    
    func reset() {
        persistentContainer.viewContext.reset()
    }
   
    func delete() {
        guard let persistentStoreUrl = persistentContainer
                .persistentStoreCoordinator.persistentStores.first?.url else {
            return
        }
        
        do {
            try persistentContainer.persistentStoreCoordinator.destroyPersistentStore(at: persistentStoreUrl,
                                                                                      ofType: NSSQLiteStoreType,
                                                                                      options: nil)
        } catch {
            fatalError("could not delete test database. \(error.localizedDescription)")
        }
    }
    
    static func manageObjectModel(with name: String) -> NSManagedObjectModel {
        guard let modelURL = Bundle.main.url(forResource: name, withExtension: "momd") else {
            fatalError("Error could not find model.")
        }
        
        guard let managedObjectModel = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing managedObjectModel from: \(modelURL).")
        }
        
        return managedObjectModel
    }
    
    func performInBackground(_ block: @escaping (NSManagedObjectContext) -> Void) {
        let privateMOC = NSManagedObjectContext(concurrencyType: .privateQueueConcurrencyType)
        
        privateMOC.parent = viewContext
        
        privateMOC.perform {
            block(privateMOC)
        }
    }
}






extension DataController {
    
    func loadNotesInBackground() {
        performInBackground { (privateManagedObjectContext) in
            let managedObjectContext = privateManagedObjectContext
            guard let notebook = NotebookMO.createNotebook(createdAt: Date(),
                                                           title: "notebook con notas",
                                                           in: managedObjectContext) else {
                return
            }
            
            NoteMO.createNote(managedObjectContext: managedObjectContext,
                              notebook: notebook,
                              title: "nota 1",
                              createdAt: Date())
            
            NoteMO.createNote(managedObjectContext: managedObjectContext,
                              notebook: notebook,
                              title: "nota 2",
                              createdAt: Date())
            
            NoteMO.createNote(managedObjectContext: managedObjectContext,
                              notebook: notebook,
                              title: "nota 3",
                              createdAt: Date())
            
            let notebookImage = UIImage(named: "notebookImage")
            
            if let dataNotebookImage = notebookImage?.pngData() {
                let photograph = PhotographMO.createPhoto(imageData: dataNotebookImage,
                                                          managedObjectContext: managedObjectContext)
            
                notebook.photograph = photograph
            }
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("failure to save in background.")
            }
        }
    }
    func loadNotesIntoViewContext() {
        let managedObjectContext = viewContext
        // crear nuestro Note en el view context
        guard let notebook = NotebookMO.createNotebook(createdAt: Date(),
                                                       title: "notebook con notas",
                                                       in: managedObjectContext) else {
            return
        }
        
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "nota 1",
                          createdAt: Date())
        
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "nota 2",
                          createdAt: Date())
        
        NoteMO.createNote(managedObjectContext: managedObjectContext,
                          notebook: notebook,
                          title: "nota 3",
                          createdAt: Date())
        
        let notebookImage = UIImage(named: "notebookImage")
        
        if let dataNotebookImage = notebookImage?.pngData() {
            let photograph = PhotographMO.createPhoto(imageData: dataNotebookImage,
                                                      managedObjectContext: managedObjectContext)
        
            notebook.photograph = photograph
        }
        
        do {
            try managedObjectContext.save()
        } catch {
            fatalError("failure to save in background.")
        }
    }
    
    func loadNotebooksIntoViewContext() {
        let managedObjectContext = viewContext
        
        NotebookMO.createNotebook(createdAt: Date(),
                                  title: "notebook1",
                                  in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(),
                                  title: "notebook2",
                                  in: managedObjectContext)
        
        NotebookMO.createNotebook(createdAt: Date(),
                                  title: "notebook3",
                                  in: managedObjectContext)
    }
    
    func addNote(with urlImage: URL, notebook: NotebookMO) {
        performInBackground { (managedObjectContext) in
            guard let imageThumbnail = DownSampler.downsample(imageAt: urlImage),
                  let imageThumbnailData = imageThumbnail.pngData() else {
                return
            }
            
            let notebookID = notebook.objectID
            let copyNotebook = managedObjectContext.object(with: notebookID) as! NotebookMO
            
            let photograhMO = PhotographMO.createPhoto(imageData: imageThumbnailData,
                                                       managedObjectContext: managedObjectContext)
            
            let note = NoteMO.createNote(managedObjectContext: managedObjectContext,
                                         notebook: copyNotebook,
                                         title: "titulo de nota",
                                         createdAt: Date())
            
            note?.photograph = photograhMO
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("could not create note with thumbnail image in background.")
            }
        }
    }
    
    func editNote(note: NoteMO, title: String, content: String) {
        performInBackground{ (managedObjectContext) in
            
            let noteID = note.objectID
            let copyNote = managedObjectContext.object(with: noteID) as! NoteMO
            copyNote.title = title
            copyNote.contents = content
            
            do {
                try managedObjectContext.save()
            } catch {
                fatalError("could not create note with thumbnail image in background.")
            }
        }
    }
}


