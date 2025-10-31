//
//  ConversationsViewController.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import UIKit

class ConversationsViewController: UIViewController {
    
    // MARK: - Data Properties
    // -------------------
    
    /// Holds all possible questions, loaded from our static ContentData struct.
    private var allQuestions: [Question] = []
    
    /// A "run-once" flag to track if the intro animation has been shown for this session.
    private var hasAnimatedIntro = false
    
    /// A counter to track which animal animation to run, ensuring the pattern alternates.
    //private var questionTapCounter = 0
    

    private var questionHistory: [Question] = []
    private var historyIndex = -1
    
    private var forwardAnimationCounter = 0
    private var backwardAnimationCounter = 0

    private var hasDismissedSwipeHint = false

    // MARK: - UI Components
    // -------------------
    
    private lazy var backgroundImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = UIImage(named: "background2")
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    private lazy var blurEffectView: UIVisualEffectView = {
//        let glassEffect = UIGlassEffect()
//        let visualEffectView = UIVisualEffectView(effect: glassEffect)
        let blurEffect = UIBlurEffect(style: .systemMaterial)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        
        visualEffectView.translatesAutoresizingMaskIntoConstraints = false
        // dont block the tap heart
        visualEffectView.isUserInteractionEnabled = false
        
        return visualEffectView
    }()

    
    private lazy var bigHeart1 = createHeartButton(size: 250, color: .systemPink.withAlphaComponent(0.4))
    private lazy var bigHeart2 = createHeartButton(size: 200, color: .systemOrange.withAlphaComponent(0.4))
    private lazy var smallHeart1 = createHeartButton(size: 100, color: .systemRed.withAlphaComponent(0.4))
    private lazy var smallHeart2 = createHeartButton(size: 150, color: .systemBlue.withAlphaComponent(0.4))
    private lazy var smallHeart3 = createHeartButton(size: 120, color: .systemPink.withAlphaComponent(0.4))
    
    
    private lazy var runningAnimalView1: UIImageView = createRunningAnimalView()
    private lazy var runningAnimalView2: UIImageView = createRunningAnimalView()

    
    private lazy var mainContentContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    private lazy var headerView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .systemIndigo.withAlphaComponent(0.9)
        return view
    }()
    
    private lazy var greetingLabel: UILabel = {
        let label = UILabel()
        label.text = "Let's Chat! 💬"
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
    
    private lazy var titleStackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [greetingLabel, dateLabel])
        stackView.translatesAutoresizingMaskIntoConstraints = false
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = 2
        return stackView
    }()
    
    // both Question of the day and random question
    private lazy var ideaCardShadowContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.shadowColor = UIColor.black.cgColor
        view.layer.shadowOpacity = 0.2
        view.layer.shadowOffset = CGSize(width: 0, height: 8)
        view.layer.shadowRadius = 15
        view.alpha = 0
        view.transform = CGAffineTransform(scaleX: 0.8, y: 0.8)
        return view
    }()

    private lazy var ideaContainer: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 24
        view.clipsToBounds = true
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
            visualEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
        let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeLeft))
        swipeLeft.direction = .left
        view.addGestureRecognizer(swipeLeft)
        
        let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(didSwipeRight))
        swipeRight.direction = .right
        view.addGestureRecognizer(swipeRight)
        
        return view
    }()
    
    private lazy var ideaLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = .systemFont(ofSize: 26, weight: .bold)
        label.textAlignment = .center
        label.numberOfLines = 0
        return label
    }()
    
    private lazy var swipeHintLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Swipe left for another • Swipe right to go back"
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.textColor = .secondaryLabel
        label.textAlignment = .center
        label.numberOfLines = 0
        label.alpha = 0           // fade in on intro
        label.adjustsFontForContentSizeCategory = true
        return label
    }()

    
    private var rippleShapeLayer: CAShapeLayer?
    
    // MARK: - View Lifecycle
    // -------------------
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadContent()
        setupUI()
        configureHeader()
        
        createRippleLayer()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        if !hasAnimatedIntro {
            animateIntro()
            animateHearts()
            hasAnimatedIntro = true
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
        if hasAnimatedIntro {
            resetView()
        }
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        rippleShapeLayer?.frame = ideaContainer.bounds
    }
    
    
    // MARK: - Setup UI & Configuration
    // -------------------
    
    private func configureHeader() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, d MMMM"
        dateLabel.text = dateFormatter.string(from: Date())
    }
    
    private func setupUI() {
        // --- View Hierarchy ---
        view.addSubview(backgroundImageView)
        view.addSubview(bigHeart1)
        view.addSubview(smallHeart1)
        view.addSubview(bigHeart2)
        view.addSubview(smallHeart2)
        view.addSubview(smallHeart3)
        view.addSubview(blurEffectView)
        view.addSubview(mainContentContainer)
        view.addSubview(headerView)
        headerView.addSubview(titleStackView)
        
        // Add the card and button directly to the main container.
        mainContentContainer.addSubview(ideaCardShadowContainer)
        ideaCardShadowContainer.addSubview(ideaContainer)
        ideaContainer.addSubview(ideaLabel)
        mainContentContainer.addSubview(swipeHintLabel)
                
        mainContentContainer.addSubview(runningAnimalView1)
        mainContentContainer.addSubview(runningAnimalView2)

        // --- Auto Layout Constraints ---
        NSLayoutConstraint.activate([
            // --- All background, header, and main container constraints are correct ---
            backgroundImageView.topAnchor.constraint(equalTo: view.topAnchor),
            backgroundImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            backgroundImageView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            backgroundImageView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            blurEffectView.topAnchor.constraint(equalTo: view.topAnchor),
            blurEffectView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            blurEffectView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            blurEffectView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.topAnchor.constraint(equalTo: view.topAnchor),
            headerView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            headerView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            headerView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 80),
            titleStackView.leadingAnchor.constraint(equalTo: headerView.leadingAnchor, constant: 20),
            titleStackView.centerYAnchor.constraint(equalTo: headerView.safeAreaLayoutGuide.centerYAnchor),
            titleStackView.trailingAnchor.constraint(lessThanOrEqualTo: headerView.trailingAnchor, constant: -20),
            mainContentContainer.topAnchor.constraint(equalTo: headerView.bottomAnchor, constant: -50),
            mainContentContainer.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            mainContentContainer.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            mainContentContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),

        
            // Center the card vertically in the container.
            ideaCardShadowContainer.centerYAnchor.constraint(equalTo: mainContentContainer.centerYAnchor),
            ideaCardShadowContainer.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 40),
            ideaCardShadowContainer.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -40),
                    
            
            // hint swipe
            swipeHintLabel.topAnchor.constraint(equalTo: ideaCardShadowContainer.bottomAnchor, constant: 12),
            swipeHintLabel.leadingAnchor.constraint(equalTo: mainContentContainer.leadingAnchor, constant: 40),
            swipeHintLabel.trailingAnchor.constraint(equalTo: mainContentContainer.trailingAnchor, constant: -40),
                    
            // --- Constraints for items INSIDE the card ---
            ideaContainer.topAnchor.constraint(equalTo: ideaCardShadowContainer.topAnchor),
            ideaContainer.bottomAnchor.constraint(equalTo: ideaCardShadowContainer.bottomAnchor),
            ideaContainer.leadingAnchor.constraint(equalTo: ideaCardShadowContainer.leadingAnchor),
            ideaContainer.trailingAnchor.constraint(equalTo: ideaCardShadowContainer.trailingAnchor),
            ideaContainer.heightAnchor.constraint(greaterThanOrEqualToConstant: 200),
            ideaLabel.topAnchor.constraint(equalTo: ideaContainer.topAnchor, constant: 20),
            ideaLabel.bottomAnchor.constraint(equalTo: ideaContainer.bottomAnchor, constant: -20),
            ideaLabel.leadingAnchor.constraint(equalTo: ideaContainer.leadingAnchor, constant: 20),
            ideaLabel.trailingAnchor.constraint(equalTo: ideaContainer.trailingAnchor, constant: -20),
        ])
    }

    
    // MARK: - Actions & Logic
    // -------------------
    
    private func loadContent() {
        allQuestions = ContentData.questions
    }

    
    private func nextRandomQuestionAvoidingRepeat(_ last: Question?) -> Question? {
        var pool = allQuestions.shuffled()
        if let last, pool.first == last, pool.count > 1 { pool.swapAt(0, 1) }
        return pool.first
    }

    
    @objc private func didSwipeLeft() {
        
        if !hasDismissedSwipeHint {
            hasDismissedSwipeHint = true
            UIView.animate(withDuration: 0.4) {
                self.swipeHintLabel.alpha = 0
            }
        }
        
        // If we’re on the daily card, create the first history entry now
        if historyIndex == -1 {
            let lastShown = questionHistory.last   // usually nil when -1
            if let q = nextRandomQuestionAvoidingRepeat(lastShown) {
                questionHistory = [q]
                historyIndex = 0
                animateCardInFromRight(text: q.text, isNew: true)
            }
            return
        }

        // At end of history? fetch a brand-new one
        if historyIndex == questionHistory.count - 1 {
            if let q = nextRandomQuestionAvoidingRepeat(questionHistory.last) {
                questionHistory.append(q)
                historyIndex += 1
                animateCardInFromRight(text: q.text, isNew: true)
            }
        } else {
            // Move forward in existing history
            historyIndex += 1
            let next = questionHistory[historyIndex]
            animateCardInFromRight(text: next.text, isNew: false)
        }
    }

    @objc private func didSwipeRight() {
        // Only go back if we have history (index >= 1). Daily card (-1) does nothing.
        guard historyIndex > 0 else { return }
        historyIndex -= 1
        let prev = questionHistory[historyIndex]
        animateCardInFromLeft(text: prev.text)
    }

    
    // MARK: - Animations
    // -------------------
    
    private func animateHearts() {
        UIView.animate(withDuration: 40, delay: 0, options: [.curveEaseInOut, .repeat, .autoreverse], animations: { self.bigHeart1.transform = CGAffineTransform(translationX: 120, y: -280).rotated(by: 0.7) })
        UIView.animate(withDuration: 55, delay: 3, options: [.curveEaseInOut, .repeat, .autoreverse], animations: { self.bigHeart2.transform = CGAffineTransform(translationX: -150, y: 200).rotated(by: -0.5) })
        UIView.animate(withDuration: 50, delay: 1, options: [.curveEaseInOut, .repeat, .autoreverse], animations: { self.smallHeart1.transform = CGAffineTransform(translationX: -180, y: 320).rotated(by: -0.9) })
        UIView.animate(withDuration: 35, delay: 6, options: [.curveEaseInOut, .repeat, .autoreverse], animations: { self.smallHeart2.transform = CGAffineTransform(translationX: 200, y: -150).rotated(by: 1.2) })
        UIView.animate(withDuration: 60, delay: 8, options: [.curveEaseInOut, .repeat, .autoreverse], animations: { self.smallHeart3.transform = CGAffineTransform(translationX: -100, y: -300).rotated(by: 1.5) })
    }

    private func animateIntro() {
        ideaLabel.text = "Question Of The Day"   // pre-ripple title

        UIView.animate(withDuration: 0.6,
                       delay: 0.2,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.8,
                       options: .curveEaseInOut,
                       animations: {
            self.ideaCardShadowContainer.transform = .identity
            self.ideaCardShadowContainer.alpha = 1
            self.swipeHintLabel.alpha = 1
        }) { _ in
            // ripple, then swap to actual QOTD (with safe fallback)
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.8) {
                self.animateRippleEffect()
            }
        }
    }

    
    // Handles the ripple effect and text transition.
    private func animateRippleEffect() {
        guard let rippleLayer = self.rippleShapeLayer else { return }
            
        let cardCenter = CGPoint(x: ideaContainer.bounds.midX, y: ideaContainer.bounds.midY)
        let startPath = UIBezierPath(arcCenter: cardCenter, radius: 1, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
        let endRadius = sqrt(ideaContainer.bounds.width * ideaContainer.bounds.width + ideaContainer.bounds.height * ideaContainer.bounds.height)
        let endPath = UIBezierPath(arcCenter: cardCenter, radius: endRadius, startAngle: 0, endAngle: 2 * .pi, clockwise: true).cgPath
            
        rippleLayer.path = startPath
        rippleLayer.opacity = 1
        rippleLayer.isHidden = false
            
        let pathAnimation = CABasicAnimation(keyPath: "path")
        pathAnimation.toValue = endPath
            
        let opacityAnimation = CABasicAnimation(keyPath: "opacity")
        opacityAnimation.toValue = 0
            
        let animationGroup = CAAnimationGroup()
        animationGroup.animations = [pathAnimation, opacityAnimation]
        animationGroup.duration = 2
        animationGroup.timingFunction = CAMediaTimingFunction(name: .easeOut)
            
        rippleLayer.add(animationGroup, forKey: "rippleEffect")
            
        UIView.transition(with: ideaLabel, duration: 1, options: .transitionCrossDissolve, animations: {
            self.ideaLabel.text = ContentData.getQuestionOfTheDay()?.text ?? "Here’s a fun question!"
        }) { _ in
            self.rippleShapeLayer?.isHidden = true
        }

    }
    
    // create resuable ripple layer
    private func createRippleLayer() {
        let layer = CAShapeLayer()
        layer.strokeColor = UIColor.white.cgColor
        layer.lineWidth = 8
        layer.fillColor = UIColor.clear.cgColor
        // layer need to be added to the view
        ideaContainer.layer.addSublayer(layer)
        self.rippleShapeLayer = layer
    }
    
    // Animates the idea card into view.
    private func showIdea(text: String) {
        ideaCardShadowContainer.transform = CGAffineTransform(translationX: 0, y: 50)
        ideaLabel.text = text
              
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
//            self.getQuestionButton.alpha = 0
//            self.getQuestionButton.isUserInteractionEnabled = false
            self.ideaCardShadowContainer.alpha = 1
            self.ideaCardShadowContainer.transform = .identity
        }) { _ in
            self.animateForwardSequence()
            
        }
    }
    
    /// Animates a new card sliding in from the right.
    private func animateCardInFromRight(text: String, isNew: Bool) {
        // Animate the old card away to the left.
        UIView.animate(withDuration: 0.35, animations: {
            self.ideaCardShadowContainer.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            self.ideaCardShadowContainer.alpha = 0
            
//            self.getQuestionButton.alpha = 0
        }) { _ in
            // Prepare the new card off-screen to the right.
            self.ideaCardShadowContainer.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.ideaLabel.text = text
                
            // Animate the new card to the center.
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.ideaCardShadowContainer.alpha = 1
                self.ideaCardShadowContainer.transform = .identity
            }) { _ in
                // Only run the animal animation if it's a brand new question.
                if isNew {
                    self.animateForwardSequence()
                }
            }
        }
    }
        
    /// Animates a previous card sliding in from the left.
    private func animateCardInFromLeft(text: String) {
        UIView.animate(withDuration: 0.35, animations: {
            // Animate the old card away to the right.
            self.ideaCardShadowContainer.transform = CGAffineTransform(translationX: self.view.frame.width, y: 0)
            self.ideaCardShadowContainer.alpha = 0
        }) { _ in
            // Prepare the new card off-screen to the left.
            self.ideaCardShadowContainer.transform = CGAffineTransform(translationX: -self.view.frame.width, y: 0)
            self.ideaLabel.text = text
                
            // Animate the new card to the center.
            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.8, initialSpringVelocity: 0.5, options: .curveEaseInOut, animations: {
                self.ideaCardShadowContainer.alpha = 1
                self.ideaCardShadowContainer.transform = .identity
            }) { _ in
                self.animateBackwardSequence()
            }
        }
    }
    
    private func resetView() {
        UIView.animate(withDuration: 0.3, animations: {
            self.runningAnimalView1.layer.removeAllAnimations()
            self.runningAnimalView1.alpha = 0
            self.runningAnimalView2.layer.removeAllAnimations()
            self.runningAnimalView2.alpha = 0
            
            
            self.ideaLabel.text = ContentData.getQuestionOfTheDay()?.text ?? "Here’s a fun question!"

            self.ideaCardShadowContainer.alpha = 1
            self.ideaCardShadowContainer.transform = .identity
//            self.getQuestionButton.alpha = 1
                
        }) { _ in
            self.questionHistory.removeAll()
            self.historyIndex = -1
        }
    }
    
    enum AnimalDirection {
        case leftToRight, rightToLeft
    }
    
    /// Orchestrates the "forward" animation: two animals run along the bottom.
    private func animateForwardSequence() {
        let yPosition = mainContentContainer.bounds.height - 60
            
        runAnimal(imageView: runningAnimalView1, imageName: "animal1", atY: yPosition, direction: .leftToRight)
            
        // Schedule the second animal to run after a delay.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.runAnimal(imageView: self.runningAnimalView2, imageName: "animal2", atY: yPosition, direction: .leftToRight)
        }
    }
        
    /// Orchestrates the "backward" animation: two animals run along the top.
    private func animateBackwardSequence() {
        let yPosition: CGFloat = 130
            
        runAnimal(imageView: runningAnimalView1, imageName: "animal1", atY: yPosition, direction: .rightToLeft)
            
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            self.runAnimal(imageView: self.runningAnimalView2, imageName: "animal2", atY: yPosition, direction: .rightToLeft)
        }
    }
        
    // helper function that runs a single animal across the screen.
    private func runAnimal(imageView: UIImageView, imageName: String, atY yPosition: CGFloat, direction: AnimalDirection) {
        imageView.image = UIImage(named: imageName)
        
        imageView.layer.speed = 1
            
        let screenWidth = view.bounds.width
        let animalWidth: CGFloat = 100
        let startX, endX: CGFloat
            
        // Stop any previous animations on this specific image view.
        imageView.layer.removeAllAnimations()
            
        // Determine start/end points and facing direction.
        if direction == .leftToRight {
            startX = -animalWidth
            endX = screenWidth + animalWidth
            imageView.transform = .identity // Face right.
        } else { // rightToLeft
            startX = screenWidth + animalWidth
            endX = -animalWidth
            imageView.transform = CGAffineTransform(scaleX: -1, y: 1) // Flip to face left.
        }
            
        imageView.center = CGPoint(x: startX, y: yPosition)
        imageView.alpha = 1
            
        // Create animations.
        let jiggle = CAKeyframeAnimation(keyPath: "transform.rotation.z")
        jiggle.values = [0, -0.1, 0.1, 0]
        jiggle.keyTimes = [0, 0.25, 0.75, 1]
        jiggle.duration = 0.5
        jiggle.repeatCount = .infinity
        jiggle.isAdditive = true
            
        let run = CABasicAnimation(keyPath: "position.x")
        run.fromValue = startX
        run.toValue = endX
        run.duration = 4.0
            
        // Add animations.
        imageView.layer.add(jiggle, forKey: "jiggleAnimation")
        imageView.layer.add(run, forKey: "runAnimation")
            
        // Schedule this specific image view to hide after its run.
        DispatchQueue.main.asyncAfter(deadline: .now() + run.duration) {
            imageView.alpha = 0
        }
    }
    
    /// A helper to create the running animal image views.
    private func createRunningAnimalView() -> UIImageView {
        let imageView = UIImageView()
        imageView.frame = CGRect(x: 0, y: 0, width: 100, height: 100)
        imageView.contentMode = .scaleAspectFit
        imageView.alpha = 0
        return imageView
    }
    
    
    
    /// Helper function to create a styled heart view.
    private func createHeartView(size: CGFloat, color: UIColor) -> UIImageView {
        let config = UIImage.SymbolConfiguration(pointSize: size)
        let image = UIImage(systemName: "heart.fill", withConfiguration: config)
        let imageView = UIImageView(image: image)
        imageView.tintColor = color
        imageView.frame = CGRect(x: CGFloat.random(in: -100...view.bounds.width), y: CGFloat.random(in: -100...view.bounds.height), width: size, height: size)
        return imageView
    }
    
    
    // A helper function to create a styled, tappable heart button.
    private func createHeartButton(size: CGFloat, color: UIColor) -> UIButton {
        let button = UIButton(type: .custom)
        let config = UIImage.SymbolConfiguration(pointSize: size)
        let image = UIImage(systemName: "heart.fill", withConfiguration: config)
        button.setImage(image, for: .normal)
        button.tintColor = color
        button.frame = CGRect(x: CGFloat.random(in: -100...view.bounds.width), y: CGFloat.random(in: -100...view.bounds.height), width: size, height: size)
        button.addTarget(self, action: #selector(didTapHeartButton(_:)), for: .touchUpInside)
            return button
    }
        
    // Action that fires when a heart is tapped.
    @objc private func didTapHeartButton(_ sender: UIButton) {
        sender.isUserInteractionEnabled = false
        UIView.animate(withDuration: 0.4, animations: {
            sender.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
            sender.alpha = 0
        }) { _ in
            sender.frame.origin.x = CGFloat.random(in: -100...self.view.bounds.width)
            sender.frame.origin.y = self.view.bounds.height + 100
            sender.transform = .identity
            UIView.animate(withDuration: 0.6, delay: 2.0, options: .curveEaseIn, animations: {
                sender.alpha = 1
            }) { _ in
                sender.isUserInteractionEnabled = true
            }
        }
    }
}

#Preview {
    ConversationsViewController()
}


