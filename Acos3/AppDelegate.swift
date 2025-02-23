//
//  AppDelegate.swift
//  Acos3
//
//  Created by mac on 2021/05/10.
//

import UIKit
import Firebase
import GoogleSignIn
import GoogleMobileAds

import FirebaseAuth
import AuthenticationServices
import CryptoKit
import IQKeyboardManagerSwift

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    
    // PhotoVC이미지를 appDelegate에 저장하여 Asynchronous 방식으로 불러온다
    var imgApp : UIImage?
    
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        
        window = UIWindow(frame: UIScreen.main.bounds)
                
        // Override point for customization after application launch.
        FirebaseApp.configure()
        
        let settings = FirestoreSettings()
        settings.isPersistenceEnabled = false
        Firestore.firestore().settings = settings

        //구글로그인
        GIDSignIn.sharedInstance().clientID = FirebaseApp.app()?.options.clientID
        
        
        //애드몹
        GADMobileAds.sharedInstance().start(completionHandler: nil)
        
        UIApplication.setupHud()
            
        IQKeyboardManager.shared.enable = true
        IQKeyboardManager.shared.shouldResignOnTouchOutside = true
        
        return true
    }

    // MARK: UISceneSession Lifecycle

    func application(_ application: UIApplication, configurationForConnecting connectingSceneSession: UISceneSession, options: UIScene.ConnectionOptions) -> UISceneConfiguration {
        // Called when a new scene session is being created.
        // Use this method to select a configuration to create the new scene with.
        return UISceneConfiguration(name: "Default Configuration", sessionRole: connectingSceneSession.role)
    }

    func application(_ application: UIApplication, didDiscardSceneSessions sceneSessions: Set<UISceneSession>) {
        // Called when the user discards a scene session.
        // If any sessions were discarded while the application was not running, this will be called shortly after application:didFinishLaunchingWithOptions.
        // Use this method to release any resources that were specific to the discarded scenes, as they will not return.
    }
}

