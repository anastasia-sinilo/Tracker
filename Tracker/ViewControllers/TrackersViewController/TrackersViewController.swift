import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapComplete(trackerId: UUID, indexPath: IndexPath)
}

final class TrackersViewController: UIViewController {
    
    //MARK: - Properties
    
    var categories: [TrackerCategory] = []
    var completedTrackers: [TrackerRecord] = []
    
    var visibleCategories: [TrackerCategory] {
        let selectedWeekday = Calendar.current.component(.weekday, from: datePicker.date)
        let visibleCategory = categories.compactMap { category in
            let trackers = category.trackers.filter { tracker in
                tracker.schedule.contains(selectedWeekday)
            }
            if !trackers.isEmpty {
                return TrackerCategory(categortTittle: category.categortTittle, trackers: trackers)
            } else {
                return nil
            }
        }
        return visibleCategory
    }
    
    private var dateStringFormat: String {
        let selectedDate = datePicker.date
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd.MM.yyyy"
        return dateFormatter.string(from: selectedDate)
    }
    
    //MARK: - UI Elements
    
    private var datePicker = UIDatePicker()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "Поиск"
        searchBar.searchBarStyle = .minimal
        searchBar.translatesAutoresizingMaskIntoConstraints = false
        return searchBar
    }()
    
    private lazy var emptyTrackerListImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .emptyTrackerList)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var emptyTrackerListLabel: UILabel = {
        let label = UILabel()
        label.text = "Что будем отслеживать?"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .customBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var collectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.backgroundColor = .clear
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        view.register(TrackersHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersHeader.identifier)
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        
        setupNavigationBar()
        setupUI()
        updateEmptyListImageVisibility()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(emptyTrackerListImage)
        view.addSubview(emptyTrackerListLabel)
        view.addSubview(collectionView)
        
        NSLayoutConstraint.activate([
            searchBar.heightAnchor.constraint(equalToConstant: 36),
            searchBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 7),
            searchBar.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 8),
            searchBar.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -8),
            
            emptyTrackerListImage.heightAnchor.constraint(equalToConstant: 80),
            emptyTrackerListImage.widthAnchor.constraint(equalToConstant: 80),
            emptyTrackerListImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyTrackerListImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            emptyTrackerListLabel.heightAnchor.constraint(equalToConstant: 18),
            emptyTrackerListLabel.topAnchor.constraint(equalTo: emptyTrackerListImage.bottomAnchor, constant: 8),
            emptyTrackerListLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyTrackerListLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            collectionView.topAnchor.constraint(equalTo: searchBar.bottomAnchor, constant: 24),
            collectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            collectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "Трекеры"
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addTrackerButton = UIBarButtonItem(image: .addTracker, style: .plain,
                                               target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .customBlack
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let container = UIView()
        container.addSubview(datePicker)
        
        NSLayoutConstraint.activate([
            datePicker.leadingAnchor.constraint(equalTo: container.leadingAnchor),
            datePicker.trailingAnchor.constraint(equalTo: container.trailingAnchor),
            datePicker.topAnchor.constraint(equalTo: container.topAnchor),
            datePicker.bottomAnchor.constraint(equalTo: container.bottomAnchor)
        ])
        container.widthAnchor.constraint(equalToConstant: 100).isActive = true
        container.translatesAutoresizingMaskIntoConstraints = false
        
        let datePickerItem = UIBarButtonItem(customView: container)
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .compact
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        navigationItem.rightBarButtonItem = datePickerItem
    }
    
    //MARK: - Actions
    
    @objc private func addTrackerButtonTapped() {
        //categories += makeMockTrackers()
        
        let habitCreation = HabitCreationViewController()
        habitCreation.delegate = self
        let navigationController = UINavigationController(rootViewController: habitCreation)
        present(navigationController, animated: true)
        
        //collectionView.reloadData()
        //updateEmptyListImageVisibility()
    }
    
    @objc private func datePickerTapped() {
        collectionView.reloadData()
        updateEmptyListImageVisibility()
    }
    
    //MARK: - Other functions
    
    private func updateEmptyListImageVisibility() {
        let isEmpty = visibleCategories.isEmpty
        emptyTrackerListImage.isHidden = !isEmpty
        emptyTrackerListLabel.isHidden = !isEmpty
    }
    
    //MARK: Моки
    /*
    private func makeMockTrackers() -> [TrackerCategory] {
        let category1 = "Важное"
        let category2 = "Задачи"
        
        let tracker1 = Tracker(
            id: UUID(),
            title: "Почитать книгу",
            color: .systemBlue,
            emoji: "📚",
            schedule: [1,2,3,4,5,6,7]
        )
        
        let tracker2 = Tracker(
            id: UUID(),
            title: "Тренировка",
            color: .systemRed,
            emoji: "💪",
            schedule: [2,4,6]
        )
        
        let tracker3 = Tracker(
            id: UUID(),
            title: "Выпить воды",
            color: .systemGreen,
            emoji: "💧",
            schedule: [1,2,3,4,5,6,7]
        )
        
        return [
            TrackerCategory(categortTittle: category1, trackers: [tracker2, tracker3]),
            TrackerCategory(categortTittle: category2, trackers: [tracker1])
        ]
    }
    */
}

//MARK: - CollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    
}

//MARK: - CollectionViewDataSourse

extension TrackersViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int {
        return visibleCategories.count
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return visibleCategories[section].trackers.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: TrackerCell.identifier, for: indexPath) as? TrackerCell else { return UICollectionViewCell() }
        
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let date = dateStringFormat
        let isCompletedTracker = completedTrackers.contains { $0.trackerId == tracker.id && $0.trackerDate == date }
        let completedTrackerDaysCount = completedTrackers.filter { $0.trackerId == tracker.id }.count
        
        
        cell.dataForCellConfig(tracker: tracker, isCompletedTracker: isCompletedTracker, completedTrackerDaysCount: completedTrackerDaysCount, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackersHeader.identifier, for: indexPath) as? TrackersHeader else { return UICollectionReusableView() }
            
            header.dataForHeaderConfig(title: visibleCategories[indexPath.section].categortTittle)
            return header
        }
        return UICollectionReusableView()
    }
}

//MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    
    func didTapComplete(trackerId: UUID, indexPath: IndexPath) {
        let currentDate = datePicker.date
        guard currentDate <= Date() else { return }
        
        let record = TrackerRecord(
            trackerId: trackerId,
            trackerDate: dateStringFormat
        )
        
        let isCompleted = completedTrackers.contains { $0.trackerId == trackerId && $0.trackerDate == dateStringFormat }
        
        if isCompleted { completedTrackers = completedTrackers.filter { !($0.trackerId == trackerId && $0.trackerDate == dateStringFormat) }
        } else {
            completedTrackers = completedTrackers + [record]
        }
        
        collectionView.reloadItems(at: [indexPath])
    }
}

//MARK: - CollectionViewFlowLayout

extension TrackersViewController: UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalHorizontalPadding: CGFloat = 16 + 9 + 16
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let cellWidth = floor(availableWidth / 2)
        return CGSize(width: cellWidth, height: 148)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 9
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 18)
    }
}

//MARK: - HabitCreationDelegate

extension TrackersViewController: HabitCreationViewControllerDelegate {
    func didCreateHabit(_ tracker: Tracker, categoryName: String) {
        //addTracker(tracker: tracker, categoryName: categoryName)
        collectionView.reloadData()
        updateEmptyListImageVisibility()
    }
}
