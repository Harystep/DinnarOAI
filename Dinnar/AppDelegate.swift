//
//  AppDelegate.swift
//  Dinnar
//
//  Created by Lizheng Pang on 2023/5/20.
//

import UIKit
import IQKeyboardManagerSwift
@main
class AppDelegate: UIResponder, UIApplicationDelegate {
    var window: UIWindow?



    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        window = UIWindow.init(frame: UIScreen.main.bounds)
        window?.backgroundColor = UIColor.white
//        let islogin = DataTool.getToken() != nil
//        if !islogin{
//            self.window?.rootViewController =  LoginViewController.initWithNib()
//        } else {
//        }
        let navC = UINavigationController.init(rootViewController:SelectVC.initWithNib())
        navC.navigationBar.isHidden = true
        self.window?.rootViewController =  navC
        IQKeyboardManager.shared.enable = true
        window?.makeKeyAndVisible()
        
        
        // Override point for customization after application launch.
        return true
    }




}

