//
//  FilterCell.swift
//  PocketOfTimev3
//
//  Created by Kelly Chui on 24/10/25.
//


import UIKit

// This is the custom cell for our new filter "pills"
class FilterCell: UICollectionViewCell {
    
    static let reuseID = "FilterCell"
    
    // The label that displays the filter title (e.g., "Toddler")
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .center
        label.font = .systemFont(ofSize: 14, weight: .medium)
        return label
    }()
    
    // We override 'isSelected' to change the cell's appearance when tapped.
    override var isSelected: Bool {
        didSet {
            updateAppearance()
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        // Style the cell itself
        layer.cornerRadius = 16
        layer.borderWidth = 1.0
        
        contentView.addSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 8),
            titleLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            titleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16)
        ])
        
        // Set the initial appearance
        updateAppearance()
    }
    
    // This function configures the cell with a title
    func configure(with title: String) {
        titleLabel.text = title
    }
    
    // This updates the UI based on whether the cell is selected or not
    private func updateAppearance() {
        if isSelected {
            // Selected state
            backgroundColor = .systemBlue
            titleLabel.textColor = .white
            layer.borderColor = UIColor.systemBlue.cgColor
        } else {
            // Deselected state
            backgroundColor = .systemGray6
            titleLabel.textColor = .label
            layer.borderColor = UIColor.systemGray4.cgColor
        }
    }
}