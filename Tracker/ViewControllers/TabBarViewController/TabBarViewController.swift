import UIKit

final class TabBarViewController: UITabBarController {
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tabBarConfig()
        setupViewControllers()
    }
    
    //MARK: - Other functions
    
    private func tabBarConfig() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .customWhite
        appearance.shadowColor = .separator
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
        
        let context = appDelegate.context
        let trackerStore = TrackerStore(context: context)
        let trackerCategoryStore = TrackerCategoryStore(context: context)
        let trackerRecordStore = TrackerRecordStore(context: context)
        
        let trackersVC = TrackersViewController(trackerStore: trackerStore,
                                                trackerCategoryStore: trackerCategoryStore,
                                                trackerRecordStore: trackerRecordStore)
        let trackersNavC = UINavigationController(rootViewController: trackersVC)
        let statisticsVC = StatisticsViewController(trackerRecordStore: trackerRecordStore)
        let statisticsNavC = UINavigationController(rootViewController: statisticsVC)
        
        trackersVC.tabBarItem = UITabBarItem(title: "trackers_screen_title".localized, image: .trackersItem, selectedImage: nil)
        statisticsVC.tabBarItem = UITabBarItem(title: "statistics_screen_title".localized, image: .statisticsItem, selectedImage: nil)
        
        self.viewControllers = [trackersNavC, statisticsNavC]
    }
}
