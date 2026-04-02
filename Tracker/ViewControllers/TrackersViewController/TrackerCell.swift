import UIKit

final class TrackerCell: UICollectionViewCell {
    
    static let identifier = "TrackerCell"
    weak var delegate: TrackerCellDelegate?
    
    private var trackerId: UUID?
    private var indexPath: IndexPath?

    //MARK: - UI Elements
    
    private lazy var trackerCard: UIView = {
        let view = UIView()
        view.layer.cornerRadius = 16
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var emojiLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 12)
        label.backgroundColor = .customWhite.withAlphaComponent(0.3)
        label.layer.cornerRadius = 12
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customWhite
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var daysTrackerLabel: UILabel = {
        let label = UILabel()
        label.textColor = .customBlack
        label.font = .systemFont(ofSize: 12, weight: .regular)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var trackerCompletionButton: UIButton = {
        let button = UIButton(type: .system)
        button.layer.cornerRadius = 17
        button.clipsToBounds = true
        button.addTarget(self, action: #selector(trackerCompletionButtonTapped), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    //MARK: - Actions
    
    @objc private func trackerCompletionButtonTapped() {
        guard let trackerId = trackerId,
              let indexPath = indexPath else { return }
            
        delegate?.didTapComplete(trackerId: trackerId, indexPath: indexPath)
    }
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(trackerCard)
        contentView.addSubview(daysTrackerLabel)
        contentView.addSubview(trackerCompletionButton)
        trackerCard.addSubview(emojiLabel)
        trackerCard.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            trackerCard.heightAnchor.constraint(equalToConstant: 90),
            trackerCard.topAnchor.constraint(equalTo: contentView.topAnchor),
            trackerCard.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            trackerCard.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            emojiLabel.heightAnchor.constraint(equalToConstant: 24),
            emojiLabel.widthAnchor.constraint(equalToConstant: 24),
            emojiLabel.topAnchor.constraint(equalTo: trackerCard.topAnchor, constant: 12),
            emojiLabel.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            
            titleLabel.bottomAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: -12),
            titleLabel.leadingAnchor.constraint(equalTo: trackerCard.leadingAnchor, constant: 12),
            titleLabel.trailingAnchor.constraint(equalTo: trackerCard.trailingAnchor, constant: -12),
            
            daysTrackerLabel.topAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: 16),
            daysTrackerLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 12),
            daysTrackerLabel.centerXAnchor.constraint(equalTo: trackerCompletionButton.centerXAnchor),
            
            trackerCompletionButton.heightAnchor.constraint(equalToConstant: 34),
            trackerCompletionButton.widthAnchor.constraint(equalToConstant: 34),
            trackerCompletionButton.topAnchor.constraint(equalTo: trackerCard.bottomAnchor, constant: 8),
            trackerCompletionButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -12)
        ])
    }
    
    //MARK: - Other Functions
    
    func dataForCellConfig(tracker: Tracker, isCompletedTracker: Bool, completedTrackerDaysCount: Int, indexPath: IndexPath) {
        self.trackerId = tracker.id
        self.indexPath = indexPath
        
        trackerCard.backgroundColor = tracker.color
        titleLabel.text = tracker.title
        emojiLabel.text = tracker.emoji
        daysTrackerLabel.text = updateDaysTrackerLabel(completedTrackerDaysCount: completedTrackerDaysCount)
        trackerCompletionButton.tintColor = tracker.color
        trackerCompletionButton.setImage(isCompletedTracker
                                         ? UIImage(resource: .doneButton)
                                         : UIImage(resource: .plusButton), for: .normal)
    }
    
    private func updateDaysTrackerLabel(completedTrackerDaysCount: Int) -> String {
        let daysCount = completedTrackerDaysCount
        let daysText: String
        
        if daysCount == 1 {
            daysText = "день"
        } else if daysCount == 2 || daysCount == 3 || daysCount == 4 {
            daysText = "дня"
        } else {
            daysText = "дней"
        }
        return "\(daysCount) \(daysText)"
    }
}
