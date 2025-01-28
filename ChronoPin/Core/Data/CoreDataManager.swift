//
//  Persistence.swift
//  ChronoPin
//
//  Created by Nischal Paudyal on 1/25/25.
//

import CoreData

final class CoreDataManager {
    static let shared = CoreDataManager()
    let container: NSPersistentContainer

    private init() {
        container = NSPersistentContainer(name: "Chronopin")
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Core Data failed to load: \(error)")
            }
        }
    }

//    func save(_ pin: Pin) {
//        let entity = PinEntity(context: container.viewContext)
//        entity.id = pin.id
//        entity.userId = pin.userId
//        entity.latitude = pin.latitude
//        entity.longitude = pin.longitude
//        entity.message = pin.message
//        entity.unlockDate = pin.unlockDate
//        try? container.viewContext.save()
//    }
}
