//
//  TabBarController.swift
//  spravochnik_spz
//
//  Created by Swift Learning on 06.02.2023.
//

import UIKit

final class TabBarController: UITabBarController {
    // MARK: - PrivateProperties
    
    private let sceneBuildManager: Buildable = SceneBuildManager()
    // MARK: - LifeCycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupTabBarController()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.isNavigationBarHidden = true
    }
}

private extension TabBarController {
    func setupTabBarController() {
        let mainViewController = sceneBuildManager.buildMainScreen()
        let savedCalculationViewController = sceneBuildManager.buildSavedCalculationsScreen()
        let profileViewController = sceneBuildManager.buildProfileScreen()
        
        let navMainViewController = UINavigationController(rootViewController: mainViewController)
        let navSavedCalculationViewController = UINavigationController(rootViewController: savedCalculationViewController)
        let navProfileViewController = UINavigationController(rootViewController: profileViewController)
        
        mainViewController.tabBarItem.image = Constants.Images.tabBarMain
        savedCalculationViewController.tabBarItem.image = Constants.Images.tabBarSaved
        navProfileViewController.tabBarItem.image = Constants.Images.tabBarProfile
        
        tabBar.tintColor = .black
        tabBar.backgroundColor = .systemBackground
        
        viewControllers = [navMainViewController,
                           navSavedCalculationViewController,
                           navProfileViewController]
    }
}

