//
//  AppDelegate.swift
//  AccountBook
//
//  Created by 최호주 on 2021/08/25.
//

import UIKit

import FBSDKCoreKit
import Firebase
import GoogleSignIn

@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        FirebaseApp.configure()
        
        GIDSignIn.sharedInstance.restorePreviousSignIn { user, error in
            if error != nil || user == nil {
                // Show the app's signed-out state.
            } else {
                // Show the app's signed-in state.
            }
        }
        
        ApplicationDelegate.shared.application(application, didFinishLaunchingWithOptions: launchOptions)
        
        window = UIWindow(frame: UIScreen.main.bounds)
        
        UINavigationBar.appearance().tintColor = .white
        let appearance = UINavigationBarAppearance()
        appearance.configureWithDefaultBackground()
        appearance.backgroundColor = .systemIndigo
        appearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        UINavigationBar.appearance().standardAppearance = appearance
        UINavigationBar.appearance().scrollEdgeAppearance = appearance
        
        let tabBarController = TabBarController()
        let db = Firestore.firestore()
        let api = ABAPI(db: db)
        let provider = ABProvider(api: api)
        provider.setUP()
        let tabBarViewModel = TabBarViewModel(provider: provider)
        tabBarController.viewModel = tabBarViewModel
        
        window?.rootViewController = tabBarController
        window?.makeKeyAndVisible()
        
        return true
    }
    
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        if url.scheme == "gati",
           let component = URLComponents(string: url.absoluteString) {
            let queryItems = component.queryItems ?? []
            let parameters = Dictionary(grouping: queryItems, by: { $0.name })
                .mapValues({ $0.first!.value! })
            
            switch url.host {
            case "invite":
                if let id = parameters["id"] {
                    print("invite: ", id)
                }
            default:
                break
            }
        }
        return GIDSignIn.sharedInstance.handle(url)
            || ApplicationDelegate.shared.application(
                app,
                open: url,
                sourceApplication: options[UIApplication.OpenURLOptionsKey.sourceApplication] as? String,
                annotation: options[UIApplication.OpenURLOptionsKey.annotation])
    }

}

