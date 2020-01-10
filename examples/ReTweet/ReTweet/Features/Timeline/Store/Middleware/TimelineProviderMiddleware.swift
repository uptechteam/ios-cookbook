//
//  TimelineProviderMiddleware.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import RxSwift

extension TimelineViewController {
  static func makeProviderMiddleware(timelineProvider: TimelineProvider) -> Store.Middleware {
    return Store.makeMiddleware { _, getState, next, action in
      let oldState = getState()
      next(action)
      let newState = getState()

      guard let updateIntent = newState.updateIntent, oldState.updateIntent != newState.updateIntent else {
        return
      }

      switch updateIntent.type {
      case .reload:
        timelineProvider.reloadTimeline()

      case .resendTweet(let tweetID):
        timelineProvider.resendTweet(id: tweetID)
      }
    }
  }
}
