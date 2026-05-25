//
//  TrackerCD+CoreDataProperties.swift
//  Tracker
//
//  Created by Анастасия Синило on 24.05.2026.
//
//

public import Foundation
public import CoreData
import UIKit


public typealias TrackerCDCoreDataPropertiesSet = NSSet

extension TrackerCD {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<TrackerCD> {
        return NSFetchRequest<TrackerCD>(entityName: "TrackerCD")
    }

    @NSManaged public var color: UIColor?
    @NSManaged public var emoji: String?
    @NSManaged public var id: UUID?
    @NSManaged public var schedule: String?
    @NSManaged public var title: String?
    @NSManaged public var categoryCoreData: TrackerCategoryCD?

}

extension TrackerCD : Identifiable {

}
