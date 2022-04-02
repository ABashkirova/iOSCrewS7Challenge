//
//  SceneDelegate.swift
//  AnimateMe
//
//  Created by katleta3000 on 21.11.2021.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {
	var window: UIWindow?
    
	func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
		guard let _ = (scene as? UIWindowScene) else { return }
        UIScreen.main.focusedView?.window?.backgroundColor = .systemBackground
	}
}

