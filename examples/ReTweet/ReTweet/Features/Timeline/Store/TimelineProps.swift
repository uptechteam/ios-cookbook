//
//  TimelineProps.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

extension TimelineViewController {
  static func makeProps(from state: State) -> TimelineViewController.Props {
    return TimelineViewController.Props(
      items: makeItems(from: state),
      isLoading: state.isLoading,
      error: state.error?.localizedDescription
    )
  }

  private static func makeItems(from state: State) -> [TimelineViewController.Props.Item] {
    func makeTweetCellProps(from tweet: Tweet) -> TimelineTweetCell.Props {
      return TimelineTweetCell.Props(
        username: tweet.username,
        time: DateFormatter.shortTime.string(from: tweet.date),
        avatarURL: tweet.avatar,
        tweet: tweet.text,
        likesAmount: tweet.likesAmount
      )
    }

    func makePendingCellProps(tweet: ComposedTweet, error: Error?) -> TimelinePendingTweetCell.Props {
      return TimelinePendingTweetCell.Props(
        username: state.user.username,
        time: DateFormatter.shortTime.string(from: tweet.sentDate),
        tweet: tweet.text,
        status: error == nil ? .sending : .error
      )
    }

    return state.timeline
      .map { timelineTweet in
        switch timelineTweet {
        case let .pending(composedTweet, error):
          return .pendingTweet(makePendingCellProps(tweet: composedTweet, error: error))
        case let .remote(remoteTweet):
          return .tweet(makeTweetCellProps(from: remoteTweet))
        }
      }
  }
}
