//
//  TimelineStore.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

extension TimelineViewController {
  typealias Store = ReduxStore<State, Action>

  struct TimelineUpdateIntent: Equatable {
    private let id: UUID = UUID()
    let type: UpdateType

    enum UpdateType: Equatable {
      case reload
      case resendTweet(Tweet.Identifier)
    }
  }

  struct State {
    let user: User
    var timeline: [TimelineTweet]
    var isLoading: Bool
    var updateIntent: TimelineUpdateIntent?
    var error: Error?
  }

  enum Action {
    case loadTweets
    case updateTimeline([TimelineTweet])
    case resendTweet(index: Int)
    case displayTimelineError(Error)
    case dismissError
  }

  static func reduce(state: State, action: Action) -> State {
    var newState = state
    switch action {
    case .loadTweets:
      newState.isLoading = true
      newState.updateIntent = .init(type: .reload)

    case .updateTimeline(let timeline):
      newState.timeline = timeline
      newState.isLoading = false

    case .resendTweet(let index):
      guard case .pending(let tweet, _) = state.timeline[index] else {
        print("Error")
        break
      }

      newState.updateIntent = .init(type: .resendTweet(tweet.id))

    case .displayTimelineError(let error):
      newState.error = error
      newState.isLoading = false

    case .dismissError:
      newState.error = nil
    }

    return newState
  }
}
