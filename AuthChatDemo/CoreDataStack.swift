//
//  CoreDataStack.swift
//  AuthChatDemo
//
//  Created by Jonathan Guthrie on 2017-07-05.
//  Copyright © 2017 iamjono.io. All rights reserved.
//

import CoreData

class CoreDataStack {
	lazy var persistentContainer: NSPersistentContainer = {
		let container = NSPersistentContainer(name: "Model")
		container.loadPersistentStores(completionHandler: { (storeDescription, error) in
			if let error = error {
				fatalError("Unresolved error \(error)")
			}
		})
		return container
	}()

	var context: NSManagedObjectContext {
		return persistentContainer.viewContext
	}

	func saveContext() {
		let context = persistentContainer.viewContext
		if context.hasChanges {
			do {
				try context.save()
			} catch let error as NSError {
				fatalError("Unresolved error \(error)")
			}
		}
	}
}
