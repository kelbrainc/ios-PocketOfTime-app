//
//  EmptyStateCell.swift
//  PocketOfTimevv3
//
//  Created by Kelly Chui on 30/10/25.
//


import UIKit

class EmptyStateCell: UICollectionViewCell {
    
    static let reuseID = "EmptyStateCell"
    
    private lazy var messageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//        let glassEffect = UIGlassEffect()
//        let effectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        
        contentView.addSubview(visualEffectView)
        contentView.addSubview(messageLabel)
        
        contentView.layer.cornerRadius = 24
        contentView.clipsToBounds = true
        
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: contentView.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: contentView.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            
            messageLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            messageLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            messageLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20)
        ])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(with message: String) {
        messageLabel.text = message
    }
}
