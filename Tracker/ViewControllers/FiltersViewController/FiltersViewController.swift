import UIKit

final class FiltersViewController: UIViewController {

    // MARK: - Properties

    private let filters: [(title: String, filter: TrackerFilter)] = [("Все трекеры", .all),
                                                                     ("Трекеры на сегодня", .today),
                                                                     ("Завершённые", .completed),
                                                                     ("Незавершённые", .uncompleted)]

    private var selectedFilter: TrackerFilter

    var onFilterSelected: ((TrackerFilter) -> Void)?

    // MARK: - UI Elements

    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.register(FilterCell.self, forCellReuseIdentifier: FilterCell.identifier)
        tableView.dataSource = self
        tableView.delegate = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    // MARK: - Init

    init(selectedFilter: TrackerFilter) {
        self.selectedFilter = selectedFilter
        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle

    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Фильтры"

        setupUI()
    }

    // MARK: - UI Setup

    private func setupUI() {
        view.addSubview(tableView)

        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 300),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
        ])
    }

    // MARK: - Other Functions

    private func title(for filter: TrackerFilter) -> String {
        switch filter {
        case .all:
            return "Все трекеры"
        case .today:
            return "Трекеры на сегодня"
        case .completed:
            return "Завершённые"
        case .uncompleted:
            return "Не завершённые"
        }
    }
}

// MARK: - UITableViewDelegate

extension FiltersViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let selected = filters[indexPath.row]
        
        onFilterSelected?(selected.filter)
        
        dismiss(animated: true)
    }
}

// MARK: - UITableViewDataSource

extension FiltersViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { filters.count }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath ) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: FilterCell.identifier, for: indexPath) as? FilterCell else {
            return UITableViewCell()
        }
        
        let item = filters[indexPath.row]
        let shouldShowMark: Bool

        switch selectedFilter {
        case .completed, .uncompleted, .today:
            shouldShowMark = item.filter == selectedFilter
        case .all:
            shouldShowMark = false
        }
        
        let isLastCell: Bool = (indexPath.row == filters.count - 1)

        cell.configure(title: item.title, showsCheckmark: shouldShowMark, isLastCell: isLastCell)
        cell.backgroundColor = .customGray.withAlphaComponent(0.1)
        return cell
    }
}
