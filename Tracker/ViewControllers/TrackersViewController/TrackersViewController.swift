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
    
    private var selectedFilter: TrackerFilter = {
        guard let rawValue = UserDefaults.standard.string(forKey: "SelectedFilter"),
              let filter = TrackerFilter(rawValue: rawValue)
        else { return .all }

        return filter
    }()
    
    //MARK: - UI Elements
    
    private var datePicker = UIDatePicker()
    
    private lazy var searchBar: UISearchBar = {
        let searchBar = UISearchBar()
        searchBar.placeholder = "search_placeholder".localized
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
        label.text = "empty_list_placeholder".localized
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
        view.contentInset.bottom = 100
        view.register(TrackerCell.self, forCellWithReuseIdentifier: TrackerCell.identifier)
        view.register(TrackersHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: TrackersHeader.identifier)
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var filtersButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("filters_title".localized, for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        button.setTitleColor(.customWhite, for: .normal)
        button.backgroundColor = .customBlue
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(filtersButtonTapped), for: .touchUpInside)
        return button
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
        
        trackerCategoryStore.delegate = self
        
        completedTrackers = trackerRecordStore.fetchRecords()
        completedTrackersSet = Set(completedTrackers.map { trackerKey(for: $0.trackerId, date: formatDate($0.trackerDate))})
        
        setupNavigationBar()
        setupUI()
        updatePlaceholderState()
        updateVisibleCategories()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        collectionView.reloadData()
        updatePlaceholderState()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(searchBar)
        view.addSubview(emptyTrackerListImage)
        view.addSubview(emptyTrackerListLabel)
        view.addSubview(collectionView)
        view.addSubview(filtersButton)
        
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
            collectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            
            filtersButton.heightAnchor.constraint(equalToConstant: 50),
            filtersButton.widthAnchor.constraint(equalToConstant: 114),
            filtersButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            filtersButton.centerXAnchor.constraint(equalTo: view.centerXAnchor)
        ])
    }
    
    private func setupNavigationBar() {
        title = "trackers_screen_title".localized
        navigationController?.navigationBar.prefersLargeTitles = true
        
        let addTrackerButton = UIBarButtonItem(image: .addTracker, style: .plain,
                                               target: self, action: #selector(addTrackerButtonTapped))
        addTrackerButton.tintColor = .customBlack
        navigationItem.leftBarButtonItem = addTrackerButton
        
        let container = UIView()
        container.addSubview(datePicker)
        container.layer.cornerRadius = 16
        container.clipsToBounds = true
        
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
        datePicker.overrideUserInterfaceStyle = .light
        datePicker.backgroundColor = .white
        datePicker.preferredDatePickerStyle = .compact
        datePicker.layer.cornerRadius = 8
        datePicker.clipsToBounds = true
        datePicker.translatesAutoresizingMaskIntoConstraints = false
        datePicker.addTarget(self, action: #selector(datePickerTapped), for: .valueChanged)
        navigationItem.rightBarButtonItem = datePickerItem
        if #available(iOS 26.0, *) {
            navigationItem.rightBarButtonItem?.hidesSharedBackground = true
        }
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
        updatePlaceholderState()
    }
    
    @objc private func filtersButtonTapped() {
        let vc = FiltersViewController(selectedFilter: selectedFilter)
        vc.onFilterSelected = { [weak self] filter in
            self?.applyFilter(filter)
        }
        
        let navigationController = UINavigationController(rootViewController: vc)
        
        present(navigationController, animated: true)
    }
    
    //MARK: - Other functions
    
    private func formatDate(_ date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "dd.MM.yyyy"
        return formatter.string(from: date)
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
            let trackers = category.trackers.filter { tracker in
                guard tracker.schedule.contains(selectedWeekday) else { return false }

                let key = trackerKey(for: tracker.id, date: formattedCurrentDate)
                let completed = completedTrackersSet.contains(key)

                switch selectedFilter {
                case .all, .today:
                    return true
                case .completed:
                    return completed
                case .uncompleted:
                    return !completed
                }
            }
            if trackers.isEmpty { return nil }
            return TrackerCategory(categoryTittle: category.categoryTittle, trackers: trackers)
        }
        filtersButton.isHidden = visibleCategories.isEmpty
    }
    
    //MARK: - Placeholders
    
    private func updatePlaceholder(state: PlaceholderState) {
        switch state {
        case .emptyTrackers:
            emptyTrackerListImage.image = UIImage(resource: .emptyTrackerList)
            emptyTrackerListLabel.text = "empty_list_placeholder".localized
            emptyTrackerListImage.isHidden = false
            emptyTrackerListLabel.isHidden = false
            
        case .notFound:
            emptyTrackerListImage.image = UIImage(resource: .nothingFound)
            emptyTrackerListLabel.text = "nothing_found".localized
            emptyTrackerListImage.isHidden = false
            emptyTrackerListLabel.isHidden = false
            
        case .hidden:
            emptyTrackerListImage.isHidden = true
            emptyTrackerListLabel.isHidden = true
        }
    }
    
    private func updatePlaceholderState() {
        let hasAnyTrackers = !trackerCategoryStore.categories.isEmpty
        let hasVisibleTrackers = !visibleCategories.isEmpty

        if !hasAnyTrackers {
            updatePlaceholder(state: .emptyTrackers)
            return
        }
        if !hasVisibleTrackers {
            updatePlaceholder(state: .notFound)
            return
        }
        updatePlaceholder(state: .hidden)
    }
    
    //MARK: - Действия с трекерами
    
    private func editTracker(at indexPath: IndexPath) {
        let tracker = visibleCategories[indexPath.section].trackers[indexPath.row]
        let completedDaysCount = completedTrackersSet.filter { $0.hasPrefix(tracker.id.uuidString) }.count
        let category = trackerCategoryStore.category(for: tracker.id)
        
        let vc = HabitCreationViewController(mode: .edit(tracker: tracker, category: category, completedDays: completedDaysCount))
        vc.onTrackerEdited = { [weak self] tracker, categoryName in
            self?.updateTracker(tracker, categoryName: categoryName)
        }
        vc.hidesBottomBarWhenPushed = true
        let navigationController = UINavigationController(rootViewController: vc)
        present(navigationController, animated: true)
    }
    
    private func updateTracker(_ tracker: Tracker, categoryName: String) {
        do {
            try trackerStore.updateTracker(tracker, categoryName: categoryName)

            updateVisibleCategories()
            collectionView.reloadData()
        } catch {
            print(error)
        }
    }
    
    private func deleteTracker(_ tracker: Tracker) {
        do {
            try trackerStore.deleteTracker(tracker)
            
            updateVisibleCategories()
            collectionView.reloadData()
            updatePlaceholderState()
        } catch {
            print(error)
        }
    }
    
    //MARK: - Фильтры
    
    private func applyFilter(_ filter: TrackerFilter) {
        selectedFilter = filter

        UserDefaults.standard.set(filter.rawValue, forKey: "SelectedFilter")

        if filter == .today {
            datePicker.date = Date()
        }
        
        updateVisibleCategories()
        collectionView.reloadData()
        updatePlaceholderState()
    }
}

