//
//  TimelineResendMiddleware.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import RxSwift

extension Timeline {
  static func makeResendMiddleware(twitterService: TwitterService) -> Store.Middleware {
    let disposeBag = DisposeBag()
    return Store.makeMiddleware { dispatch, getState, next, action in
      next(action)
      let state = getState()

      guard case Action.resendTweet(let index) = action else {
        return
      }

      let tweetID = state.timeline[index]
      guard let pendingTweet = state.allPendingTweets[tweetID] else {
        fatalError("STATE IS OUR OF SYNC")
      }

      twitterService.postTweet(pendingTweet.tweet)
        .map(Action.sendTweetSuccess)
        .catchError { error in Observable.just(Action.sendTweetFailure(id: tweetID, error: error)) }
        .subscribe(onNext: dispatch)
        .disposed(by: disposeBag)
    }
  }
}
