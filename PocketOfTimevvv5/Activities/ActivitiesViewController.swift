//
//  ActivitiesViewController.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//

import UIKit

class ActivitiesViewController: UIViewController, FilterDelegate, AddMemoryDelegate {

    // MARK: - Data Properties
    // -------------------

    /// Holds all possible activities, loaded from our static ContentData struct.
    private var allActivities: [Activity] = []

    /// Stores the activity currently being displayed on the card. This is nil if no activity is shown.
    private var currentActivity: Activity?

    /// The array of titles for the age filter picker.
    private let ageTitles = AgeGroup.allCases.map { $0.rawValue }

    /// The array of titles for the category filter picker.
    private let categoryTitles = Category.allCases.map { $0.rawValue }

    /// The index of the currently selected age filter. Defaults to 0 ("All").
    private var selectedAgeIndex = 0

    /// The index of the currently selected category filter. Defaults to 0 ("All").
    private var selectedCategoryIndex = 0

    /// A timer used to trigger the camera button reminder animation.
    private var reminderTimer: Timer?

    // A "run-once" flag to track if the intro animation has been shown.
    private var hasAnimatedIntro = false


    // Floating Orb Views ---
    // create a few UIViews into colored circles.
    private lazy var orb1 = createOrbView(color: .systemIndigo.withAlphaComponent(0.4))
    private lazy var orb2 = createOrbView(color: .systemGreen.withAlphaComponent(0.4))
    private lazy var orb3 = createOrbView(color: .systemPink.withAlphaComponent(0.4))
    private lazy var orb4 = createOrbView(color: .systemYellow.withAlphaComponent(0.4))

    // MARK: - UI Components
    // -------------------

    /// The background image for the entire view.
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background2")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()

    /// The view that applies the modern "Liquid Glass" effect over the background.
    private lazy var blurEffectView: UIVisualEffectView = {
//        let glassEffect = UIGlassEffect()
//        let visualEffectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        return visualEffectView
    }()

    /// A safe container for all interactive UI, positioned between the header and tab bar.
    private lazy var mainContentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()

    /// The custom colored bar at the top of the screen.
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
//        view.backgroundColor = .clear // The blur view behind it provides the look.
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.9)
        return view
    }()

    // Header Components

    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Lets Have Fun! 🎳"
        label.font = .systemFont(ofSize: 28, weight: .bold)
        label.textColor = .white
        return label
    }()

    private lazy var dateLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .medium)
        label.textColor = .white.withAlphaComponent(0.8)
        return label
    }()
    
    // interactive filter pill.
    private lazy var filterStatusPill: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 16
        view.clipsToBounds = true
        view.alpha = 0 // Start hidden.
            
