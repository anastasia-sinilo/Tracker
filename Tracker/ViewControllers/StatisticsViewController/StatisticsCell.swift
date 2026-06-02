import UIKit

final class StatisticsCell: UITableViewCell {

    static let identifier = "StatisticsCell"

    
    //MARK: - UI Elements
    
    private lazy var containerView = {
        let view = UIView()
        view.clipsToBounds = true
        view.layer.cornerRadius = 16
        view.backgroundColor = .customWhite
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var valueLabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: 34, weight: .bold)
        label.textAlignment = .left
        label.textColor = .customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel = {
        let label = UILabel()
        label.text = "Трекеров завершено"
        label.font = UIFont.systemFont(ofSize: 14, weight: .regular)
        label.textAlignment = .left
        label.textColor = .customBlack
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let gradientLayer = CAGradientLayer()
    private let borderMask = CAShapeLayer()

    //MARK: - init
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        setupUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    //MARK: - UI Setup
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        gradientLayer.frame = containerView.bounds
        
        borderMask.path = UIBezierPath(roundedRect: containerView.bounds.insetBy(dx: 1.5, dy: 1.5),
                                       cornerRadius: 16).cgPath
        borderMask.fillColor = UIColor.clear.cgColor
        borderMask.strokeColor = UIColor.black.cgColor
        borderMask.lineWidth = 1
        
        gradientLayer.mask = borderMask
    }

    private func setupUI() {
        selectionStyle = .none
        backgroundColor = .clear
        
        contentView.addSubview(containerView)
        
        gradientLayer.colors = [UIColor.systemRed.cgColor, UIColor.systemGreen.cgColor, UIColor.systemBlue.cgColor]
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)

        containerView.layer.addSublayer(gradientLayer)
        containerView.addSubview(valueLabel)
        containerView.addSubview(titleLabel)

        NSLayoutConstraint.activate([
            containerView.topAnchor.constraint(equalTo: contentView.topAnchor),
            containerView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            containerView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            containerView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            
            valueLabel.heightAnchor.constraint(equalToConstant: 41),
            valueLabel.topAnchor.constraint(equalTo: containerView.topAnchor, constant: 12),
            valueLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12),
            
            titleLabel.heightAnchor.constraint(equalToConstant: 18),
            titleLabel.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: containerView.leadingAnchor, constant: 12)
        ])
    }
    
    //MARK: - Other functions
    
    func configure(completedCount: Int) {
        valueLabel.text = "\(completedCount)"
    }
}
