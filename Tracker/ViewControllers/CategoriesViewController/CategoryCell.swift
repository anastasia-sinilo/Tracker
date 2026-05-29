import UIKit

final class CategoryCell: UITableViewCell {
    
    static let identifier: String = "CategoryCell"
    
    //MARK: - UI Elements
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .regular)
        label.textColor = .customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var markImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .mark)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .customGray.withAlphaComponent(0.4)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    //MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError()
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(markImageView)
        contentView.addSubview(separatorView)
        
        backgroundColor = .clear
        contentView.backgroundColor = .customGray.withAlphaComponent(0.1)
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            markImageView.heightAnchor.constraint(equalToConstant: 24),
            markImageView.widthAnchor.constraint(equalToConstant: 24),
            markImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            markImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 1),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
            ])
    }
    
    //MARK: - Other functions
    
    func dataForCellConfig(title: String, isSelected: Bool, isLastCell: Bool) {
        titleLabel.text = title
        markImageView.isHidden = !isSelected
        separatorView.isHidden = isLastCell
    }
}
