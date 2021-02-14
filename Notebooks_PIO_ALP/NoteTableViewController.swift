//
//  NoteTableViewController.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 12/2/21.
//

import Foundation
import UIKit
import CoreData

class NoteTableViewController: UITableViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    let searchController = UISearchController ( searchResultsController : nil )
    
    var dataController: DataController?
    var fetchResultsController: NSFetchedResultsController<NSFetchRequestResult>?
    var notebook: NotebookMO?
    
    public convenience init(dataController: DataController) {
        self.init()
        self.dataController = dataController
    }
    
    func initializeFetchResultsController() {
        // 1. Safe unwrapping de nuestro DataController.
        guard let dataController = dataController,
            let notebook = notebook else {
            return
        }
        
        // 2. Crear nuestro NSFetchRequest
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        // 3. Seteamos el NSSortDescriptor.
        let noteCreatedAtSortDescriptor = NSSortDescriptor(key: "createdAt", ascending: true)
        fetchRequest.sortDescriptors = [noteCreatedAtSortDescriptor]
        
        // 4. Creamos nuestro NSPredicate.
        fetchRequest.predicate = NSPredicate(format: "notebook == %@", notebook)
        
        // 5. Creamos el NSFetchResultsController.
        let managedObjectContext = dataController.viewContext
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                            managedObjectContext: managedObjectContext,
                                                            sectionNameKeyPath: nil,
                                                            cacheName: nil)
        
        fetchResultsController?.delegate = self
        
        do {
            try fetchResultsController?.performFetch()
        } catch {
            fatalError("can't find notes \(error.localizedDescription) ")
        }
    }
    
    init() {
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initializeFetchResultsController()
        searchBar.delegate = self
        setupNavigationItem()
    }
    
    func setupNavigationItem() {
        let addNoteBarButtonItem = UIBarButtonItem(title: "Add Note",
                                                   style: .done,
                                                   target: self,
                                                   action: #selector(createAndPresentImagePicker))
        
        navigationItem.rightBarButtonItem = addNoteBarButtonItem
    }
    
    @objc
    func createAndPresentImagePicker() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = false
        
        if  UIImagePickerController.isSourceTypeAvailable(.photoLibrary),
            let availabletypes = UIImagePickerController.availableMediaTypes(for: .photoLibrary) {
            picker.mediaTypes = availabletypes
        }
        
        present(picker, animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController,
                               didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true) { [unowned self] in
            if let urlImage = info[.imageURL] as? URL {
                
                if let notebook = self.notebook {
                    self.dataController?.addNote(with: urlImage, notebook: notebook)
                }
            }
        }
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        return fetchResultsController?.sections?.count ?? 0
    }
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let fetchResultsController = fetchResultsController {
            return fetchResultsController.sections![section].numberOfObjects
        } else {
            return 0
        }
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "noteCellIdentifier",
                                                 for: indexPath)
        
        guard let note = fetchResultsController?.object(at: indexPath) as? NoteMO else {
            fatalError("Attempt to configure cell without a managed object")
        }
        
        cell.textLabel?.text = note.title
        
        if let noteCreatedAt = note.createdAt {
            cell.detailTextLabel?.text = HelperDateFormatter.textFrom(date: noteCreatedAt)
        }
        
        if let photograph = note.photograph,
           let imageData = photograph.imageData,
           let image = UIImage(data: imageData) {
            cell.imageView?.image = image
        }
        
        return cell
    }
    
    
    var isSearchBarEmpty: Bool {
      return searchController.searchBar.text?.isEmpty ?? true
    }
    
    func filterForSearchText(predicate: String) {
        
        guard let dataController = dataController else {return}
        guard let notebook = notebook else {return}
        
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: "Note")
        
        let notesCreatedAtSortDescriptor = NSSortDescriptor(key: "title", ascending: true)
        fetchRequest.sortDescriptors = [notesCreatedAtSortDescriptor]
        
        fetchRequest.predicate = NSPredicate(format: "title CONTAINS %@", predicate, notebook)
        
        let managedObjectContext = dataController.viewContext
        fetchResultsController = NSFetchedResultsController(fetchRequest: fetchRequest,
                                                           managedObjectContext:managedObjectContext,
                                                           sectionNameKeyPath:nil,
                                                           cacheName: nil)
        fetchResultsController?.delegate = self
        
        do{
            try fetchResultsController?.performFetch()
        } catch{
            fatalError("no Notes -> \(error.localizedDescription)")
        }
    }


}

// MARK:- NSFetchResultsControllerDelegate.
extension NoteTableViewController: NSFetchedResultsControllerDelegate {

    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView.insertSections(IndexSet(integer: sectionIndex), with: .fade)
        case .delete:
            tableView.deleteSections(IndexSet(integer: sectionIndex), with: .fade)
        case .move, .update:
            break
        @unknown default: fatalError()
        }
    }

    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
            case .insert:
                tableView.insertRows(at: [newIndexPath!], with: .fade)
            case .delete:
                tableView.deleteRows(at: [indexPath!], with: .fade)
            case .update:
                tableView.reloadRows(at: [indexPath!], with: .fade)
            case .move:
                tableView.moveRow(at: indexPath!, to: newIndexPath!)
            @unknown default:
                fatalError()
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
}

extension NoteTableViewController: UISearchResultsUpdating{
    func updateSearchResults(for searchController: UISearchController) {

        guard let searchText = self.searchController.searchBar.text else {return}
        print(searchText)
        self.tableView.reloadData()
        self.filterForSearchText(predicate: searchText)
    }
}

extension NoteTableViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if !searchText.isEmpty{
          self.filterForSearchText(predicate: searchText)
                }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
//            self.setupSearchBarShow(isShowing: false)
//            self.viewModel.viewWasLoad()
//            self.tablewView.reloadData()
        }
}

