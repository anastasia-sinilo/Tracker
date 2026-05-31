import UIKit

final class CategoriesViewController: UIViewController {
    
    weak var delegate: CategorySelectionDelegate?
    
    //MARK: - Properties
    
    private let viewModel: CategoriesViewModel
    private var tableViewHeightConstraint: NSLayoutConstraint?
    
    //MARK: - UI Elements
    
    private lazy var tableView: UITableView = {
        let tableView = UITableView()
        tableView.clipsToBounds = true
        tableView.layer.cornerRadius = 16
        tableView.backgroundColor = .clear
        tableView.separatorStyle = .none
        tableView.tableHeaderView = UIView(frame: .zero)
        tableView.tableFooterView = UIView(frame: .zero)
        tableView.isScrollEnabled = true
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.translatesAutoresizingMaskIntoConstraints = false
        return tableView
    }()
    
    private lazy var placeholderImage: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .emptyTrackerList)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var placeholderLabel: UILabel = {
        let label = UILabel()
        label.text = """
Привычки и события можно 
объединить по смыслу
"""
        label.textColor = .customBlack
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textAlignment = .center
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var addCategoryButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Добавить категорию", for: .normal)
        button.setTitleColor(.customWhite, for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.backgroundColor = .customBlack
        button.layer.cornerRadius = 16
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(addCategoryButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - init
    
    init(viewModel: CategoriesViewModel) {
        self.viewModel = viewModel
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Категория"
        view.backgroundColor = .systemBackground
        
        setupUI()
        setupBindings()
        
        viewModel.fetchCategories()
    }
    
    //MARK: - Actions
    
    @objc private func addCategoryButtonTapped() {
        let vc = NewCategoryViewController()
        
        vc.onCategoryCreated = { [weak self] title in
            self?.viewModel.addCategory(title: title)
        }
        navigationController?.pushViewController(vc, animated: true)
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(tableView)
        view.addSubview(placeholderImage)
        view.addSubview(placeholderLabel)
        view.addSubview(addCategoryButton)
        
        //Динамическое расширение таблицы
        tableViewHeightConstraint = tableView.heightAnchor.constraint(equalToConstant: 0)
        tableViewHeightConstraint?.isActive = true
        
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            placeholderImage.heightAnchor.constraint(equalToConstant: 80),
            placeholderImage.widthAnchor.constraint(equalToConstant: 80),
            placeholderImage.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            placeholderImage.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            
            placeholderLabel.heightAnchor.constraint(equalToConstant: 36),
            placeholderLabel.topAnchor.constraint(equalTo: placeholderImage.bottomAnchor, constant: 8),
            placeholderLabel.centerXAnchor.constraint(equalTo: placeholderImage.centerXAnchor),
            
            addCategoryButton.heightAnchor.constraint(equalToConstant: 60),
            addCategoryButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            addCategoryButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            addCategoryButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16)
        ])
    }
    
    //MARK: - Other functions
    
    private func setupBindings() {
        viewModel.onCategoriesChanged = { [weak self] in
            guard let self else { return }
            
            self.tableView.reloadData()
            
            let isEmpty = self.viewModel.categories.isEmpty
            self.placeholderImage.isHidden = !isEmpty
            self.placeholderLabel.isHidden = !isEmpty
            self.tableView.isHidden = isEmpty
            
            //В макете Figma не показано поведение при большом кол-ве категорий, поэтому сделано динамическое расширение таблицы и ее скрол
            let contentHeight = CGFloat(self.viewModel.numberOfCategories()) * 75
            let maxHeight = view.frame.height * 0.65
            self.tableViewHeightConstraint?.constant = min(contentHeight, maxHeight)
        }
    }
}

//MARK: - TableViewDataSource

extension CategoriesViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        viewModel.numberOfCategories()
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as? CategoryCell else {
            return UITableViewCell()
        }
        
        let category = viewModel.category(at: indexPath.row)
        let isLastCell = indexPath.row == viewModel.numberOfCategories() - 1
        
        cell.dataForCellConfig(title: category.categoryTittle, isSelected: viewModel.isSelected(at: indexPath.row), isLastCell: isLastCell)
        
        return cell
    }
}

//MARK: - UITableViewDelegate

extension CategoriesViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat { 75 }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        viewModel.selectCategory(at: indexPath.row)
        
        let category = viewModel.category(at: indexPath.row)
        
        delegate?.didSelectCategory(category)
        navigationController?.popViewController(animated: true)
    }
}

//MARK: - Меню и алерт удаления

extension CategoriesViewController {
    func tableView(_ tableView: UITableView, contextMenuConfigurationForRowAt indexPath: IndexPath, point: CGPoint) -> UIContextMenuConfiguration? {
        UIContextMenuConfiguration(identifier: nil, previewProvider: nil) { _ in
            
            let editAction = UIAction(title: "Редактировать") { [weak self] _ in
                guard let self else { return }
                
                let category = self.viewModel.category(at: indexPath.row)
                let vc = EditCategoryViewController(categoryTitle: category.categoryTittle)
                
                vc.onCategoryEdited = { [weak self] newTitle in
                    self?.viewModel.updateCategory(at: indexPath.row, newTitle: newTitle)
                }
                self.navigationController?.pushViewController(vc, animated: true)
            }
            
            let deleteAction = UIAction(title: "Удалить", attributes: .destructive) { [weak self] _ in
                self?.showDeleteAlert(indexPath: indexPath)
            }
            
            return UIMenu(children: [editAction, deleteAction])
        }
    }
    
    private func showDeleteAlert(indexPath: IndexPath) {
        
        let alert = UIAlertController(title: "Эта категория точно не нужна?", message: nil, preferredStyle: .actionSheet)
        
        let deleteAction = UIAlertAction(title: "Удалить", style: .destructive) { [weak self] _ in
            self?.viewModel.deleteCategory(at: indexPath.row)
        }
        
        let cancelAction = UIAlertAction(title: "Отмена", style: .cancel)
        
        alert.addAction(deleteAction)
        alert.addAction(cancelAction)
        
        present(alert, animated: true)
    }
}
