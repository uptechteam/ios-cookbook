//
//  ComposedTweet.swift
//  ReTweet
//
//  Created by Arthur Myronenko on 10/11/18.
//  Copyright © 2018 Arthur Mironenko. All rights reserved.
//

import Foundation

struct ComposedTweet {
  let id: Tweet.Identifier
  let text: String
  let sentDate: Date
}

extension ComposedTweet {
  init(text: String) {
    self.init(
      id: UUID().uuidString,
      text: text,
      sentDate: Date()
    )
  }
}