//MARK: - CollectionViewDelegate - Меню и алерт удаления трекера

extension TrackersViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, contextMenuConfigurationForItemAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        
        UIContextMenuConfiguration(identifier: indexPath as NSIndexPath, previewProvider: nil) { [weak self] _ in
            
            guard let self else { return nil }
            
            let editAction = UIAction(title: "edit_action".localized) { _ in
                self.editTracker(at: indexPath)
            }
            
            let deleteAction = UIAction(title: "delete_action".localized,attributes: .destructive) { _ in
                self.showDeleteTrackerAlert(indexPath: indexPath)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    //Выделение только карточки
    func collectionView(_ collectionView: UICollectionView, previewForHighlightingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
              let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell
        else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = cell.cardColor
       
        return UITargetedPreview(view: cell.previewView, parameters: parameters)
    }
    //Помогает убрать мигание карточки при отмене выбора
    func collectionView(_ collectionView: UICollectionView, previewForDismissingContextMenuWithConfiguration configuration: UIContextMenuConfiguration) -> UITargetedPreview? {
        guard let indexPath = configuration.identifier as? IndexPath,
                let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell
        else { return nil }

        let parameters = UIPreviewParameters()
        parameters.backgroundColor = cell.cardColor

        return UITargetedPreview(view: cell.previewView, parameters: parameters)
    }
    
    private func showDeleteTrackerAlert(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "delete_alert_title".localized,
                                      message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "delete_action".localized, style: .destructive) { [weak self] _ in
            guard let self else { return }
            
            let tracker = self.visibleCategories[indexPath.section].trackers[indexPath.row]
            self.deleteTracker(tracker)
        }
        
        let cancelAction = UIAlertAction(title: "cancel_button".localized, style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
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
            if let cell = collectionView.cellForItem(at: indexPath) as? TrackerCell {
                
                let completedDaysCount = completedTrackersSet
                    .filter { $0.hasPrefix(trackerId.uuidString) }
                    .count
                cell.updateCompletionState(
                    isCompleted: !isCompleted,
                    completedDaysCount: completedDaysCount
                )
            }
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
        updatePlaceholderState()
    }
}

//MARK: - TrackerCategoryStoreDelegate

extension TrackersViewController: TrackerCategoryStoreDelegate {
    
    func trackerCategoryStoreDidUpdate() {
        updateVisibleCategories()
        collectionView.reloadData()
        updatePlaceholderState()
    }
}
