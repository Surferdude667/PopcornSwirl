//
//  SceneDelegate.swift
//  PopcornSwirl
//
//  Created by Bjørn Lau Jørgensen on 03/06/2020.
//  Copyright © 2020 Bjørn Lau Jørgensen. All rights reserved.
//

import UIKit
import NotificationBannerSwift
import Reachability

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?
    private let reachability = try! Reachability()
    private var lostBanner: StatusBarNotificationBanner?
    private var restoredBanner: StatusBarNotificationBanner?
    private var isReachabilityConfigured = false
    
    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }
    }

    func sceneDidDisconnect(_ scene: UIScene) {
        // Called as the scene is being released by the system.
        // This occurs shortly after the scene enters the background, or when its session is discarded.
        // Release any resources associated with this scene that can be re-created the next time the scene connects.
        // The scene may re-connect later, as its session was not neccessarily discarded (see `application:didDiscardSceneSessions` instead).
    }

    func sceneDidBecomeActive(_ scene: UIScene) {
        configureReachability()
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

        // Save changes in the application's managed object context when the application transitions to the background.
        (UIApplication.shared.delegate as? AppDelegate)?.saveContext()
    }

    private func configureReachability() {
        
        guard !isReachabilityConfigured else { return }
        
        reachability.whenReachable = { [weak self] reachability in
            guard let self = self else { return }

            if let banner = self.lostBanner {
                NotificationCenter.default.post(name: .connectionRestored, object: nil)
                banner.dismiss()
                self.restoredBanner?.show()
            } else {
                self.lostBanner = StatusBarNotificationBanner(title: "No Internet Connection.", style: .danger, colors: nil)
                self.restoredBanner = StatusBarNotificationBanner(title: "You are back online!", style: .success, colors: nil)
                self.lostBanner?.autoDismiss = false
            }
        }
        
        reachability.whenUnreachable = { [weak self] _ in
            guard let self = self else { return }
            if let banner = self.lostBanner {
                NotificationCenter.default.post(name: .connectionLost, object: nil)
                banner.show()
            } else {
                NotificationCenter.default.post(name: .connectionLost, object: nil)
                self.lostBanner = StatusBarNotificationBanner(title: "No Internet Connection...", style: .danger, colors: nil)
                self.lostBanner?.autoDismiss = false
                self.lostBanner?.show()
            }
        }

        do {
            try reachability.startNotifier()
        } catch {
            print("Unable to start notifier")
        }
        
        isReachabilityConfigured = true
    }

}

