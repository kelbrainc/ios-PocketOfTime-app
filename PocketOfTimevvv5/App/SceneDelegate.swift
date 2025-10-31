//
//  SceneDelegate.swift
//  PocketOfTime
//
//  Created by Kelly Chui on 23/10/25.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options: UIScene.ConnectionOptions) {
        
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        
        // --- ONBOARDING LOGIC ---
        // Check UserDefaults for our 'hasCompletedOnboarding' flag.
        let hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if hasCompletedOnboarding {
            // If they've seen it before, go straight to the main app.
            showMainApp()
        } else {
            // If it's their first time, show the onboarding screen.
            showOnboarding()
        }
        
        window?.makeKeyAndVisible()
    }

    // This function sets the root view controller to our main Tab Bar App
    func showMainApp() {
        let tabBarController = createTabBarController()
        
        // Animate the transition for a smoother experience
        if let window = self.window {
            UIView.transition(with: window,
                              duration: 0.3,
                              options: .transitionCrossDissolve,
                              animations: {
                                  window.rootViewController = tabBarController
                              },
                              completion: nil)
        } else {
            window?.rootViewController = tabBarController
        }
    }
    
    // This function sets the root view controller to the Onboarding screen
    func showOnboarding() {
        let onboardingVC = OnboardingViewController()
        window?.rootViewController = onboardingVC
    }
    
    // 
    func createTabBarController() -> UITabBarController {
        // (No changes here)
        let tabBarController = UITabBarController()
        tabBarController.tabBar.tintColor = .systemIndigo
        tabBarController.viewControllers = [
            createActivitiesNavController(),
            createConversationsNavController(),
            createMyMomentsNavController()
        ]
        return tabBarController
    }
    
    func createActivitiesNavController() -> UINavigationController {
        // (No changes here)
        let activitiesVC = ActivitiesViewController()
        activitiesVC.title = "Activities"
        activitiesVC.tabBarItem = UITabBarItem(title: "Activities", image: UIImage(systemName: "figure.play"), tag: 0)
        
        let navController = UINavigationController(rootViewController: activitiesVC)
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
    
    func createConversationsNavController() -> UINavigationController {
        // (No changes here)
        let conversationsVC = ConversationsViewController()
        conversationsVC.title = "Conversations"
        conversationsVC.tabBarItem = UITabBarItem(title: "Conversations", image: UIImage(systemName: "bubble.left.and.bubble.right"), tag: 1)
        
        let navController = UINavigationController(rootViewController: conversationsVC)
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
    }
    
    func createMyMomentsNavController() -> UINavigationController {
        // (No changes here)
        let myMomentsVC = MyMomentsViewController()
        myMomentsVC.title = "My Moments"
        myMomentsVC.tabBarItem = UITabBarItem(title: "Moments", image: UIImage(systemName: "heart.rectangle"), tag: 2)
        
        let navController = UINavigationController(rootViewController: myMomentsVC)
        navController.navigationBar.prefersLargeTitles = true
        
        return navController
        
    }


    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not necessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        // Called when the scene has moved from an inactive state to an active state.
        // Use this method to restart any tasks that were paused (or not yet started) when the scene was inactive.
    }

    func sceneWillResignActive(_ scene: UIScene) {
        // Called when the scene will move from an active state to an inactive state.
        // This may occur due to temporary interruptions (ex. an incoming phone call).
    }

    func sceneWillEnterForeground(_ scene: UIScene) {
        // Called as the scene transitions from the background to the foreground.
        // Use this method to undo the changes made on entering the background.
    }

    func sceneDidEnterBackground(_ scene: UIScene) {
        // Called as the scene transitions from the foreground to the background.
        // Use this method to save data, release shared resources, and store enough scene-specific state information
        // to restore the scene back to its current state.
    }


}

