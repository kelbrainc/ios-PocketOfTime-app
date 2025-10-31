//
//  OnboardingContentViewController.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import UIKit

// This view controller represents a single page/slide in the onboarding flow.
class OnboardingContentViewController: UIViewController {

    // --- Data ---
    var slide: OnboardingSlide?
    var pageIndex: Int = 0
    
    // animate
    private var hasAnimatedIn = false

    
    // --- UI Components ---
    
    private lazy var slideImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        // Use a large font size for SF Symbols
        imageView.preferredSymbolConfiguration = .init(pointSize: 120)
        imageView.tintColor = .systemIndigo
        return imageView
    }()
    
    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 17)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.textColor = .secondaryLabel
        return label
    }()
    
    // animation functions
    private func prepareInitialAnimationState() {
        // Start slightly below and transparent
        slideImageView.transform = CGAffineTransform(translationX: 0, y: 20).scaledBy(x: 0.9, y: 0.9)
        titleLabel.transform      = CGAffineTransform(translationX: 0, y: 14)
        descriptionLabel.transform = CGAffineTransform(translationX: 0, y: 10)

        slideImageView.alpha = 0
        titleLabel.alpha = 0
        descriptionLabel.alpha = 0
    }
    
    private func animateIn() {
        // Image pops first
        UIView.animate(
            withDuration: 0.6,
            delay: 0.05,
            usingSpringWithDamping: 0.75,
            initialSpringVelocity: 0.7,
            options: [.curveEaseInOut],
            animations: {
                self.slideImageView.transform = .identity
                self.slideImageView.alpha = 1
            }
        )

        // Title follows
        UIView.animate(withDuration: 0.45, delay: 0.12, options: .curveEaseOut, animations: {
            self.titleLabel.transform = .identity
            self.titleLabel.alpha = 1
        })

        // Description last
        UIView.animate(withDuration: 0.45, delay: 0.20, options: .curveEaseOut, animations: {
            self.descriptionLabel.transform = .identity
            self.descriptionLabel.alpha = 1
        })
    }


    
    // --- View Lifecycle ---
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        setupUI()
        configureView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // Prepare every time we’re about to appear
        prepareInitialAnimationState()
    }

    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        // Only run the entrance once per slide instance
        guard !hasAnimatedIn else { return }
        hasAnimatedIn = true
        animateIn()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Allow this slide to animate again when we come back to it
        hasAnimatedIn = false
    }

    
    // --- Setup ---
    
    private func setupUI() {
        // Use a UIStackView for easy vertical layout
        let stackView = UIStackView(arrangedSubviews: [slideImageView, titleLabel, descriptionLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 24 // Space between elements
        stackView.alignment = .center
        
        view.addSubview(stackView)
        
        NSLayoutConstraint.activate([
            // Constrain the stack view to the center
            stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40)
        ])
    }
    
    private func configureView() {
        guard let slide = slide else { return }

        // Use SF Symbol from slide.imageName
        slideImageView.image = UIImage(systemName: slide.imageName)

        // 🔹 Set tint per symbol
        switch slide.imageName {
        case "lightbulb", "lightbulb.fill":
            slideImageView.tintColor = .systemYellow
        case "heart", "heart.fill", "heart.rectangle", "heart.rectangle.fill":
            slideImageView.tintColor = .systemRed
        default:
            slideImageView.tintColor = .systemIndigo
        }

        titleLabel.text = slide.title
        descriptionLabel.text = slide.description
    }

}