//        let glassEffect = UIGlassEffect()
//        let effectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(visualEffectView)
            
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
        ])
            
        // Add a tap gesture to the whole pill to clear filters.
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(didTapClearFilters))
        view.addGestureRecognizer(tapGesture)
            
        return view
    }()
    
    
    // show the current filter status
    private lazy var filterStatusLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 15, weight: .bold)
        label.textColor = .secondaryLabel
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var clearFilterIcon: UIImageView = {
        let config = UIImage.SymbolConfiguration(pointSize: 12, weight: .bold)
        let image = UIImage(systemName: "xmark", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.tintColor = .secondaryLabel
        return imageView
    }()
    
    
    // A stack view to hold the greeting and date labels.
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [greetingLabel, dateLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()

//    /// The main title label displayed in the custom header.
//    private lazy var titleLabel: UILabel = {
//        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
//        label.text = "Activities"
//        label.font = .systemFont(ofSize: 28, weight: .bold)
//        label.textColor = .white
//        return label
//    }()

//    /// The button in the header that opens the filter modal sheet.
//    private lazy var filterButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(didTapFilterButton), for: .touchUpInside)
//        return button
//    }()
//
//    /// The camera button in the header, used to capture a moment.
//    private lazy var cameraButton: UIButton = {
//        let button = UIButton(type: .system)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.alpha = 0 // Starts hidden.
//        button.addTarget(self, action: #selector(didTapCaptureMoment), for: .touchUpInside)
//
//        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
//        let image = UIImage(systemName: "camera.fill", withConfiguration: config)
//        button.setImage(image, for: .normal)
//        button.tintColor = .white
//
//        return button
//    }()


    // The individual filter and camera buttons
    private lazy var filterButton: UIButton = createHeaderButton(imageName: "slider.horizontal.3", action: #selector(didTapFilterButton))
    private lazy var cameraButton: UIButton = createHeaderButton(imageName: "camera.fill", action: #selector(didTapCaptureMoment))

    // Use a UIStackView for the header buttons for flawless automatic layout.
    private lazy var buttonStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [filterButton, cameraButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .horizontal
        stackView.spacing = 16
        return stackView
    }()


    // --- Spotlight Card ---
    private lazy var spotlightCardView: SpotlightCardView = {
        let card = SpotlightCardView()
        card.alpha = 0 // Start hidden for animation
        card.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Start smaller for animation
        return card
    }()



    // Two layer for card -shadow pop out
    private lazy var ideaCardShadowContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        // The shadow is applied to this outer container.
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 15

        // Start hidden for animation.
        view.alpha = 0
        view.transform = CGAffineTransform(translationX: 0, y: 50)
        return view
    }()

    // The card view that displays the activity idea.
    private lazy var ideaContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true // Important for the glass effect to be contained.

        // Add a UIGlassEffect to the card itself for a modern look.
//        let glassEffect = UIGlassEffect()
//        let effectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)

        visualEffectView.translatesAutoresizingMaskIntoConstraints = false

        // Add the effect view inside the container, behind the label.
        view.addSubview(visualEffectView)
        NSLayoutConstraint.activate([
            visualEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            visualEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            visualEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])

        // Add the swipe gesture recognizer for "Try Another".
        let swipeGesture = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeOnCard))
        swipeGesture.direction = .left
        view.addGestureRecognizer(swipeGesture)

        return view
    }()

    // The label inside the ideaContainer that shows the activity text.
    private lazy var ideaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()

    // A label to instruct the user how to swipe.
    private lazy var swipeInstructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Swipe left for another"
        label.font = .italicSystemFont(ofSize: 15)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.alpha = 0 // Start hidden
        return label
    }()

    // The main button on the screen to request an activity.
//    private lazy var getIdeaButton: UIButton = {
        // Use the new .prominentGlass() configuration for modern bounce animations.
//        var config = UIButton.Configuration.prominentGlass()
//        config.title = "Get a Fun Activity"
//        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
//            var outgoing = incoming
//            outgoing.font = .systemFont(ofSize: 18, weight: .bold)
//            return outgoing
//        }
//
//        config.baseBackgroundColor = .systemIndigo
//        config.cornerStyle = .capsule
//
//        let button = UIButton(configuration: config)
//        button.translatesAutoresizingMaskIntoConstraints = false
//        button.addTarget(self, action: #selector(didTapGetActivityButton), for: .touchUpInside)
        
        // The main button on the screen to request an activity.
    private lazy var getIdeaButton: UIButton = {
        var config = UIButton.Configuration.borderedProminent()
        config.title = "Get a Fun Activity"
        config.titleTextAttributesTransformer = UIConfigurationTextAttributesTransformer { incoming in
            var out = incoming
            out.font = .systemFont(ofSize: 18, weight: .bold)
            return out
        }
        config.baseBackgroundColor = .systemIndigo
        config.baseForegroundColor = .white
        config.cornerStyle = .capsule

        let button = UIButton(configuration: config)
        button.translatesAutoresizingMaskIntoConstraints = false        // << important for your heightAnchor constraint
        button.addTarget(self, action: #selector(didTapGetActivityButton),
                             for: .touchUpInside)                       // << wire it up again
        return button
    }()


    // stack view to group and center the main content.
    private lazy var contentStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [spotlightCardView, getIdeaButton])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.spacing = 40 // The space between the card and the button.
        stackView.alignment = .fill
        return stackView
    }()
    
    // view for the "Memory Captured!" prompt.
    private lazy var successPromptView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemGreen
        view.layer.cornerRadius = 16
        view.layer.masksToBounds = true
        view.alpha = 0 // Start hidden.
        view.transform = CGAffineTransform(translationX: 0, y: 100) // Start off-screen.
            
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Memory Captured! 🎉"
        label.font = .systemFont(ofSize: 16, weight: .bold)
        label.textColor = .white
            
        view.addSubview(label)
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: view.centerYAnchor)
        ])
            
        return view
    }()

    // MARK: - View Lifecycle
    // -------------------

    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
        setupUI()

        configureHeader()
        updateFilterButtonAppearance()
        
        updateFilterStatusLabel()

        //cameraButton.isHidden = true
    }

    // add the intro animation here.
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)

        // Call the new function to set up and animate the spotlight card
        setupSpotlightCard()

        // Trigger the intro animation for the button.
        animateIntro()

        animateOrbs()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        // We hide the default navigation bar because we have a custom header.
        navigationController?.setNavigationBarHidden(true, animated: animated)

        // If the intro sequence has already run, it means we are returning
                // to this tab. Therefore, reset it to its initial state.
        if hasAnimatedIntro {
            resetView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // We show the navigation bar again for other screens in the app.
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }

    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // Reset the view if the user switches to another tab.
        //if isMovingFromParent || isBeingDismissed {
