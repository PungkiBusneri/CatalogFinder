//
//  TabBarController.swift
//  CatalogFinder
//
//  Created by Pungki Busneri on 03/12/23.
//

import UIKit

class TabBarController: UITabBarController, UITabBarControllerDelegate {

    override func viewDidLoad() {
        super.viewDidLoad()
        navigationController?.setNavigationBarHidden(true, animated: false)
        setupTabs()
        self.tabBar.backgroundColor = .systemGray6
        self.tabBar.unselectedItemTintColor = .separator
        self.tabBar.tintColor = UIColor(named: "PinkColor")
        
        let topBorder = CALayer()
        topBorder.frame = CGRect(x: 0, y: 0, width: tabBar.frame.width, height: 1)
        topBorder.backgroundColor = UIColor.systemGray5.cgColor
        tabBar.layer.addSublayer(topBorder)
        
        tabBar.layer.cornerRadius = 25
        tabBar.layer.masksToBounds = true
    }
    
    private func setupTabs() {
        
        let home = self.createNav(with: "Beranda", and: UIImage(systemName: "house"), vc: CatalogViewController())
        
        let recomanded = self.createNav(with: "Rekomendasi", and: UIImage(systemName: "heart"), vc: RecomandedViewController())
        
        let profil = self.createNav(with: "Saya", and: UIImage(systemName: "person"), vc: ProfilViewController())
        
        self.setViewControllers([home, recomanded, profil], animated: true)
        
    }
    private func createNav(with title: String, and image: UIImage?, vc: UIViewController) -> UINavigationController {
        let nav = UINavigationController(rootViewController: vc)
        
        nav.tabBarItem.title = title
        nav.tabBarItem.image = image
        
        return nav
    }
}


