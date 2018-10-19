//
//  AppDelegate.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import UIKit
import RxSwift
import Moya

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

  var window: UIWindow?

  func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {

    let window = UIWindow()
    self.window = window

    let user = User(username: "Arthur")
    let twitterService = TwitterService(
      user: user,
      provider: MoyaProvider<TwitterTarget>(plugins: [NetworkLoggerPlugin(verbose: true, cURL: true)])
    )

    let timelineViewController = TimelineViewController(user: user, twitterService: twitterService)
    let timelineNavigationController = UINavigationController(rootViewController: timelineViewController)
    window.rootViewController = timelineNavigationController
    window.makeKeyAndVisible()

    return true
  }
}
