//
//  TimelineViewModel.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/12/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import RxSwift

extension Timeline {

  enum Route {
    case newTweet
  }

  final class ViewModel {
    struct Inputs {
      let viewWillAppear: Observable<Void>
      let pullToRefresh: Observable<Void>
      let newTweetButtonTap: Observable<Void>
      let postTweet: Observable<ComposedTweet>
      let resendTweet: Observable<Int>
      let dismissError: Observable<Void>
    }

    struct Outputs {
      let props: Observable<TimelineViewController.Props>
      let route: Observable<Route>
      let stateChanges: Observable<Void>
    }

    private let user: User
    private let twitterService: TwitterService

    init(user: User, twitterService: TwitterService) {
      self.user = user
      self.twitterService = twitterService
    }

    func makeOutputs(from inputs: Inputs) -> Outputs {
      let initialState = State(
        user: user,
        allFetchedTweets: [:],
        allPendingTweets: [:],
        timeline: [],
        isLoading: false,
        error: nil
      )
      let resendMiddleware = Timeline.makeResendMiddleware(twitterService: twitterService)
      let store = Store(initialState: initialState, reducer: Timeline.reduce, middlewares: [
        resendMiddleware
        ])

      let props = store.state
        .map(Timeline.makeProps)

      let actionCreator = ActionCreator(inputs: inputs, twitterService: twitterService)

      let stateChanges = actionCreator.actions
        .do(onNext: store.dispatch)
        .map { _ in Void() }

      return Outputs(
        props: props,
        route: inputs.newTweetButtonTap.map { Route.newTweet },
        stateChanges: stateChanges
      )
    }
  }
}
