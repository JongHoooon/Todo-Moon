//
//  TabBarViewController.swift
//  Todo-Moon
//
//  Created by JongHoon on 2022/12/13.
//

import UIKit
import Then

final class TabBarViewController: UITabBarController {
    
    // MARK: - Constants
    
    // MARK: - Property
    
    let provider: ServiceProviderType
    
    // MARK: - UI
    
    let todoTabBarItem = UITabBarItem(title: nil,
                                      image: UIImage(systemName: "checklist"),
                                      selectedImage: UIImage(systemName: "checklist"))
    
    let memoTabBarItem = UITabBarItem(title: nil,
                                      image: UIImage(systemName: "list.bullet.rectangle"),
                                      selectedImage: UIImage(systemName: "list.bullet.rectangle.fill"))
    
    // MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setTabBar()
    }
    
    // MARK: - Init
    
    init(provider: ServiceProviderType) {
        self.provider = provider
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}

// MARK: - Method

extension TabBarViewController {
    
    private func setTabBar() {
        self.tabBar.backgroundColor = .systemGray6

        let todoViewController = UIViewController().then {
            $0.tabBarItem = todoTabBarItem
        }
        
        let memoViewController = UIViewController().then {
            $0.tabBarItem = memoTabBarItem
        }
        
        self.viewControllers = [todoViewController, memoViewController]
    }
}
