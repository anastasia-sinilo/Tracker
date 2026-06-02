import UIKit

final class StatisticsViewController: UIViewController {
    
    private let trackerRecordStore: TrackerRecordStore

    private var completedCount: Int = 0
    
    //MARK: - UI Elements
    
    private lazy var emptyStatisticImage: UIImageView = {
        let image = UIImageView()
        image.image = UIImage(resource: .statisticsPlaceholder)
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    private lazy var emptyStatisticLabel: UILabel = {
        let label = UILabel()
        label.text = "Анализировать пока нечего"
        label.font = UIFont.systemFont(ofSize: 12, weight: .regular)
        label.textColor = .customBlack
        label.textAlignment = .center
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.backgroundColor = .customWhite
        tableView.isScrollEnabled = false
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(StatisticsCell.self, forCellReuseIdentifier: StatisticsCell.identifier)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupNavigationBar()
        setupUI()
        
        loadStatistics()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        loadStatistics()
    }
    
    //MARK: - init
    
    init(trackerRecordStore: TrackerRecordStore) {
        self.trackerRecordStore = trackerRecordStore
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    
    private func setupNavigationBar() {
        title = "Статистика"
        navigationController?.navigationBar.prefersLargeTitles = true
        navigationItem.largeTitleDisplayMode = .always
    }
    
    private func setupUI() {
        view.addSubview(emptyStatisticImage)
        view.addSubview(emptyStatisticLabel)
        view.addSubview(tableView)
        
        NSLayoutConstraint.activate([
            emptyStatisticImage.heightAnchor.constraint(equalToConstant: 80),
            emptyStatisticImage.widthAnchor.constraint(equalToConstant: 80),
            emptyStatisticImage.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            emptyStatisticImage.centerYAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerYAnchor),
            
            emptyStatisticLabel.heightAnchor.constraint(equalToConstant: 18),
            emptyStatisticLabel.topAnchor.constraint(equalTo: emptyStatisticImage.bottomAnchor, constant: 8),
            emptyStatisticLabel.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            emptyStatisticLabel.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            tableView.heightAnchor.constraint(equalToConstant: 90),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 70),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    //MARK: - Other functions
    
    private func loadStatistics() {
        completedCount = trackerRecordStore.fetchRecords().count

        let isEmpty = completedCount == 0

        tableView.isHidden = isEmpty
        emptyStatisticImage.isHidden = !isEmpty
        emptyStatisticLabel.isHidden = !isEmpty
        
        tableView.reloadData()
        tableView.layoutIfNeeded()
    }
}

//MARK: - UITableViewDelegate

extension StatisticsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 90 }
}
//MARK: - UITableViewDataSource

extension StatisticsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { 1 }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: StatisticsCell.identifier, for: indexPath) as? StatisticsCell
        else {
            return UITableViewCell()
        }
        cell.configure(completedCount: completedCount)
        return cell
    }
}
