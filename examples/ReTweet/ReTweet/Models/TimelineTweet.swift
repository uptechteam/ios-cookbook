//
//  TimelineTweet.swift
//  ReTweet
//
//  Created by Arthur Mironenko on 10.01.2020.
//  Copyright © 2020 Arthur Mironenko. All rights reserved.
//

import Foundation

enum TimelineTweet {
  case pending(ComposedTweet, error: Error?)
  case remote(Tweet)
}

extension TimelineTweet {
  var isRemote: Bool {
    switch self {
    case .pending: return false
    case .remote: return true
    }
  }

  var isPending: Bool {
    switch self {
    case .pending: return true
    case .remote: return false
    }
  }

  var id: Tweet.Identifier {
    switch self {
    case .pending(let tweet, _): return tweet.id
    case .remote(let tweet): return tweet.id
    }
  }

  var date: Date {
    switch self {
    case .pending(let tweet, _): return tweet.sentDate
    case .remote(let tweet): return tweet.date
    }
  }
}