//        if isMovingFromParent {
//            resetView()
//        }
        // Only run the intro sequence the very first time the view appears.
        if !hasAnimatedIntro {
            setupSpotlightCard()
            animateIntro()
            hasAnimatedIntro = true // Set the flag so this never runs again.
        }

    }

    // MARK: - Setup UI
    // -------------------

    private func configureHeader() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        dateLabel.text = dateFormatter.string(from: Date())
        cameraButton.isHidden = true
    }

    // AMENDED: New function to setup and animate the spotlight card
    private func setupSpotlightCard() {
        // 1. Load the most recent memory (requires PersistenceManager)
        let allMemories = PersistenceManager.shared.loadMemories()

        if let latestMemory = allMemories.first { // Assuming `loadMemories()` returns in reverse chronological order
            spotlightCardView.configure(with: latestMemory)
        } else {
            spotlightCardView.showWelcomeMessage()
        }

        // 2. Animate the spotlight card into view
        UIView.animate(withDuration: 0.6, delay: 0.4, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
                self.spotlightCardView.alpha = 1
                self.spotlightCardView.transform = .identity // Scale back to normal size
        })
    }

    private func setupUI() {
        // --- View Hierarchy ---
        // 1st layer
        view.addSubview(backgroundImageView)

        // 2nd layer
        view.addSubview(orb1)
        view.addSubview(orb2)
        view.addSubview(orb3)
        view.addSubview(orb4)

        // 3rd layer
        view.addSubview(blurEffectView)

        // 4th layer
        view.addSubview(mainContentContainer)
        view.addSubview(headerView)
        view.addSubview(successPromptView)
        //headerView.addSubview(titleLabel)
//        headerView.addSubview(filterButton)
//        headerView.addSubview(cameraButton)
        headerView.addSubview(titleStackView)
        headerView.addSubview(buttonStackView)
        
        mainContentContainer.addSubview(filterStatusPill)
        filterStatusPill.addSubview(filterStatusLabel)
        filterStatusPill.addSubview(clearFilterIcon)

//        mainContentContainer.addSubview(spotlightCardView)
//        mainContentContainer.addSubview(getIdeaButton)
        mainContentContainer.addSubview(contentStackView)
        mainContentContainer.addSubview(ideaCardShadowContainer)
        ideaCardShadowContainer.addSubview(ideaContainer)
        ideaContainer.addSubview(ideaLabel)
        mainContentContainer.addSubview(swipeInstructionLabel)


        // --- Auto Layout Constraints ---
        NSLayoutConstraint.activate([
            // Background and blur fill the entire screen.
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),

            // Header is pinned to the top.
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            //headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60),

//            titleLabel.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
//            titleLabel.bottomAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -12),

//            // Header buttons are aligned to the title.
//            cameraButton.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
//            cameraButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),
//
//            filterButton.trailingAnchor.constraint(equalTo: cameraButton.leadingAnchor, constant: -16),
//            filterButton.centerYAnchor.constraint(equalTo: titleLabel.centerYAnchor),

//            titleStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
//            titleStackView.centerYAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.centerYAnchor),
            
            titleStackView.topAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.topAnchor, constant: 8),
            titleStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            
            headerView.bottomAnchor.constraint(equalTo: titleStackView.bottomAnchor, constant: 12),

            // The entire stack view is pinned to the right.
            buttonStackView.trailingAnchor.constraint(equalTo: headerView.trailingAnchor, constant: -20),
            buttonStackView.centerYAnchor.constraint(equalTo: titleStackView.centerYAnchor),

            // Main content container fills the safe space between header and tab bar.
            mainContentContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor),
            mainContentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

