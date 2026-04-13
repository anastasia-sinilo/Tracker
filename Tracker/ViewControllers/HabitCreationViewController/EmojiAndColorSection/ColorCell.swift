import UIKit

final class ColorCell: UICollectionViewCell {
    
    static let identifier = "ColorCell"
    
    //MARK: - UI Elements
    
    private var image: UIView = {
        let image = UIView()
        image.layer.cornerRadius = 8
        image.contentMode = .scaleAspectFit
        image.translatesAutoresizingMaskIntoConstraints = false
        return image
    }()
    
    //MARK: - init
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        setupUI()
    }
    
    required init?(coder: NSCoder) { fatalError() }
    
    //MARK: - UI Setup
    
    private func setupUI() {
        contentView.addSubview(image)
        
        NSLayoutConstraint.activate([
            image.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 6),
            image.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -6),
            image.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 6),
            image.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -6)
        ])
        contentView.layer.cornerRadius = 8
    }
    
    //MARK: - Other functions
    
    func dataForColorCell(color: UIColor, isSelected: Bool) {
        image.backgroundColor = color
        
        if isSelected {
            contentView.layer.borderWidth = 3
            contentView.layer.borderColor = color.withAlphaComponent(0.3).cgColor
        } else {
            contentView.layer.borderWidth = 0
        }
    }
}
