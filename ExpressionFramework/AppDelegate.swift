//
//  AppDelegate.swift
//  ExpressionFramework
//
//  Created by Andriusstep on 18/10/2017.
//  Copyright © 2017 Andriusstep. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?


    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        let string = try! NSString(contentsOf: URL(string:"http://macbook-pro.local:8000/1.json")!, encoding: String.Encoding.utf8.rawValue)
        print(string)
        return true
    }
}

