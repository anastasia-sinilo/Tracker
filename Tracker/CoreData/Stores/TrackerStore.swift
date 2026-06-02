import Foundation
import CoreData

final class TrackerStore {
    //MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    //MARK: - init
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    //MARK: - Other Functions
    
    func addTracker(_ tracker: Tracker, categoryName: String) throws {
        let category = findCategory(categoryName: categoryName)
        let object = TrackerCD(context: context)
        object.id = tracker.id
        object.title = tracker.title
        object.color = tracker.color.toHex()
        object.emoji = tracker.emoji
        object.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        object.categoryCoreData = category
        
        do {
            try context.save()
            print("Данные сохранились")
        } catch {
            print("Данные не сохранились:", error)
        }
    }
    
    private func findCategory(categoryName: String) -> TrackerCategoryCD {
        let request = NSFetchRequest<TrackerCategoryCD>(entityName: "TrackerCategoryCD")
        request.predicate = NSPredicate(format: "categoryTitle == %@", categoryName)
        
        if let existingCategory = try? context.fetch(request).first { return existingCategory }
        
        let newCategory = TrackerCategoryCD(context: context)
        newCategory.categoryTitle = categoryName
        return newCategory
    }
    
    func deleteTracker(_ tracker: Tracker) throws {
        let trackerRequest = TrackerCD.fetchRequest()

        guard let trackers = try? context.fetch(trackerRequest),
              let trackerCD = trackers.first(where: { $0.id == tracker.id })
        else { return }

        let recordRequest: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        recordRequest.predicate = NSPredicate(format: "trackerID == %@", tracker.id as CVarArg)

        let records = try context.fetch(recordRequest)

        records.forEach { context.delete($0) }

        context.delete(trackerCD)
        try context.save()
    }
    
    func updateTracker(_ tracker: Tracker, categoryName: String) throws {
        let request = TrackerCD.fetchRequest()

        guard let trackers = try? context.fetch(request),
              let trackerCD = trackers.first(where: { $0.id == tracker.id })
        else { return }

        trackerCD.title = tracker.title
        trackerCD.color = tracker.color.toHex()
        trackerCD.emoji = tracker.emoji
        trackerCD.schedule = tracker.schedule.map { String($0.rawValue) }.joined(separator: ",")
        trackerCD.categoryCoreData = findCategory(categoryName: categoryName)

        try context.save()
    }
}
