//
//  SpotlightCardView.swift
//  PocketOfTimevv1
//
//  Created by Kelly Chui on 26/10/25.
//


//
//  SpotlightCardView.swift
//
//  Created by YourName on CurrentDate.
//

import UIKit

class SpotlightCardView: UIView {
    
    // MARK: - UI Components
    
    private lazy var imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true // Crucial for rounded corners
        imageView.backgroundColor = .systemGray5 // Placeholder color
        return imageView
    }()
    
    private lazy var textLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17, weight: .medium)
        label.textColor = .label // Adapts to light/dark mode
        label.numberOfLines = 0 // Limit to a few lines for brevity
        label.textAlignment = .center
        return label
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
//        let glassEffect = UIGlassEffect()
//        let visualEffectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()
    
    // MARK: - Initialization
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupView() {
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = 24 // Match your activity card's corner radius
        clipsToBounds = true // Crucial for rounded corners
        
        // Add shadow to the container for a floating effect (optional, but nice)
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.15
        layer.shadowOffset = CGSize(width: 0, height: 6)
        layer.shadowRadius = 12
        
        // Add blur effect as a base for text
        addSubview(blurEffectView)
        
        // Add image view (behind text)
        addSubview(imageView)
        
        // Add text label
        addSubview(textLabel)
        
        NSLayoutConstraint.activate([
            // Blur effect fills the card
            blurEffectView.topAnchor.constraint(equalTo: topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Image view fills the card (behind the blur, if used)
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.bottomAnchor.constraint(equalTo: bottomAnchor),
            imageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            imageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            
            // Text label centered with padding
            textLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            textLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            textLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 20),
            textLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -20),
            
            // Set a fixed height for the card
            heightAnchor.constraint(equalToConstant: 220) // Adjust as needed
        ])
    }
    
    // MARK: - Configuration Methods
    
    func configure(with memory: Memory) {
        // Hide blur if image exists for better visibility
        //blurEffectView.isHidden = (memory.imageData != nil)
        
        // Configure image (if present)
        if let imageData = memory.imageData, let image = UIImage(data: imageData) {
            imageView.image = image
            imageView.alpha = 1.0 // Ensure image is visible
            textLabel.isHidden = true
            blurEffectView.isHidden = true
        } else {
            imageView.image = nil
            imageView.alpha = 0.0 // Hide image view if no image
            textLabel.text = memory.text
            textLabel.isHidden = false
            blurEffectView.isHidden = false
        }
        
        //textLabel.text = memory.text
        //textLabel.textColor = .white // Adjust text color for better contrast over images/blur
        //textLabel.backgroundColor = UIColor.black.withAlphaComponent(0.3) // Semi-transparent background for text
        textLabel.textColor = .label // Adjust text color for better contrast over images/blur
        textLabel.backgroundColor = .clear
        //textLabel.layer.cornerRadius = 10
        //textLabel.clipsToBounds = true
        textLabel.font = .systemFont(ofSize: 17, weight: .medium) // Slightly larger font for spotlight
    }
    
    func showWelcomeMessage() {
        imageView.image = nil // No image for welcome
        imageView.alpha = 0.0
        blurEffectView.isHidden = false // Ensure blur is visible for welcome
        textLabel.text = "Welcome to your Pocket of Time!\n\nTap 'Get a Fun Activity' below, then capture the moment to see it here."
        textLabel.textColor = .label
        textLabel.backgroundColor = .clear
        textLabel.font = .systemFont(ofSize: 17, weight: .medium)
    }
    
    // Call this if you need to reset the card
    func reset() {
        imageView.image = nil
        imageView.alpha = 0.0
        textLabel.text = nil
        textLabel.textColor = .label
        textLabel.backgroundColor = .clear
        blurEffectView.isHidden = false
        textLabel.font = .systemFont(ofSize: 17, weight: .medium)
    }
}
