import Foundation
import UIKit
import CoreData

protocol TrackerCategoryStoreDelegate: AnyObject {
    func trackerCategoryStoreDidUpdate()
}

final class TrackerCategoryStore: NSObject, NSFetchedResultsControllerDelegate {
    
    //MARK: - Properties
    
    weak var delegate: TrackerCategoryStoreDelegate?
    
    private var context: NSManagedObjectContext
    
    lazy var fetchedResultsController: NSFetchedResultsController<TrackerCategoryCD> = {
        let request: NSFetchRequest<TrackerCategoryCD> = TrackerCategoryCD.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(key: "categoryTitle", ascending: true)]
        
        let fetchedResultsController = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        fetchedResultsController.delegate = self
        return fetchedResultsController
    }()
    
    var categories: [TrackerCategory] {

        guard let objects = fetchedResultsController.fetchedObjects else { return [] }

        return objects.compactMap { categoryCD in
            let trackersSet = categoryCD.trackersCoreData as? Set<TrackerCD> ?? []
            let trackers = trackersSet.compactMap(trackerMap)

            return TrackerCategory(categoryTittle: categoryCD.categoryTitle ?? "", trackers: trackers)
        }
    }
    
    var numberOfSections: Int {
        return fetchedResultsController.sections?.count ?? 0
    }
    
    //MARK: - init
    
    init(context: NSManagedObjectContext) {
        self.context = context
        super.init()
        
        do {
            try fetchedResultsController.performFetch()
        } catch {
            assertionFailure("Ошибка TrackerCategoryStore: \(error)")
        }
    }
    
    //MARK: - Other functions
    
    private func trackerMap(from trackerCD: TrackerCD) -> Tracker? {
        guard
            let id = trackerCD.id,
            let title = trackerCD.title,
            let emoji = trackerCD.emoji,
            let colorHex = trackerCD.color,
            let color = UIColor(hex: colorHex),
            let rawSchedule = trackerCD.schedule
        else {
            return nil
        }

        let schedule = rawSchedule.split(separator: ",").compactMap { Int($0) }.compactMap { WeekDay(rawValue: $0) }

        return Tracker(id: id, title: title, color: color, emoji: emoji, schedule: schedule)
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        delegate?.trackerCategoryStoreDidUpdate()
    }
    
    func addCategory(title: String) throws {
        let categoryCD = TrackerCategoryCD(context: context)
        categoryCD.categoryTitle = title
        
        try context.save()
    }
    
    func fetchCategories() -> [TrackerCategory] {
        categories
    }
    
    func deleteCategory(_ category: TrackerCategory) throws {
        let request = TrackerCategoryCD.fetchRequest()
        
        guard let categories = try? context.fetch(request),
              let categoryCD = categories.first(where: { $0.categoryTitle == category.categoryTittle })
        else { return }
        
        context.delete(categoryCD)
        try context.save()
    }
    
    func updateCategory(oldTitle: String, newTitle: String) throws {
        let request = TrackerCategoryCD.fetchRequest()
        
        guard let categories = try? context.fetch(request),
              let categoryCD = categories.first(where: { $0.categoryTitle == oldTitle })
        else { return }
        
        categoryCD.categoryTitle = newTitle
        try context.save()
    }
}
