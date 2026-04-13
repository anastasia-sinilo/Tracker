import UIKit

final class EmojiAndColorHeader: UICollectionReusableView {
    
    static let identifier = "Header"
    
    //MARK: - UI Elements
    
    let titleLabel: UILabel = {
        let label = UILabel()
        label.font = .boldSystemFont(ofSize: 19)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 19),
            titleLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
}
