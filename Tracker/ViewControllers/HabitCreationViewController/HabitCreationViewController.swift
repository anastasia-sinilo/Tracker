import UIKit
import os

protocol HabitCreationViewControllerDelegate: AnyObject {
    func dataForHabitCreation(_ tracker: Tracker, categoryName: String)
}

final class HabitCreationViewController: UIViewController {
    
    private let logger = Logger(subsystem: "com.anastasia-sinilo.Tracker.habits", category: "HabitCreation")
    
    weak var delegate: HabitCreationViewControllerDelegate?
    
    private var trackerName = ""
    //private var categoryName = "Важное" //временно
    private var selectedCategory: TrackerCategory?
    private var schedule = ""
    private var selectedEmoji: String?
    private var selectedColor: UIColor?
    
    private var selectedDays: [WeekDay] = []
    
    private let allEmojis: [String] = ["🙂", "😻", "🌺", "🐶", "❤️", "😱",
                                       "😇", "😡", "🥶", "🤔", "🙌", "🍔",
                                       "🥦", "🏓", "🥇", "🎸", "🏝", "😪"]
    
    private let colors: [UIColor] = [.customRed2, .customOrange, .customBlue2, .customViolet, .customGreen, .customPink,
                                     .customPink3, .customBlue3, .customGreen2, .customViolet2, .customRed3, .customPink2,
                                     .customOrange2, .customBlue4, .customViolet5, .customViolet3, .customViolet4, .customGreen3]
    
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
        view.layer.cornerRadius = 16
        view.isScrollEnabled = false
        view.translatesAutoresizingMaskIntoConstraints = false
        view.register(HabitCreationMenuCell.self, forCellReuseIdentifier: HabitCreationMenuCell.identifier)
        view.delegate = self
        view.dataSource = self
        return view
    }()
    
    private lazy var emojiAndColorCollectionView: UICollectionView = {
        let view = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
        view.isScrollEnabled = false
        view.backgroundColor = .clear
        view.register(EmojiCell.self, forCellWithReuseIdentifier: EmojiCell.identifier)
        view.register(ColorCell.self, forCellWithReuseIdentifier: ColorCell.identifier)
        view.register(EmojiAndColorHeader.self, forSupplementaryViewOfKind: UICollectionView.elementKindSectionHeader, withReuseIdentifier: EmojiAndColorHeader.identifier)
        view.delegate = self
        view.dataSource = self
        view.translatesAutoresizingMaskIntoConstraints = false
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
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(createButtonTapped), for: .touchUpInside)
        return button
        
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Новая привычка"
        view.backgroundColor = .customWhite
        
        setupUI()
        updateCreateButton()
        
        //скрытие клавиатуры
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
        tapGesture.cancelsTouchesInView = false
        view.addGestureRecognizer(tapGesture)
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(scrollView)
        scrollView.addSubview(contentView)
        contentView.addSubview(textField)
        contentView.addSubview(textLimitLabel)
        contentView.addSubview(tableView)
        contentView.addSubview(emojiAndColorCollectionView)
        
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
            //tableView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            emojiAndColorCollectionView.heightAnchor.constraint(equalToConstant: 500),
            emojiAndColorCollectionView.topAnchor.constraint(equalTo: tableView.bottomAnchor, constant: 32),
            emojiAndColorCollectionView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            emojiAndColorCollectionView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            emojiAndColorCollectionView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            
            buttonsStackView.heightAnchor.constraint(equalToConstant: 60),
            buttonsStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            buttonsStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            buttonsStackView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor)
        ])
    }
    
    //MARK: - Actions
    
    @objc private func textFieldChanged() {
        trackerName = textField.text ?? ""
        updateCreateButton()
    }
    
    @objc private func cancelButtonTapped() {
        dismiss(animated: true)
    }
    
    @objc private func createButtonTapped() {
        guard let color = selectedColor, let emoji = selectedEmoji else { return }
        
        let trackerName = trackerName
        //let categoryName = categoryName
        guard let categoryName = selectedCategory?.categoryTittle else { return }
        
        let newHabit = Tracker(
            id: UUID(),
            title: trackerName,
            color: color,
            emoji: emoji,
            schedule: selectedDays)
        
        delegate?.dataForHabitCreation(newHabit, categoryName: categoryName)
        presentingViewController?.dismiss(animated: true)
    }
    
    @objc private func hideKeyboard() {
        view.endEditing(true)
    }
    
    
    //MARK: - Other functions
    
    private func updateCreateButton() {
        let isNameValid = !trackerName.isEmpty
        let isScheduleSelected = !selectedDays.isEmpty
        let isEmojiSelected = selectedEmoji != nil
        let isColorSelected = selectedColor != nil
        let isCategorySelected = selectedCategory != nil
        
        let isEnabled: Bool = isNameValid && isScheduleSelected && isEmojiSelected && isColorSelected && isCategorySelected
        createButton.isEnabled = isEnabled
        createButton.backgroundColor = isEnabled ? .customBlack : .customGray
    }
}

//MARK: - TextFieldDelegate (ограничение длины)

extension HabitCreationViewController: UITextFieldDelegate {
    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        let currentText = textField.text ?? ""
        
        guard let textRange = Range(range, in: currentText) else { return false }
        
        let textLengthLimit = 38
        let updatedText = currentText.replacingCharacters(in: textRange, with: string)
        
