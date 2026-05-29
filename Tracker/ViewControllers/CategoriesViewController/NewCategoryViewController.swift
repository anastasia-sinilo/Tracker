import UIKit

final class NewCategoryViewController: UIViewController {
    
    //MARK: - Properties
    
    var onCategoryCreated: ((String) -> Void)?
    
    private var categoryName: String = ""
    
    //MARK: - UI Elements
    
    private lazy var textField: UITextField = {
        let textField = UITextField()
        textField.placeholder = "Введите название категории"
        textField.backgroundColor = .customGray.withAlphaComponent(0.1)
        textField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 16, height: 0))
        textField.leftViewMode = .always
        textField.layer.cornerRadius = 16
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.addTarget(self, action: #selector(textFieldChanged), for: .editingChanged)
        return textField
    }()
    
    private lazy var doneButton: UIButton = {
        let button = UIButton(type: .system)
        button.setTitle("Готово", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 16, weight: .medium)
        button.setTitleColor(.customWhite, for: .normal)
        button.backgroundColor = .customGray
        button.layer.cornerRadius = 16
        button.isEnabled = false
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(doneButtonTapped), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        title = "Новая категория"
        view.backgroundColor = .systemBackground
        
        setupUI()
    }
    
    //MARK: - Actions
    
    @objc private func textFieldChanged() {
        categoryName = textField.text ?? ""
        let isEnabled = !categoryName.isEmpty
        
        doneButton.isEnabled = !categoryName.isEmpty
        doneButton.backgroundColor = isEnabled ? .customBlack : .customGray
    }
    
    @objc private func doneButtonTapped() {
        onCategoryCreated?(categoryName)
        navigationController?.popViewController(animated: true)
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        view.addSubview(textField)
        view.addSubview(doneButton)
        
        NSLayoutConstraint.activate([
            textField.heightAnchor.constraint(equalToConstant: 75),
            textField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            textField.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
            textField.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
            
            doneButton.heightAnchor.constraint(equalToConstant: 60),
            doneButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -16),
            doneButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            doneButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }
}
