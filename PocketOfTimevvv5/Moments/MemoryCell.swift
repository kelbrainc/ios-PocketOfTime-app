//
//  MemoryCell.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import UIKit

// This is the custom cell for our Collection View.
class MemoryCell: UICollectionViewCell {
    
    // A unique string identifier for dequeuing the cell
    static let reuseID = "MemoryCell"
    
    // send a "like button was tapped"
    // message back to the view controller without needing a full delegate protocol.
    var likeButtonTapped: (() -> Void)?
    
    // --- UI Components ---
    
    private lazy var memoryImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        // If no image, show a placeholder
        imageView.image = UIImage(systemName: "photo") 
        imageView.tintColor = .systemGray4
        imageView.backgroundColor = .systemGray6
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 14)
        label.numberOfLines = 2 // Show max 2 lines
        return label
    }()
    
    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 12, weight: .medium)
        label.textColor = .secondaryLabel
        return label
    }()
    
    // The heart button for liking a memory.
    private lazy var likeButton: UIButton = {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(handleLikeTapped), for: .touchUpInside)
        return button
    }()
    
    
    // --- Initializer ---
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // --- Setup ---
    
    private func setupUI() {
        // Basic cell styling
        contentView.backgroundColor = .systemBackground
        contentView.layer.cornerRadius = 10
        contentView.layer.masksToBounds = true
        
        // Shadow (on the cell itself, not the content)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.1
        layer.shadowOffset = CGSize(width: 0, height: 2)
        layer.shadowRadius = 4
        layer.masksToBounds = false
        
        
        // Add subviews to the cell's content view
        contentView.addSubview(memoryImageView)
        contentView.addSubview(textLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(likeButton)
        
        // --- Constraints ---
        NSLayoutConstraint.activate([
            // Image View (takes up the top half)
            memoryImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            memoryImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            memoryImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            memoryImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.6), // 60% of height
            
            // Date Label (at the bottom)
            dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8),
            dateLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            
            // Text Label (between image and date)
            textLabel.topAnchor.constraint(equalTo: memoryImageView.bottomAnchor, constant: 8),
            textLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 8),
            textLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            textLabel.bottomAnchor.constraint(lessThanOrEqualTo: dateLabel.topAnchor, constant: -4),
            
            // like button in the bottom-right corner.
            likeButton.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -4),
            likeButton.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -8),
            likeButton.widthAnchor.constraint(equalToConstant: 44),
            likeButton.heightAnchor.constraint(equalToConstant: 44)
        ])
    }
    
    // The action that fires when the like button is tapped.
    @objc private func handleLikeTapped() {
        // When tapped, it calls the closure that the view controller will implement.
        likeButtonTapped?()
    }
    
    
    // This function is called by the Collection View to set up the cell's content
    func configure(with memory: Memory) {
        textLabel.text = memory.text
        
        // Format the date
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        dateLabel.text = formatter.string(from: memory.date)
        
        // Set the image
        if let imageData = memory.imageData, let image = UIImage(data: imageData) {
            memoryImageView.image = image
            memoryImageView.tintColor = nil // Clear tint if we have a real image
        } else {
            // Show placeholder
            memoryImageView.image = UIImage(systemName: "photo")
            memoryImageView.tintColor = .systemGray4
        }
        
        // Configure the heart button's appearance based on the memory's 'isLiked' state.
        let imageName = memory.isLiked ? "heart.fill" : "heart"
        let color: UIColor = memory.isLiked ? .systemPink : .secondaryLabel
        let config = UIImage.SymbolConfiguration(pointSize: 18)
        let image = UIImage(systemName: imageName, withConfiguration: config)
                
        likeButton.setImage(image, for: .normal)
        likeButton.tintColor = color
    }
    
    // Reset cell on reuse to prevent old data from showing
    override func prepareForReuse() {
        super.prepareForReuse()
        memoryImageView.image = nil
        textLabel.text = nil
        dateLabel.text = nil
        likeButton.setImage(nil, for: .normal)
    }
}
