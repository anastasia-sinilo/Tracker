import UIKit

protocol HabitCreationViewControllerDelegate: AnyObject {
    func didCreateHabit(_ tracker: Tracker, categoryName: String)
}

final class HabitCreationViewController: UIViewController {
    
    weak var delegate: HabitCreationViewControllerDelegate?
    
    private var trackerName = ""
    private var categoryName = "Важное" //временно
    private var schedule = "Пример текста" //временно
    
    private var menuTopToTextFieldConstraint: NSLayoutConstraint!
    private var menuTopToLabelConstraint: NSLayoutConstraint!
    
    //MARK: - UI Elements
    
    private lazy var scrollView: UIScrollView = {
        let view = UIScrollView()
        view.alwaysBounceVertical = true
        view.delaysContentTouches = false
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var contentView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название трекера"
        textField.backgroundColor = .customGray.withAlphaComponent(0.1)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var textLimitLabel: UILabel = {
        let label = UILabel()
        label.text = "Ограничение 38 символов"
        label.textColor = .customRed
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.isHidden = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var tableView: UITableView = {
        let view = UITableView()
        view.separatorStyle = .singleLine
        view.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        view.layer.cornerRadius = 16
        view.isScrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(HabitCreationMenuCell.self, forCellReuseIdentifier: HabitCreationMenuCell.identifier)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    private lazy var cancelButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Отмена", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.customRed, for: .normal)
        button.backgroundColor = .clear
        button.layer.borderColor = UIColor.customRed.cgColor
        button.layer.cornerRadius = 16
        button.layer.borderWidth = 1
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(cancelButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var createButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Создать", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.customWhite, for: .normal)
        button.backgroundColor = .customGray
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
        
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая привычка"
        
        setupUI()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textField)
        contentView.addSubview(textLimitLabel)
        contentView.addSubview(tableView)
        view.addSubview(buttonsStackView)
        buttonsStackView.addArrangedSubview(cancelButton)
        buttonsStackView.addArrangedSubview(createButton)
        
        //Сдвиг меню при превышении лимита символов
        textField.delegate = self
        menuTopToTextFieldConstraint = tableView.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 24)
        menuTopToLabelConstraint = tableView.topAnchor.constraint(equalTo: textLimitLabel.bottomAnchor, constant: 24)
        menuTopToTextFieldConstraint.isActive = true
        menuTopToLabelConstraint.isActive = false
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: buttonsStackView.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            
            contentView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            contentView.topAnchor.constraint(equalTo: scrollView.topAnchor),
            contentView.bottomAnchor.constraint(equalTo: scrollView.bottomAnchor),
            contentView.leadingAnchor.constraint(equalTo: scrollView.leadingAnchor),
            contentView.trailingAnchor.constraint(equalTo: scrollView.trailingAnchor),
            
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            textLimitLabel.heightAnchor.constraint(equalToConstant: 22),
            textLimitLabel.topAnchor.constraint(equalTo: textField.bottomAnchor, constant: 8),
            textLimitLabel.leadingAnchor.constraint(equalTo: textField.leadingAnchor),
            textLimitLabel.trailingAnchor.constraint(equalTo: textField.trailingAnchor),
            
            tableView.heightAnchor.constraint(equalToConstant: 150),
            tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
            ])
    }
    
    //MARK: - Actions
    
    @objc private func textFieldChanged() {
        
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        print("createButtonTapped")
    }
}

//MARK: - TextFieldDelegate

extension HabitCreationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let textRange = Range(range, in: currentText) else { return false }
        
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        let maxTextLength = updatedText.count > 38
        textLimitLabel.isHidden = !maxTextLength
        
        menuTopToTextFieldConstraint.isActive = !maxTextLength
        menuTopToLabelConstraint.isActive = maxTextLength
        
        trackerName = updatedText
                
        return updatedText.count <= 38
    }
}

//MARK: - TableViewDelegate

extension HabitCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
            tableView.deselectRow(at: indexPath, animated: true)
            
            if indexPath.row == 0 {
                print("Category screen")
            } else {
                print("Schedule screen")
            }
        }
}

//MARK: - TableViewDataSourse

extension HabitCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitCreationMenuCell.identifier, for: indexPath) as? HabitCreationMenuCell else { return UITableViewCell() }
        
        indexPath.row == 0 ? cell.dataForMenuCellConfig(title: "Категория", subtitle: categoryName) : cell.dataForMenuCellConfig(title: "Расписание", subtitle: schedule)
            
        cell.backgroundColor = .customGray.withAlphaComponent(0.1)
        
        return cell
    }
}

