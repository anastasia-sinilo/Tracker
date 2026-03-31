import UIKit

final class TabBarViewController: UITabBarController {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
    }
    
    private func tabBarConfig() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        appearance.backgroundColor = .white
        appearance.shadowColor = .separator
        
        tabBar.standardAppearance = appearance
        tabBar.scrollEdgeAppearance = appearance
    }
    
    private func setupViewControllers() {
        let trackersVC = TrackersViewController()
        let trackersNavC = UINavigationController(rootViewController: trackersVC)
        let statisticsVC = StatisticsViewController()
        let statisticsNavC = UINavigationController(rootViewController: statisticsVC)
        
        trackersVC.tabBarItem = UITabBarItem(title: "Трекеры", image: .trackersItem, selectedImage: nil)
        statisticsVC.tabBarItem = UITabBarItem(title: "Трекеры", image: .statisticsItem, selectedImage: nil)
        
        self.viewControllers = [trackersNavC, statisticsNavC]
    }
}
