import Foundation
import CoreData

final class TrackerRecordStore {
    
    //MARK: - Properties
    
    private let context: NSManagedObjectContext
    
    //MARK: - init
    
    init(context: NSManagedObjectContext) {
        self.context = context
    }
    
    //MARK: - Other functions
    
    func addRecord(trackerID: UUID, trackerDate: Date) throws {
        let record = TrackerRecordCD(context: context)
        record.trackerID = trackerID
        record.trackerDate = trackerDate
        
        try context.save()
    }
    
    func deleteRecord(trackerID: UUID, trackerDate: Date) throws {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        request.predicate = NSPredicate(format: "trackerID == %@ AND trackerDate == %@", trackerID as CVarArg, trackerDate as CVarArg)
        
        let records = try context.fetch(request)
        records.forEach { context.delete($0) }
        
        try context.save()
    }
    
    func fetchRecords() -> [TrackerRecord] {
        let request: NSFetchRequest<TrackerRecordCD> = TrackerRecordCD.fetchRequest()
        
        guard let records = try? context.fetch(request) else { return [] }
        
        return records.compactMap { recordCD in
            guard let trackerID = recordCD.trackerID,
                  let trackerDate = recordCD.trackerDate
            else { return nil }
            
            return TrackerRecord(trackerId: trackerID, trackerDate: trackerDate)
        }
    }
}
