//
//  TimelineStore.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

extension Timeline {
  typealias Store = ReduxStore<State, Action>

  struct State {
    struct PendingTweet {
      let tweet: ComposedTweet
      var error: Error?
    }

    let user: User
    var allFetchedTweets: [Tweet.Identifier: Tweet]
    var allPendingTweets: [Tweet.Identifier: PendingTweet]
    var timeline: [Tweet.Identifier]
    var isLoading: Bool
    var error: Error?
  }

  enum Action {
    case loadTweets
    case loadTweetsSuccess([Tweet])
    case loadTweetsFailure(Error)

    case sendTweet(ComposedTweet)
    case sendTweetSuccess(Tweet)
    case sendTweetFailure(id: Tweet.Identifier, error: Error)

    case resendTweet(index: Int)
    case dismissError
  }

  static func reduce(state: State, action: Action) -> State {
    var newState = state
    switch action {
    case .loadTweets:
      newState.isLoading = true

    case .loadTweetsSuccess(let newTweets):
      newTweets.forEach { newState.allFetchedTweets[$0.id] = $0 }
      newState.isLoading = false

      let timelinePendingTweets = state.allPendingTweets.values.map { (id: $0.tweet.id, date: $0.tweet.sentDate) }
      let timelineFetchedTweets = newTweets.map { (id: $0.id, date: $0.date) }

      newState.timeline = (timelinePendingTweets + timelineFetchedTweets)
        .sorted { $0.date > $1.date }
        .map { $0.id }

    case .loadTweetsFailure(let error):
      newState.error = error
      newState.isLoading = false

    case .sendTweet(let newComposedTweet):
      newState.allPendingTweets[newComposedTweet.id] = State.PendingTweet(tweet: newComposedTweet, error: nil)
      newState.timeline.insert(newComposedTweet.id, at: 0)

    case .sendTweetSuccess(let fetchedTweet):
      newState.allPendingTweets[fetchedTweet.id] = nil
      newState.allFetchedTweets[fetchedTweet.id] = fetchedTweet

    case .sendTweetFailure(let tweetID, let error):
      newState.allPendingTweets[tweetID]?.error = error

    case .resendTweet(let index):
      let tweetID = state.timeline[index]
      newState.allPendingTweets[tweetID]?.error = nil

    case .dismissError:
      newState.error = nil
    }

    return newState
  }
}
