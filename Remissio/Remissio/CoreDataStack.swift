//
//  CoreDataStack.swift
//  Remissio
//
//  Created by Lorenzo Annibalini on 24/04/25.
//

import CoreData

class CoreDataStack {
    static let shared = CoreDataStack()

    let persistentContainer: NSPersistentContainer

    private init() {
        persistentContainer = NSPersistentContainer(name: "StatoSaluteModel")
        persistentContainer.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Errore Core Data: \(error)")
            }
        }
    }

    var context: NSManagedObjectContext {
        persistentContainer.viewContext
    }

    func saveContext() {
        let context = persistentContainer.viewContext
        if context.hasChanges {
            try? context.save()
        }
    }
}
