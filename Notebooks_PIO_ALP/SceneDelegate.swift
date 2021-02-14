//
//  SceneDelegate.swift
//  Notebooks_PIO_ALP
//
//  Created by Alejandro Lorenzo perez on 6/2/21.
//

import Foundation
import UIKit
import CoreData


class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    var dataController: DataController!

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        dataController = DataController(modelName: "Notebooks_PIO_ALPModel",
                                        optionalStoreName: nil,
                                        completionHandler: { [weak self] persistentContainer in

            guard persistentContainer != nil else {
                fatalError("the core data stack was not created")
            }
            
            self?.preloadData()
        })
        
        guard let tableNotebookViewController = UIStoryboard(name: "Main",
                                                             bundle: nil)
                .instantiateViewController(identifier: "NotebookTableViewController") as? NotebookTableViewController else {
            fatalError("NotebookTableViewController could not be created")
        }
        
        tableNotebookViewController.dataController = dataController
        
        guard let windowScene = scene as? UIWindowScene else { return }
        self.window = UIWindow(windowScene: windowScene)
        self.window?.rootViewController = UINavigationController(rootViewController: tableNotebookViewController)
        self.window?.makeKeyAndVisible()
    }
    
    func preloadData() {
        
        guard !UserDefaults.standard.bool(forKey: "hasPreloadData") else {
            return
        }
        
        UserDefaults.standard.set(true, forKey: "hasPreloadData")
        
        dataController?.loadNotesIntoViewContext()
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        dataController.save()
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }


}
