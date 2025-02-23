//
//  SceneDelegate.swift
//  Acos3
//
//  Created by mac on 2021/05/10.
//

import UIKit

import FirebaseAuth
import AuthenticationServices
import CryptoKit


class SceneDelegate: UIResponder, UIWindowSceneDelegate {
    
    var window: UIWindow?

    func scene(_ scene: UIScene, willConnectTo session: UISceneSession, options connectionOptions: UIScene.ConnectionOptions) {
        // Use this method to optionally configure and attach the UIWindow `window` to the provided UIWindowScene `scene`.
        // If using a storyboard, the `window` property will automatically be initialized and attached to the scene.
        // This delegate does not imply the connecting scene or session are new (see `application:configurationForConnectingSceneSession` instead).
        guard let _ = (scene as? UIWindowScene) else { return }

        //KeychainItem.currentUserIdentifier
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        appleIDProvider.getCredentialState(forUserID: "000389.29e9746a418f4a128c01078a39738e7b.0748") { (credentialState, error) in
            switch credentialState {
            case .authorized:
                DispatchQueue.main.async {
                    self.window?.rootViewController?.showHomeVC()
                }
                print("a")
                
            // The Apple ID credential is valid.
            case .revoked, .notFound:
                // The Apple ID credential is either revoked or was not found, so show the sign-in UI.
                //            DispatchQueue.main.async {
                //                self.window?.rootViewController?.showLoginViewController()
                //            }
                //            print("b")
                break
            default:
                break
            }
        }
        
        // go to home if already login
        if Auth.auth().currentUser != nil {
            
            let tabVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(identifier: Constants.Storyboard2.tabBarController) as? UITabBarController
            #if DEBUG
            tabVC?.selectedIndex = 0
            #endif
            self.window?.rootViewController = tabVC
            self.window?.makeKeyAndVisible()
        }
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

