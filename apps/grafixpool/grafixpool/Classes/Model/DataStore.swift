//
//  DataStore.swift
//  grafixpool
//
//  Created by Alex Romayev on 2/25/17.
//  Copyright © 2017 Executive Graphics. All rights reserved.
//

import Foundation
import CoreData

final class DataStore: NSObject {
    static let store = DataStore()
    static let storeName = "grafixpool"

    var managedObjectContext: NSManagedObjectContext
    var editingOjbectContext: NSManagedObjectContext {
        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        editingContext.userInfo["EDIT"] = true
        editingContext.parent = managedObjectContext
        return editingContext
    }

    override init() {
        guard let modelURL = Bundle.main.url(forResource: DataStore.storeName, withExtension: "momd") else {
            fatalError("Error loading model from bundle")
        }
        guard let mom = NSManagedObjectModel(contentsOf: modelURL) else {
            fatalError("Error initializing mom from: \(modelURL)")
        }
        let psc = NSPersistentStoreCoordinator(managedObjectModel: mom)
        managedObjectContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = psc

        DispatchQueue.global(qos: .background).async {
            let urls = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
            let docURL = urls[urls.endIndex - 1]
            let storeURL = docURL.appendingPathComponent(DataStore.storeName + ".sqlite")
            do {
                try psc.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: storeURL, options: nil)
            } catch {
                fatalError("Error migrating store: \(error)")
            }
        }
    }

    private func isEditing(context: NSManagedObjectContext) -> Bool {
        if let condition = context.userInfo["EDIT"] as? Bool {
            return condition == true
        }
        return false
    }

    func saveContext(_ context: NSManagedObjectContext) {
        precondition(context != managedObjectContext, "Illigal parameter: main context is read-only")
        assert(Thread.isMainThread, "Illegal state: can only save context on the main thread")
        
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                print("Failure to save context: \(error)")
            }
        }
    }
}
