//
//  Tweet.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/12/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

struct Tweet {
  typealias Identifier = String

  let id: Identifier
  let username: String
  let date: Date
  let avatar: URL
  let text: String
  let likesAmount: Int
}

extension Tweet {
  init?(response: NetworkTweet) {
    guard let avatarURL = URL(string: response.avatar) else {
      return nil
    }

    self.init(
      id: response.clientID,
      username: response.username,
      date: response.date,
      avatar: avatarURL,
      text: response.text,
      likesAmount: response.likes
    )
  }
}
