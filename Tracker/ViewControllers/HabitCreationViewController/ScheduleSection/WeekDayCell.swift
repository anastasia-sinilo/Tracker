import UIKit

final class WeekDayCell: UITableViewCell {
    
    static let identifier = "WeekDayCell"
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.backgroundColor = .clear
        label.font = .systemFont(ofSize: 17, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private let toggleSwitch = UISwitch()
    
    var onSwitchChanged: ((Bool) -> Void)?
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        selectionStyle = .none
        
        toggleSwitch.addTarget(self, action: #selector(switchChanged), for: .valueChanged)
        toggleSwitch.onTintColor = .customBlue
        
        contentView.addSubview(titleLabel)
        contentView.addSubview(toggleSwitch)
        
        toggleSwitch.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            titleLabel.heightAnchor.constraint(equalToConstant: 22),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor,constant: 16),
            titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            
            toggleSwitch.heightAnchor.constraint(equalToConstant: 31),
            toggleSwitch.widthAnchor.constraint(equalToConstant: 51),
            toggleSwitch.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            toggleSwitch.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor)
        ])
    }
    
    func dataForScheduleConfig(with day: WeekDay, isOn: Bool) {
        titleLabel.text = day.fullVersionTitle
        toggleSwitch.isOn = isOn
    }
    
    @objc private func switchChanged() {
        onSwitchChanged?(toggleSwitch.isOn)
    }
}