//            // "Get Idea" button is centered in the safe space.
//            getIdeaButton.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor),
//            getIdeaButton.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 40),
//            getIdeaButton.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -40),
//            getIdeaButton.heightAnchor.constraint(equalToConstant: 60),
//
//            // outer shadow container
//            ideaCardShadowContainer.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 20),
//            ideaCardShadowContainer.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -20),
//            ideaCardShadowContainer.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor),

//            // AMENDED: Spotlight Card Constraints
//            // Position the spotlight card in the upper middle of the content area.
//            spotlightCardView.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 30),
//            spotlightCardView.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -30),
//            spotlightCardView.centerXAnchor.constraint(equalTo: mainContentContainer.centerXAnchor),
//            spotlightCardView.topAnchor.constraint(equalTo: mainContentContainer.topAnchor, constant: 40), // Adjust top padding as needed
//
//            // AMENDED: Update "Get Idea" button constraints to be below the spotlight card.
//            getIdeaButton.topAnchor.constraint(equalTo: spotlightCardView.bottomAnchor, constant: 40), // Space between card and button
//            getIdeaButton.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 40),
//            getIdeaButton.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -40),
//            getIdeaButton.heightAnchor.constraint(equalToConstant: 60),

            // filter pill.
            filterStatusPill.topAnchor.constraint(equalTo: mainContentContainer.topAnchor, constant: 20),
            filterStatusPill.centerXAnchor.constraint(equalTo: mainContentContainer.centerXAnchor),
                        
            filterStatusLabel.topAnchor.constraint(equalTo: filterStatusPill.topAnchor, constant: 8),
            filterStatusLabel.bottomAnchor.constraint(equalTo: filterStatusPill.bottomAnchor, constant: -8),
            filterStatusLabel.leadingAnchor.constraint(equalTo: filterStatusPill.leadingAnchor, constant: 16),
                        
            clearFilterIcon.leadingAnchor.constraint(equalTo: filterStatusLabel.trailingAnchor, constant: 8),
            clearFilterIcon.trailingAnchor.constraint(equalTo: filterStatusPill.trailingAnchor, constant: -16),
            clearFilterIcon.centerYAnchor.constraint(equalTo: filterStatusLabel.centerYAnchor),
            
            // Center the new contentStackView.
            contentStackView.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor),
            contentStackView.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 40),
            contentStackView.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -40),

            // Set the height for the button inside the stack view.
            getIdeaButton.heightAnchor.constraint(equalToConstant: 60),

            // Activity card (ideaCardShadowContainer) constraints remain similar,
            // but now it overlays the spotlight card and GetIdeaButton when active.
            ideaCardShadowContainer.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 20),
            ideaCardShadowContainer.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -20),
            ideaCardShadowContainer.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor), // Still centered over button

            // The inner container fills the shadow container.
            ideaContainer.topAnchor.constraint(equalTo: ideaCardShadowContainer.topAnchor),
            ideaContainer.bottomAnchor.constraint(equalTo: ideaCardShadowContainer.bottomAnchor),
            ideaContainer.leadingAnchor.constraint(equalTo: ideaCardShadowContainer.leadingAnchor),
            ideaContainer.trailingAnchor.constraint(equalTo: ideaCardShadowContainer.trailingAnchor),
            ideaContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),

            ideaLabel.topAnchor.constraint(equalTo: ideaContainer.topAnchor, constant: 20),
            ideaLabel.bottomAnchor.constraint(equalTo: ideaContainer.bottomAnchor, constant: -20),
            ideaLabel.leadingAnchor.constraint(equalTo: ideaContainer.leadingAnchor, constant: 20),
            ideaLabel.trailingAnchor.constraint(equalTo: ideaContainer.trailingAnchor, constant: -20),

            // instruction label below the card
            swipeInstructionLabel.topAnchor.constraint(equalTo: ideaCardShadowContainer.bottomAnchor, constant: 16),
            swipeInstructionLabel.centerXAnchor.constraint(equalTo: mainContentContainer.centerXAnchor),
            
            // the success prompt view.
            // Pin it to the bottom of the screen's safe area.
            successPromptView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20),
            successPromptView.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            successPromptView.heightAnchor.constraint(equalToConstant: 50),
            successPromptView.widthAnchor.constraint(equalToConstant: 250)


        ])
    }

    // MARK: - Actions & Logic
    // -------------------

    // when the user taps the filter pill.
    @objc private func didTapClearFilters() {
        // Reset the filter indexes.
        selectedAgeIndex = 0
        selectedCategoryIndex = 0
            
        // Update the UI to reflect the change.
        updateFilterButtonAppearance()
        updateFilterStatusLabel()
    }
    
    /// Updates the filter button's icon to show if a filter is active.
    private func updateFilterButtonAppearance() {
        let isFilterActive = selectedAgeIndex != 0 || selectedCategoryIndex != 0
        let imageName = isFilterActive ? "slider.horizontal.3.fill" : "slider.horizontal.3"

        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: imageName, withConfiguration: config)

        filterButton.setImage(image, for: .normal)
        filterButton.tintColor = isFilterActive ? .systemYellow : .white
    }

    /// Loads the static content from our data struct.
    private func loadContent() {
        allActivities = ContentData.activities
    }

    /// Finds and displays a new activity based on the current filters.
