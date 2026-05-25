import UIKit

protocol TrackerCellDelegate: AnyObject {
    func didTapComplete(trackerId: UUID, indexPath: IndexPath)
}

final class TrackersViewController: UIViewController {
    
    //MARK: - Properties
    
    private let trackerStore: TrackerStore
    private let trackerCategoryStore: TrackerCategoryStore
    private let trackerRecordStore: TrackerRecordStore
    
    var completedTrackers: [TrackerRecord] = []
    var completedTrackersSet: Set<String> = []
    private var visibleCategories: [TrackerCategory] = []
    
    private var currentDate: Date {
        Calendar.current.startOfDay(for: datePicker.date)
    }
    
    
    private var formattedCurrentDate: String {
        formatDate(currentDate)
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
    
    //MARK: - init
    
    init(trackerStore: TrackerStore,
         trackerCategoryStore: TrackerCategoryStore,
         trackerRecordStore: TrackerRecordStore) {
        self.trackerStore = trackerStore
        self.trackerCategoryStore = trackerCategoryStore
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .customWhite
        
        completedTrackers = trackerRecordStore.fetchRecords()
        completedTrackersSet = Set(completedTrackers.map { trackerKey(for: $0.trackerId, date: formatDate($0.trackerDate))})
        
        setupNavigationBar()
        setupUI()
        updateEmptyListImageVisibility()
        updateVisibleCategories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
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
        let habitCreation = HabitCreationViewController()
        habitCreation.delegate = self
        let navigationController = UINavigationController(rootViewController: habitCreation)
        present(navigationController, animated: true)
    }
    
    @objc private func datePickerTapped() {
        updateVisibleCategories()
        collectionView.reloadData()
        updateEmptyListImageVisibility()
    }
    
    //MARK: - Other functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
    }
    
    private func updateEmptyListImageVisibility() {
        let isEmpty = visibleCategories.isEmpty
        emptyTrackerListImage.isHidden = !isEmpty
        emptyTrackerListLabel.isHidden = !isEmpty
    }
    
    func addTracker(tracker: Tracker, categoryName: String) {
        do {
            try trackerStore.addTracker(tracker, categoryName: categoryName)
        } catch {
            assertionFailure("Failure adding tracker: \(error)")
        }
    }
    
    private func trackerKey(for trackerId: UUID, date: String) -> String {
        return "\(trackerId.uuidString)_\(date)"
    }
    
    private func updateVisibleCategories() {
        let categories = trackerCategoryStore.categories
        
        let selectedWeekdayInt = Calendar.current.component(.weekday, from: datePicker.date)
        
        guard let selectedWeekday = WeekDay(rawValue: selectedWeekdayInt) else {
            visibleCategories = categories
            return
        }
        
        visibleCategories = categories.compactMap { category in
            let trackers = category.trackers.filter { $0.schedule.contains(selectedWeekday) }
            
            if trackers.isEmpty { return nil }
            
            return TrackerCategory(categoryTittle: category.categoryTittle, trackers: trackers)
        }
    }
}

//MARK: - CollectionViewDelegate

extension TrackersViewController: UICollectionViewDelegate {
    
}

//MARK: - CollectionViewDataSource

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
        let date = formattedCurrentDate
        
        let key = trackerKey(for: tracker.id, date: date)
        let isCompletedTracker = completedTrackersSet.contains(key)
        let completedTrackerDaysCount = completedTrackersSet.filter { $0.hasPrefix(tracker.id.uuidString) }.count
        
        cell.dataForCellConfig(tracker: tracker, isCompletedTracker: isCompletedTracker, completedTrackerDaysCount: completedTrackerDaysCount, indexPath: indexPath)
        cell.delegate = self
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: TrackersHeader.identifier, for: indexPath) as? TrackersHeader else { return UICollectionReusableView() }
            
            header.dataForHeaderConfig(title: visibleCategories[indexPath.section].categoryTittle)
            return header
        }
        return UICollectionReusableView()
    }
}

//MARK: - TrackerCellDelegate

extension TrackersViewController: TrackerCellDelegate {
    
    func didTapComplete(trackerId: UUID, indexPath: IndexPath) {
        let chosenDate = datePicker.date
        guard chosenDate <= Date() else { return }
        
        let dateString = formattedCurrentDate
        let key = trackerKey(for: trackerId, date: dateString)
        let isCompleted = completedTrackersSet.contains(key)
        
        do {
            if isCompleted {
                try trackerRecordStore.deleteRecord(trackerID: trackerId, trackerDate: currentDate)
                completedTrackersSet.remove(key)
                completedTrackers.removeAll { $0.trackerId == trackerId && $0.trackerDate == currentDate}
            } else {
                try trackerRecordStore.addRecord(trackerID: trackerId, trackerDate: currentDate)
                let record = TrackerRecord(trackerId: trackerId, trackerDate: currentDate)
                
                completedTrackersSet.insert(key)
                completedTrackers.append(record)
            }
            collectionView.reloadItems(at: [indexPath])
        } catch {
            print("Ошибка RecordStore")
        }
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
    func dataForHabitCreation(_ tracker: Tracker, categoryName: String) {
        addTracker(tracker: tracker, categoryName: categoryName)
        updateVisibleCategories()
        collectionView.reloadData()
        updateEmptyListImageVisibility()
    }
}
