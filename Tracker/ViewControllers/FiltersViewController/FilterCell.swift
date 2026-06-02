import UIKit

final class FilterCell: UITableViewCell {

    static let identifier = "FilterCell"

    // MARK: - UI Elements

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.textColor = .customBlack
        label.textAlignment = .left
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    private lazy var markImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(resource: .mark)
        imageView.contentMode = .scaleAspectFit
        imageView.isHidden = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    private lazy var separatorView: UIView = {
        let view = UIView()
        view.backgroundColor = .customGray
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    // MARK: - Init

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - UI Setup

    private func setupUI() {
        contentView.addSubview(titleLabel)
        contentView.addSubview(markImageView)
        contentView.addSubview(separatorView)

        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 24),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            markImageView.widthAnchor.constraint(equalToConstant: 24),
            markImageView.heightAnchor.constraint(equalToConstant: 24),
            markImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            markImageView.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            separatorView.heightAnchor.constraint(equalToConstant: 0.5),
            separatorView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            separatorView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            separatorView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
    }

    // MARK: - Configuration

    func configure(title: String, showsCheckmark: Bool, isLastCell: Bool) {
        titleLabel.text = title
        markImageView.isHidden = !showsCheckmark
        separatorView.isHidden = isLastCell
    }
}