        let maxTextLength = updatedText.count > textLengthLimit
        textLimitLabel.isHidden = !maxTextLength
        
        menuTopToTextFieldConstraint.isActive = !maxTextLength
        menuTopToLabelConstraint.isActive = maxTextLength
        
        return updatedText.count <= textLengthLimit
    }
}

//MARK: - TableViewDelegate (высота ячеек и тапы по ним)

extension HabitCreationViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { return 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        if indexPath.row == 0 {
            //logger.info("Category screen")
            guard let appDelegate = UIApplication.shared.delegate as? AppDelegate else { return }
            
            let categoryStore = TrackerCategoryStore(context: appDelegate.context)
            let viewModel = CategoriesViewModel(categoryStore: categoryStore, selectedCategory: selectedCategory)
            let vc = CategoriesViewController(viewModel: viewModel)
            
            vc.delegate = self
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let scheduleViewController = ScheduleViewController()
            scheduleViewController.delegate = self
            scheduleViewController.chosenDays = self.selectedDays
            let navigationController = UINavigationController(rootViewController: scheduleViewController)
            present(navigationController, animated: true)
        }
    }
}

//MARK: - TableViewDataSource (кол-во ячеек и их тип)

extension HabitCreationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int { return 2 }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: HabitCreationMenuCell.identifier, for: indexPath) as? HabitCreationMenuCell else { return UITableViewCell() }
        
        indexPath.row == 0
        ? cell.dataForMenuCellConfig(title: "Категория", subtitle: selectedCategory?.categoryTittle ?? "")//categoryName)
        : cell.dataForMenuCellConfig(title: "Расписание", subtitle: schedule)
        
        //скрытие нижнего сепаратора
        if indexPath.row == 1 {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: .greatestFiniteMagnitude)
        } else {
            cell.separatorInset = UIEdgeInsets(top: 0, left: 16, bottom: 0, right: 16)
        }
        
        cell.backgroundColor = .customGray.withAlphaComponent(0.1)
        
        return cell
    }
}

//MARK: - ScheduleViewControllerDelegate (перенос дней недели и отображение их в сабтайтле)

extension HabitCreationViewController: ScheduleViewControllerDelegate {
    func didSelectWeekDays(days: [WeekDay]) {
        self.selectedDays = days
        
        if days.isEmpty {
            schedule = ""
        } else if days.count == 7 {
            schedule = "Каждый день"
        } else {
            let orderedWeekDays: [WeekDay] = [.monday, .tuesday, .wednesday, .thursday, .friday, .saturday, .sunday]
            let sortedDays = orderedWeekDays.filter { days.contains($0) }.map { $0.shortVersionTitle }.joined(separator: ", ")
            schedule = "\(sortedDays)"
        }
        updateCreateButton()
        tableView.reloadData()
    }
}

//MARK: - EmojiAndColorDelegate (выбор ячеек)

extension HabitCreationViewController: UICollectionViewDelegate {
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let section = Section(rawValue: indexPath.section) else { return }
        
        switch section {
        case .emoji:
            let emoji = allEmojis[indexPath.item]
            selectedEmoji = selectedEmoji == emoji ? nil : emoji
            
        case .color:
            let color = colors[indexPath.item]
            selectedColor = selectedColor == color ? nil : color
        }
        collectionView.reloadData()
        updateCreateButton()
    }
}

//MARK: - EmojiAndColorDataSource (кол-во секций и ячеек)

extension HabitCreationViewController: UICollectionViewDataSource {
    func numberOfSections(in collectionView: UICollectionView) -> Int { return Section.allCases.count }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        guard let section = Section(rawValue: section) else { return 0 }
        
        switch section {
        case .emoji:
            return allEmojis.count
        case .color:
            return colors.count
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let section = Section(rawValue: indexPath.section) else { return UICollectionViewCell() }
        
        switch section {
        case .emoji:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: EmojiCell.identifier, for: indexPath) as? EmojiCell else { return UICollectionViewCell() }
            
            let emoji = allEmojis[indexPath.item]
            cell.dataForEmojiCellConfig(emoji, isSelected: emoji == selectedEmoji)
            return cell
            
        case .color:
            guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ColorCell.identifier, for: indexPath) as? ColorCell else { return UICollectionViewCell() }
            
            let color = colors[indexPath.item]
            cell.dataForColorCell(color: color, isSelected: color == selectedColor)
            return cell
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        if kind == UICollectionView.elementKindSectionHeader {
            guard let header = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: EmojiAndColorHeader.identifier, for: indexPath) as? EmojiAndColorHeader else { return UICollectionReusableView() }
            
            let section = Section(rawValue: indexPath.section)
            header.titleLabel.text = section?.title
            return header
        }
        return UICollectionReusableView()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: 40)
    }
}

//MARK: - FlowLayout (размеры ячеек и тп)

extension HabitCreationViewController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 16, left: 19, bottom: 16, right: 19)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        let totalHorizontalPadding: CGFloat = 19 + 5 * 5 + 19
        let availableWidth = collectionView.bounds.width - totalHorizontalPadding
        let cellWidth = floor(availableWidth / 6)
        
        return CGSize(width: cellWidth, height: cellWidth)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 5
    }
}

//MARK: - CategorySelectionDelegate

extension HabitCreationViewController: CategorySelectionDelegate {
    func didSelectCategory(_ category: TrackerCategory) {
        selectedCategory = category
        tableView.reloadData()
        updateCreateButton()
    }
}
