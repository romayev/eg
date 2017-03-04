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

    var viewContext: NSManagedObjectContext {
        return persistentContainer.viewContext
    }
    var backgroundContext: NSManagedObjectContext {
        return persistentContainer.newBackgroundContext()
//        let editingContext = NSManagedObjectContext(concurrencyType: .mainQueueConcurrencyType)
//        editingContext.userInfo["EDIT"] = true
//        editingContext.parent = viewContext
//        editingContext.automaticallyMergesChangesFromParent = true
//        return editingContext
    }

    lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "grafixpool")
        let desc = NSPersistentStoreDescription()
        desc.shouldAddStoreAsynchronously = true

        container.loadPersistentStores(completionHandler: { (desc, error) in
            if let error = error {
                fatalError("Unresolved error \(error)")
            }
        })
        return container
    }()

    override init() {
        super.init()
        self.preloadData()
    }

    private func isEditing(context: NSManagedObjectContext) -> Bool {
        if let condition = context.userInfo["EDIT"] as? Bool {
            return condition == true
        }
        return false
    }

    func save(background: NSManagedObjectContext) {
        save(context: background);
//        if let parentContext = editing.parent {
//            save(context: parentContext);
//        }
    }

    func save(context: NSManagedObjectContext) {
        //precondition(context != managedObjectContext, "Illigal parameter: main context is read-only")
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

    private func preloadData() {
        if (JobType.isLoaded(context: viewContext)) {
            return
        }
        let editing = backgroundContext
        for (index, _) in JobType.Category.all.enumerated() {
            let record = JobType.create(context: editing)
            record.id = index + 1
        }
        save(background: editing)
    }
}
