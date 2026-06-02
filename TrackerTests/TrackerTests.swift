import XCTest
import SnapshotTesting
import CoreData
@testable import Tracker

final class TrackersViewControllerSnapshotTests: XCTestCase {

    private func makeSUT() -> TrackersViewController {
        let container = NSPersistentContainer(name: "TrackerCoreData")

        container.loadPersistentStores { _, error in
            XCTAssertNil(error)
        }

        let context = container.viewContext

        let trackerStore = TrackerStore(context: context)
        let categoryStore = TrackerCategoryStore(context: context)
        let recordStore = TrackerRecordStore(context: context)

        return TrackersViewController(
            trackerStore: trackerStore,
            trackerCategoryStore: categoryStore,
            trackerRecordStore: recordStore
        )
    }

    func testTrackersViewControllerLight() {
        let vc = makeSUT()

        assertSnapshot(of: vc, as: .image(on: .iPhone13Pro, traits: .init(userInterfaceStyle: .light)))
    }

    func testTrackersViewControllerDark() {
        let vc = makeSUT()

        assertSnapshot(of: vc, as: .image(on: .iPhone13Pro, traits: .init(userInterfaceStyle: .dark)))
    }
}