//    @objc private func didTapGetActivityButton() {
//        let selectedAgeTitle = ageTitles[selectedAgeIndex]
//        let selectedCategoryTitle = categoryTitles[selectedCategoryIndex]
//
//        var filteredActivities = allActivities
//
//        if selectedAgeTitle != AgeGroup.all.rawValue {
//            filteredActivities = filteredActivities.filter { $0.ageGroups.contains(selectedAgeTitle) }
//        }
//
//        if selectedCategoryTitle != Category.all.rawValue {
//            filteredActivities = filteredActivities.filter { $0.category == selectedCategoryTitle }
//        }
//
//        if let randomActivity = filteredActivities.randomElement() {
//            self.currentActivity = randomActivity
//            showIdea(text: randomActivity.title)
//        } else {
//            self.currentActivity = nil
//            showIdea(text: "No activities found for this combination. Try resetting your filters!")
//        }
//    }

    @objc private func didTapGetActivityButton() {
        
        // Make sure the activity card sits on top of Spotlight + Button
        mainContentContainer.bringSubviewToFront(ideaCardShadowContainer)
        
        UIView.animate(withDuration: 0.3) {
            self.spotlightCardView.alpha = 0
            self.spotlightCardView.transform = CGAffineTransform(scaleX: 0.8, y: 0.8) // Shrink for a nice fade-out
        } completion: { _ in
            self.spotlightCardView.reset() // Clear content after fade-out
            // Continue with original logic
            let selectedAgeTitle = self.ageTitles[self.selectedAgeIndex]
            let selectedCategoryTitle = self.categoryTitles[self.selectedCategoryIndex]

            var filteredActivities = self.allActivities

            if selectedAgeTitle != AgeGroup.all.rawValue {
                    filteredActivities = filteredActivities.filter { $0.ageGroups.contains(selectedAgeTitle) }
            }

            if selectedCategoryTitle != Category.all.rawValue {
                    filteredActivities = filteredActivities.filter { $0.category == selectedCategoryTitle }
            }

            if let randomActivity = filteredActivities.randomElement() {
                self.currentActivity = randomActivity
                self.showIdea(text: randomActivity.title)
            } else {
                self.currentActivity = nil
                self.showIdea(text: "No activities found for this combination. Try resetting your filters!")
            }
        }
    }

    /// Presents the modal filter sheet.
    @objc private func didTapFilterButton() {
        let filterVC = FilterViewController()
        filterVC.delegate = self
        filterVC.initialAgeIndex = selectedAgeIndex
        filterVC.initialCategoryIndex = selectedCategoryIndex

        let navController = UINavigationController(rootViewController: filterVC)

        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }

        present(navController, animated: true)
    }

    /// Presents the "Add Memory" screen with pre-filled text.
    @objc private func didTapCaptureMoment() {
        guard let activity = currentActivity else { return }

        let addMemoryVC = AddMemoryViewController()
        addMemoryVC.prefilledText = activity.title
        
        //tell addmemory screen here that activities screen is delegate
        addMemoryVC.delegate = self

        let navController = UINavigationController(rootViewController: addMemoryVC)
        present(navController, animated: true)
    }

    /// Triggered by swiping left on the idea card.
    @objc private func didSwipeOnCard() {
        reminderTimer?.invalidate()

        UIView.animate(withDuration: 0.3, animations: {
            // Animate the current card off-screen.
            self.ideaCardShadowContainer.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            self.ideaCardShadowContainer.alpha = 0
            self.swipeInstructionLabel.alpha = 0
//            self.cameraButton.alpha = 0
        }) { _ in
            // After the animation, get a new activity.
            self.didTapGetActivityButton()
        }
    }
    
    // triggered when user tap save
    func didFinishSavingMemory() {
        // dismiss the modal that is currently presented.
        dismiss(animated: true) {
        // after the dismiss animation finishes, switch to the "My Moments" tab. Tab indexes: 0 = Activities, 1 = Conversations, 2 = Moments.
        //self.tabBarController?.selectedIndex = 2
            self.showSuccessPrompt()
        }
    }

    // MARK: - Animations
    // -------------------

    // creates continous looping anmations for ORB
    private func animateOrbs() {
        // orb 1 animation
        UIView.animate(withDuration: 10, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.orb1.transform = CGAffineTransform(translationX: 150, y: -200).rotated(by: 1.2)
        })

        // orb 2 animation
        UIView.animate(withDuration: 5, delay: 5, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.orb2.transform = CGAffineTransform(translationX: -200, y: 250).rotated(by: -0.8)
        })

        // orb 3 animation
        UIView.animate(withDuration: 10, delay: 2, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.orb3.transform = CGAffineTransform(translationX: 100, y: 300).rotated(by: 1.5)
        })

        // orb 4 animation
        UIView.animate(withDuration: 3, delay: 3, options: [.curveEaseInOut, .repeat, .autoreverse], animations: {
            self.orb4.transform = CGAffineTransform(translationX: -150, y: 150).rotated(by: -0.3)
        })
    }


    // A subtle animation for when the view first appears.
    private func animateIntro() {
        // Start the button smaller than its final size.
        getIdeaButton.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)

        UIView.animate(withDuration: 0.6,
                        delay: 0.2,
                        usingSpringWithDamping: 0.6,
                        initialSpringVelocity: 0.8,
                        options: .curveEaseInOut,
                        animations: {
            // Animate the button to its normal size.
            self.getIdeaButton.transform = .identity
        })
    }

    /// Animates the idea card into view.
    private func showIdea(text: String) {
        
        mainContentContainer.bringSubviewToFront(ideaCardShadowContainer)
        
        ideaCardShadowContainer.transform = CGAffineTransform(translationX: 0, y: 50)
        ideaLabel.text = text
        reminderTimer?.invalidate()

        UIView.animate(withDuration: 0.6, delay: 0.2, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.getIdeaButton.alpha = 0
            self.getIdeaButton.isUserInteractionEnabled = false
            
            self.spotlightCardView.alpha = 0
            // Animate the shadow container and the new label
            self.ideaCardShadowContainer.alpha = 1
            self.ideaCardShadowContainer.transform = .identity


            self.cameraButton.isHidden = (self.currentActivity == nil)
        }) { _ in
            // animate instruction swipe left label
//            UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut) {
//                self.swipeInstructionLabel.alpha = 1

            // Check UserDefaults to see if we've shown the instruction before.
            let hasShownSwipeInstruction = UserDefaults.standard.bool(forKey: "hasShownSwipeInstruction")

            // Only run the animation if the flag is false.
            if !hasShownSwipeInstruction {
                UIView.animate(withDuration: 0.4, delay: 0.2, options: .curveEaseInOut) {
                    self.swipeInstructionLabel.alpha = 1
                }
            // Immediately set the flag to true so it never shows again.
            UserDefaults.standard.set(true, forKey: "hasShownSwipeInstruction")
            }

            // start reminder timer
            if self.currentActivity != nil {
                self.startReminderTimer()
            }
        }
    }

    /// Animates the idea card out of view and resets the UI to its initial state.
    private func resetView() {
        reminderTimer?.invalidate()

        UIView.animate(withDuration: 0.3, animations: {
            self.getIdeaButton.alpha = 1
            self.getIdeaButton.isUserInteractionEnabled = true
            // Animate the shadow container and the new label out
            self.ideaCardShadowContainer.alpha = 0
            self.ideaCardShadowContainer.transform = CGAffineTransform(translationX: 0, y: 50)
            self.swipeInstructionLabel.alpha = 0

            self.cameraButton.isHidden = true

            // Bring back the spotlight card.
            self.spotlightCardView.alpha = 1
            self.spotlightCardView.transform = .identity // Ensure it's back to normal size
        }) { _ in
            self.setupSpotlightCard() // Reconfigure with latest memory on reset
        }

    }
    
    private func updateFilterStatusLabel() {
        let ageTitle = ageTitles[selectedAgeIndex]
        let categoryTitle = categoryTitles[selectedCategoryIndex]
            
        var filterParts: [String] = []
            
        // Build an array of the active filters (ignoring "All").
        if ageTitle != AgeGroup.all.rawValue {
                filterParts.append(ageTitle)
        }
        if categoryTitle != Category.all.rawValue {
            filterParts.append(categoryTitle)
        }
            
        // Animate the appearance/disappearance of the label.
        UIView.animate(withDuration: 0.4) {
            if filterParts.isEmpty {
                // If no filters are active, hide the label.
                self.filterStatusPill.alpha = 0
            } else {
                // Otherwise, build the string and show the label.
                self.filterStatusLabel.text = "Filtering: " + filterParts.joined(separator: ", ")
                self.filterStatusPill.alpha = 1
            }
        }
    }

    // --- Helper function for header buttons ---
    private func createHeaderButton(imageName: String, action: Selector) -> UIButton {
        let button = UIButton(type: .system)
        let config = UIImage.SymbolConfiguration(pointSize: 24, weight: .semibold)
        let image = UIImage(systemName: imageName, withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.addTarget(self, action: action, for: .touchUpInside)
        return button
    }

    // create and style 1 orb
    private func createOrbView(color: UIColor) -> UIView {
        let orbView = UIView()
        // set initial frame off-screen
        orbView.frame = CGRect(x: CGFloat.random(in: -100...view.bounds.width),
                            y: CGFloat.random(in: -100...view.bounds.height),
                            width: 300,
                            height: 200)
        orbView.backgroundColor = color
        // circle
        orbView.layer.cornerRadius = 150
        orbView.clipsToBounds = true
        return orbView

    }

    // show and then hide the success prompt.
    private func showSuccessPrompt() {
        // Animate the prompt sliding up and fading in.
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.8, options: .curveEaseInOut, animations: {
            self.successPromptView.alpha = 1
            self.successPromptView.transform = .identity
        }) { _ in
            // After it's visible, wait for 2 seconds.
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                // Then, animate it sliding down and fading out.
                UIView.animate(withDuration: 0.4, animations: {
                    self.successPromptView.alpha = 0
                    self.successPromptView.transform = CGAffineTransform(translationX: 0, y: 100)
                })
            }
        }
    }

    // MARK: - Reminder Timer
    // -------------------

    /// Starts a 3-second timer to trigger the reminder animation.
    private func startReminderTimer() {
        reminderTimer = Timer.scheduledTimer(
            timeInterval: 2.0,
            target: self,
            selector: #selector(triggerReminderAnimation),
            userInfo: nil,
            repeats: false
        )
    }

    /// Animates the camera button with a satisfying bounce to draw the user's attention.
    @objc private func triggerReminderAnimation() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.3, initialSpringVelocity: 1.0, options: .curveEaseInOut, animations: {
            self.cameraButton.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }) { _ in
            UIView.animate(withDuration: 0.3) {
                self.cameraButton.transform = .identity
            }
        }
    }

    // MARK: - FilterDelegate
    // -------------------

    /// This function is called from the FilterViewController when the user applies new filters.
    func didApplyFilters(ageIndex: Int, categoryIndex: Int) {
        self.selectedAgeIndex = ageIndex
        self.selectedCategoryIndex = categoryIndex
        updateFilterButtonAppearance()
        
        updateFilterStatusLabel()
    }
}


#Preview {
    ActivitiesViewController()
}
