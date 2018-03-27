//
//  AppDelegate.swift
//  BackgroundUpload
//
//  Created by Sven Weidauer on 27.03.18.
//  Copyright © 2018 Sven Weidauer. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, handleEventsForBackgroundURLSession identifier: String, completionHandler: @escaping () -> Void) {
        (window?.rootViewController as? ViewController)?.handleBackgroundEvents(identifier: identifier, handler: completionHandler)
    }

}

