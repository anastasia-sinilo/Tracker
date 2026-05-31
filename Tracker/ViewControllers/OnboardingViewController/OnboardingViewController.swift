import UIKit

final class OnboardingViewController: UIViewController {
    
    //MARK: - Properties
    
    private let pages: [OnboardingPage] = [OnboardingPage(image: UIImage(resource: .onboardingPage1), title: "Отслеживайте только \nто, что хотите"),
                                           OnboardingPage(image: UIImage(resource: .onboardingPage2), title: "Даже если это \nне литры воды и йога")]
    
    private lazy var pageController: [OnboardingPageViewController] = {
        pages.map { OnboardingPageViewController(page: $0) }
    }()
    
    //MARK: - UI Elements
    
    private lazy var pageViewController: UIPageViewController = {
        let pageVC = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal)
        pageVC.delegate = self
        pageVC.dataSource = self
        return pageVC
    }()
    
    private lazy var pageControl: UIPageControl = {
        let pageControl = UIPageControl()
        pageControl.numberOfPages = pages.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .customBlack
        pageControl.pageIndicatorTintColor = .customGray
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        return pageControl
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Вот это технологии!", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.customWhite, for: .normal)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupPageViewController()
        setupUI()
        setInitialPage()
    }
    
    //MARK: - Actions
    
    @objc private func doneButtonTapped() {
        UserDefaults.standard.set(true, forKey: "OnboardingDone")
        
        guard let scene = view.window?.windowScene,
              let sceneDelegate = scene.delegate as? SceneDelegate,
              let window = sceneDelegate.window
        else { return }
        
        window.rootViewController = TabBarViewController()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(pageControl)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            pageControl.heightAnchor.constraint(equalToConstant: 6),
            pageControl.bottomAnchor.constraint(equalTo: doneButton.topAnchor, constant: -24),
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -50),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    //MARK: - Other functions
    
    private func setInitialPage() {
        if let firstVC = pageController.first {
            pageViewController.setViewControllers([firstVC], direction: .forward, animated: true)
        }
    }
    
    private func setupPageViewController() {
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        
        pageViewController.didMove(toParent: self)
    }
    
}

//MARK: - UIPageViewControllerDataSource

extension OnboardingViewController: UIPageViewControllerDataSource {
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageViewController,
              let currentIndex = pageController.firstIndex(of: currentVC), currentIndex > 0
        else { return nil }
        
        return pageController[currentIndex - 1]
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingPageViewController,
              let currentIndex = pageController.firstIndex(of: currentVC), currentIndex < pageController.count - 1
        else { return nil }
        
        return pageController[currentIndex + 1]
    }
}

//MARK: - UIPageViewControllerDelegate

extension OnboardingViewController: UIPageViewControllerDelegate {
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        guard completed,
              let currentVC = pageViewController.viewControllers?.first as? OnboardingPageViewController,
              let index = pageController.firstIndex(of: currentVC)
        else { return }
        pageControl.currentPage = index
    }
}
