import UIKit

protocol ScheduleViewControllerDelegate: AnyObject {
    func didSelectWeekDays(days: [WeekDay])
}

final class ScheduleViewController: UIViewController {
    
    weak var delegate: ScheduleViewControllerDelegate?
    
    private let allWeekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
    var chosenDays: [WeekDay] = []
    
    //MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.tableHeaderView = UIView(frame: .zero)
        view.tableFooterView = UIView(frame: .zero)
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.isScrollEnabled = false
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(WeekDayCell.self, forCellReuseIdentifier: WeekDayCell.identifier)
        return view
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .black
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Расписание"
        view.backgroundColor = .customWhite
        
        setupUI()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            tableView.heightAnchor.constraint(equalToConstant: 525),
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    //MARK: - Actions
    
    @objc
    private func doneButtonTapped() {
        delegate?.didSelectWeekDays(days: chosenDays)
        dismiss(animated: true)
    }
}

//MARK: - TableViewDelegate (высота ячейки)

extension ScheduleViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
}

//MARK: - TableViewDataSource (кол-во ячеек и их тип)

extension ScheduleViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return allWeekDays.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: WeekDayCell.identifier, for: indexPath) as? WeekDayCell else { return UITableViewCell() }
        
        let day = allWeekDays[indexPath.row]
        let isSelectedDay = chosenDays.contains(day)
        
        cell.dataForScheduleConfig(with: day, isOn: isSelectedDay)
        cell.onSwitchChanged = { [weak self] isOn in
            guard let self else { return }
            
            if isOn {
                if !self.chosenDays.contains(day) {
                    self.chosenDays.append(day)
                }
            } else {
                self.chosenDays.removeAll { $0 == day }
            }
        }
        //скрытие нижнего сепаратора
        if indexPath.row == allWeekDays.count - 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.backgroundColor = .customGray.withAlphaComponent(0.1)
        return cell
    }
}
