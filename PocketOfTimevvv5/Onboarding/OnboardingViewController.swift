//
//  OnboardingViewController.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//


import UIKit

class OnboardingViewController: UIViewController, UIPageViewControllerDataSource, UIPageViewControllerDelegate {
    
    // --- UI Components ---
    private var pageViewController: UIPageViewController!
    private var pageControl: UIPageControl!
    
    // --- Data ---
    private var slides: [OnboardingSlide] = []
    private var currentIndex = 0

    // --- View Lifecycle ---
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        
        setupSlides()
        setupPageViewController()
        setupPageControl()
        setupGetStartedButton()
    }
    
    // --- Setup ---
    
    private func setupSlides() {
        slides = [
            OnboardingSlide(title: "Welcome to Pocket of Time",
                            description: "This isn't another to-do list. It's a tool to help you find and cherish small moments of connection with your loved ones.",
                            imageName: "sparkles"),
            OnboardingSlide(title: "Instant Ideas, Zero Stress",
                            description: "When you're out of ideas, we'll make the decision for you. Get a simple activity or conversation starter in one tap.",
                            imageName: "lightbulb"),
            OnboardingSlide(title: "Capture the Good Stuff",
                            description: "Quickly save the little memories that make you smile, creating a private journal of your favorite moments.",
                            imageName: "heart.rectangle")
        ]
    }
    
    private func setupPageViewController() {
        // Instantiate the UIPageViewController
        pageViewController = UIPageViewController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
        pageViewController.dataSource = self
        pageViewController.delegate = self
        
        // Create the first page
        if let firstViewController = contentViewController(at: 0) {
            pageViewController.setViewControllers([firstViewController], direction: .forward, animated: true, completion: nil)
        }
        
        // Add the PageViewController's view to our main view
        addChild(pageViewController)
        view.addSubview(pageViewController.view)
        pageViewController.didMove(toParent: self)
        
        // Disable autoresizing masks to use Auto Layout
        pageViewController.view.translatesAutoresizingMaskIntoConstraints = false
        
        // Set constraints
        NSLayoutConstraint.activate([
            pageViewController.view.topAnchor.constraint(equalTo: view.topAnchor),
            pageViewController.view.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pageViewController.view.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pageViewController.view.bottomAnchor.constraint(equalTo: view.bottomAnchor)
        ])
    }
    
    private func setupPageControl() {
        pageControl = UIPageControl()
        pageControl.translatesAutoresizingMaskIntoConstraints = false
        pageControl.numberOfPages = slides.count
        pageControl.currentPage = 0
        pageControl.currentPageIndicatorTintColor = .systemIndigo
        pageControl.pageIndicatorTintColor = .systemGray4
        view.addSubview(pageControl)
        
        NSLayoutConstraint.activate([
            pageControl.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            // Position it above the button
            pageControl.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -80)
        ])
    }
    
    private func setupGetStartedButton() {
        let button = UIButton(type: .system)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Get Started", for: .normal)
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        button.tintColor = .white
        button.backgroundColor = .systemIndigo
        button.layer.cornerRadius = 12
        button.addTarget(self, action: #selector(didTapGetStarted), for: .touchUpInside)
        
        view.addSubview(button)
        
        NSLayoutConstraint.activate([
            button.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 40),
            button.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -40),
            button.heightAnchor.constraint(equalToConstant: 50),
            button.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -20)
        ])
    }
    
    // --- Helper to create a single slide's view controller ---
    
    private func contentViewController(at index: Int) -> OnboardingContentViewController? {
        guard index >= 0 && index < slides.count else {
            return nil
        }
        let contentVC = OnboardingContentViewController()
        contentVC.slide = slides[index]
        contentVC.pageIndex = index
        return contentVC
    }
    
    // --- Actions ---
    
    @objc private func didTapGetStarted() {
        // 1. Mark onboarding as completed.
        // UserDefaults is a simple way to store a small piece of data.
        UserDefaults.standard.set(true, forKey: "hasCompletedOnboarding")
        
        // 2. Dismiss this screen and show the main app.
        // We find our SceneDelegate to change the rootViewController.
        if let sceneDelegate = self.view.window?.windowScene?.delegate as? SceneDelegate {
            sceneDelegate.showMainApp()
        }
    }
    
    // --- UIPageViewControllerDataSource ---
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerBefore viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingContentViewController else { return nil }
        let currentIndex = currentVC.pageIndex
        let previousIndex = currentIndex - 1
        return contentViewController(at: previousIndex)
    }
    
    func pageViewController(_ pageViewController: UIPageViewController, viewControllerAfter viewController: UIViewController) -> UIViewController? {
        guard let currentVC = viewController as? OnboardingContentViewController else { return nil }
        let currentIndex = currentVC.pageIndex
        let nextIndex = currentIndex + 1
        return contentViewController(at: nextIndex)
    }
    
    // --- UIPageViewControllerDelegate ---
    
    func pageViewController(_ pageViewController: UIPageViewController, didFinishAnimating finished: Bool, previousViewControllers: [UIViewController], transitionCompleted completed: Bool) {
        if completed {
            if let currentVC = pageViewController.viewControllers?.first as? OnboardingContentViewController {
                currentIndex = currentVC.pageIndex
                pageControl.currentPage = currentIndex
            }
        }
    }
}

#Preview {
    OnboardingViewController()
}

