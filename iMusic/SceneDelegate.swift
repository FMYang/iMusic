//
//  SceneDelegate.swift
//  iMusic
//
//  Created by yfm on 2023/11/17.
//

import UIKit

class SceneDelegate: UIResponder, UIWindowSceneDelegate {

    var window: UIWindow?

//    var backgroundTask: UIBackgroundTaskIdentifier = .invalid
//    var timer: Timer?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        guard let windowScene = (scene as? UIWindowScene) else { return }
        window = UIWindow(windowScene: windowScene)
        window?.backgroundColor = .white
        let vc = RootVC()
        let nav = UINavigationController(rootViewController: vc)
        window?.rootViewController = nav
        window?.makeKeyAndVisible()
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
//        backgroundMode()
    }

}

// MARK: - 后台保活
extension SceneDelegate {
//    func backgroundMode() {
//        print(Date())
//        // 创建一个背景任务去和系统请求后台运行的时间
//        backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//            guard let self = self else { return }
//            UIApplication.shared.endBackgroundTask(self.backgroundTask)
//            self.backgroundTask = .invalid
//        }
//        
//        timer = Timer.scheduledTimer(timeInterval: 10.0, target: self, selector: #selector(applyToSystemForMoreTime), userInfo: nil, repeats: true)
//        timer?.fire()
//    }

//    @objc func applyToSystemForMoreTime() {
//        if UIApplication.shared.backgroundTimeRemaining < 30.0 { // 如果剩余时间小于30秒
//            UIApplication.shared.endBackgroundTask(backgroundTask)
//            backgroundTask = UIApplication.shared.beginBackgroundTask { [weak self] in
//                guard let self = self else { return }
//                UIApplication.shared.endBackgroundTask(self.backgroundTask)
//                self.backgroundTask = .invalid
//            }
//        }
//    }
}

