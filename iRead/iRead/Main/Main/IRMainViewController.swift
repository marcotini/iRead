//
//  IRMainViewController.swift
//  iRead
//
//  Created by zzyong on 2020/9/24.
//  Copyright © 2020 zzyong. All rights reserved.
//

import UIKit
import IRCommonLib

enum IRTabBarIndex: Int {
    case home      = 0
    case bookshelf = 1
    case mine      = 2
}

enum IRTabBarName: String {
    case home      = "Home"
    case bookshelf = "Bookshelf"
    case explore   = "Explore"
}

class IRMainViewController: UITabBarController, UITabBarControllerDelegate {

    var initOnceAfterViewDidAppear = false
    lazy var bookshelfVC = IRBookshelfViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.commonInit()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        self.initAfterViewDidAppear()
    }
    
    override var selectedIndex: Int {
        willSet {
            self.updateNavigationItems(withIndex: newValue)
        }
    }
    
    // MARK: - Private
    
    func initAfterViewDidAppear() {
        if initOnceAfterViewDidAppear {
            return
        }
        initOnceAfterViewDidAppear = true
    }
    
    func commonInit() {
        view.backgroundColor = .white
        self.delegate = self
        self.setupTabbarItems()
        updateNavigationItems(withIndex: IRTabBarIndex.home.rawValue)
    }
    
    func setupTabbarItems() {
        self.tabBar.tintColor = IRAppThemeColor
        
        let tabbarTitles = [IRTabBarName.home.rawValue, IRTabBarName.bookshelf.rawValue, IRTabBarName.explore.rawValue]
        var childViewControllers = [UIViewController]()
        
        for (index, _) in tabbarTitles.enumerated() {
            childViewControllers.append(self.childViewController(withTabIndex: index))
        }
        self.viewControllers = childViewControllers
        
        for (index, item) in self.tabBar.items!.enumerated() {
            var normalName: String?, selectName: String?
            switch index {
            case IRTabBarIndex.home.rawValue:
                normalName = "tabbar_home_n"; selectName = "tabbar_home_s"
            case IRTabBarIndex.bookshelf.rawValue:
                normalName = "tabbar_bookshelf_n"; selectName = "tabbar_bookshelf_s"
            case IRTabBarIndex.mine.rawValue:
                normalName = "tabbar_explore_n"; selectName = "tabbar_explore_s"
            default:
                IRDebugLog("TabIndex: (\(index)) undefine")
            }
            item.title = tabbarTitles[index]
            if let normalName = normalName, let selectName = selectName {
                item.image = UIImage.init(named: normalName)?.withRenderingMode(.alwaysOriginal)
                item.selectedImage = UIImage.init(named: selectName)?.withRenderingMode(.alwaysOriginal)
            }
        }
    }
    
    func childViewController(withTabIndex index: Int) -> UIViewController {
        var vc: UIViewController
        switch index {
        case IRTabBarIndex.home.rawValue:
            vc = IRHomeViewController()
        case IRTabBarIndex.bookshelf.rawValue:
            vc = bookshelfVC
        case IRTabBarIndex.mine.rawValue:
            vc = IRExploreViewController()
        default:
            vc = UIViewController()
        }
        return vc
    }
    
    func updateNavigationItems(withIndex index: Int) {
        navigationItem.rightBarButtonItems = selectedViewController?.navigationItem.rightBarButtonItems
        navigationItem.leftBarButtonItems = selectedViewController?.navigationItem.leftBarButtonItems
        
        if let titleView = selectedViewController?.navigationItem.titleView {
            navigationItem.titleView = titleView
            navigationItem.title = nil
        } else {
            navigationItem.title = selectedViewController?.navigationItem.title
            navigationItem.titleView = nil
        }
    }
    
    // MARK: - UITabBarControllerDelegate
    func tabBarController(_ tabBarController: UITabBarController, didSelect viewController: UIViewController) {
        self.updateNavigationItems(withIndex: tabBarController.viewControllers?.firstIndex(of:viewController) ?? IRTabBarIndex.home.rawValue)
    }
}
