//
//  TimelineProps.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/18/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

extension Timeline {
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

    func makePendingCellProps(from pendingTweet: State.PendingTweet) -> TimelinePendingTweetCell.Props {
      return TimelinePendingTweetCell.Props(
        username: state.user.username,
        time: DateFormatter.shortTime.string(from: pendingTweet.tweet.sentDate),
        tweet: pendingTweet.tweet.text,
        status: pendingTweet.error == nil ? .sending : .error
      )
    }

    return state.timeline
      .compactMap { tweetID in
        if let pendingTweet = state.allPendingTweets[tweetID] {
          return .pendingTweet(makePendingCellProps(from: pendingTweet))
        } else if let fetchedTweet = state.allFetchedTweets[tweetID] {
          return .tweet(makeTweetCellProps(from: fetchedTweet))
        } else {
          fatalError("State is out of sync!")
        }
      }
  }
}
