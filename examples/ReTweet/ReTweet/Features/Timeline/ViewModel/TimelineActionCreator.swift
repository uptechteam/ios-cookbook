//
//  TimelineActionCreator.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import RxSwift

extension Timeline {
  final class ActionCreator {
    let actions: Observable<Action>

    init(inputs: ViewModel.Inputs, twitterService: TwitterService) {
      let fetchTweetsActions = Observable.merge(
        inputs.viewWillAppear.take(1),
        inputs.pullToRefresh
      )
        .flatMapLatest {
          twitterService.getTimeline(offset: 0, limit: 100)
            .map(Action.loadTweetsSuccess)
            .catchError { error in Observable.just(Action.loadTweetsFailure(error)) }
            .startWith(Action.loadTweets)
        }

      let postTweetActions = inputs.postTweet
        .flatMap { newTweet in
          return twitterService.postTweet(newTweet)
            .map(Action.sendTweetSuccess)
            .catchError { error in Observable.just(Action.sendTweetFailure(id: newTweet.id, error: error)) }
            .startWith(Action.sendTweet(newTweet))
        }

      let resendTweetAction = inputs.resendTweet
        .map(Action.resendTweet)

      let dismissErrorAction = inputs.dismissError
        .map { Action.dismissError }

      self.actions = Observable.merge(
        fetchTweetsActions,
        postTweetActions,
        resendTweetAction,
        dismissErrorAction
      )
    }
  }
}
